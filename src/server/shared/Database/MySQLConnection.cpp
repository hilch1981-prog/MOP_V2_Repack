/*
* This file is part of the Pandaria 5.4.8 Project. See THANKS file for Copyright information
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the
* Free Software Foundation; either version 2 of the License, or (at your
* option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <chrono>
#include <thread>

#include "Common.h"

#ifdef _WIN32
  #include <winsock2.h>
#endif
#include "MySQLCompat.h"
#include <mysqld_error.h>
#include <errmsg.h>

#include "MySQLConnection.h"
#include "MySQLThreading.h"
#include "QueryResult.h"
#include "SQLOperation.h"
#include "PreparedStatement.h"
#include "DatabaseWorker.h"
#include "Timer.h"
#include "Log.h"

MySQLConnection::MySQLConnection(MySQLConnectionInfo& connInfo, ConnectionFlags index)
    : m_reconnecting(false), m_prepareError(false), m_Mysql(NULL), m_connectionInfo(connInfo), m_connectionFlags(index)
{
}

MySQLConnection::~MySQLConnection()
{
    Close();
}

void MySQLConnection::Close()
{
    ASSERT(m_Mysql); /// MySQL context must be present at this point

    for (size_t i = 0; i < m_stmts.size(); ++i)
        delete m_stmts[i];

    mysql_close(m_Mysql);
}

bool MySQLConnection::Open()
{
    MYSQL *mysqlInit;
    mysqlInit = mysql_init(NULL);
    if (!mysqlInit)
    {
        TC_LOG_ERROR("sql.driver", "Could not initialize Mysql connection to database `%s`", m_connectionInfo.database.c_str());
        return false;
    }

    int port;
    char const* unix_socket;
    //unsigned int timeout = 10;

    mysql_options(mysqlInit, MYSQL_SET_CHARSET_NAME, "utf8");
#ifdef _WIN32
    // MariaDB Connector/C can require TLS by default on Windows. The bundled
    // database is bound to 127.0.0.1 only, so explicitly allow the local
    // connection to use the existing password-authenticated transport.
    // Keep these MariaDB-specific options out of non-Windows builds because
    // libmysqlclient-compatible headers on Linux do not expose both symbols.
    my_bool sslEnforce = 0;
    my_bool sslVerifyServerCert = 0;
    mysql_options(mysqlInit, MYSQL_OPT_SSL_ENFORCE, &sslEnforce);
    mysql_options(mysqlInit, MYSQL_OPT_SSL_VERIFY_SERVER_CERT, &sslVerifyServerCert);
#endif
    //mysql_options(mysqlInit, MYSQL_OPT_READ_TIMEOUT, (char const*)&timeout);
    #ifdef _WIN32
    if (m_connectionInfo.host == ".")                                           // named pipe use option (Windows)
    {
        unsigned int opt = MYSQL_PROTOCOL_PIPE;
        mysql_options(mysqlInit, MYSQL_OPT_PROTOCOL, (char const*)&opt);
        port = 0;
        unix_socket = 0;
    }
    else                                                    // generic case
    {
        port = atoi(m_connectionInfo.port_or_socket.c_str());
        unix_socket = 0;
    }
    #else
    if (m_connectionInfo.host == ".")                                           // socket use option (Unix/Linux)
    {
        unsigned int opt = MYSQL_PROTOCOL_SOCKET;
        mysql_options(mysqlInit, MYSQL_OPT_PROTOCOL, (char const*)&opt);
        m_connectionInfo.host = "localhost";
        port = 0;
        unix_socket = m_connectionInfo.port_or_socket.c_str();
    }
    else                                                    // generic case
    {
        port = atoi(m_connectionInfo.port_or_socket.c_str());
        unix_socket = 0;
    }
    #endif

    m_Mysql = mysql_real_connect(mysqlInit, m_connectionInfo.host.c_str(), m_connectionInfo.user.c_str(),
        m_connectionInfo.password.c_str(), m_connectionInfo.database.c_str(), port, unix_socket, 0);

    if (m_Mysql)
    {
        if (!m_reconnecting)
        {
            TC_LOG_INFO("sql.driver", "MySQL client library: %s", mysql_get_client_info());
            TC_LOG_INFO("sql.driver", "MySQL server ver: %s ", mysql_get_server_info(m_Mysql));
            // MySQL version above 5.1 IS required in both client and server and there is no known issue with different versions above 5.1
            // if (mysql_get_server_version(m_Mysql) != mysql_get_client_version())
            //     TC_LOG_INFO("sql.driver", "[WARNING] MySQL client/server version mismatch; may conflict with behaviour of prepared statements.");
        }

        TC_LOG_INFO("sql.driver", "Connected to MySQL database at %s", m_connectionInfo.host.c_str());
        mysql_autocommit(m_Mysql, 1);

        // set connection properties to UTF8 to properly handle locales for different
        // server configs - core sends data in UTF8, so MySQL must expect UTF8 too
        mysql_set_character_set(m_Mysql, "utf8");

        return true;
    }
    else
    {
        TC_LOG_ERROR("sql.driver", "Could not connect to MySQL database at %s: %s", m_connectionInfo.host.c_str(), mysql_error(mysqlInit));
        mysql_close(mysqlInit);
        return false;
    }
}

bool MySQLConnection::PrepareStatements()
{
    DoPrepareStatements();

    if (m_prepareError)
        return false;

    return true;
}

bool MySQLConnection::Execute(char const* sql)
{
    if (!m_Mysql)
        return false;

    {
        ACE_Guard<ACE_Thread_Mutex> guard(m_Mutex);
        if (mysql_query(m_Mysql, sql))
        {
            uint32 lErrno = mysql_errno(m_Mysql);
            TC_LOG_INFO("sql.sql", "SQL: %s", sql);
            TC_LOG_ERROR("sql.sql", "SQL ERROR: %s", mysql_error(m_Mysql));

            if (_HandleMySQLErrno(lErrno)) // If it returns true, an error was handled successfully (i.e. reconnection)
                return Execute(sql);       // Try again

            return false;
        }
    }

    return true;
}

bool MySQLConnection::Execute(PreparedStatement* stmt)
{
    if (!m_Mysql)
        return false;

    {
        ACE_Guard<ACE_Thread_Mutex> guard(m_Mutex);
        PreparedStatementTask* task = new PreparedStatementTask(stmt);
        task->Execute(m_Mysql);
        delete task;
    }

    return true;
}

ResultSet* MySQLConnection::Query(char const* sql)
{
    if (!m_Mysql)
        return NULL;

    MYSQL_RES *result = NULL;
    MYSQL_FIELD *fields = NULL;
    uint64 rowCount = 0;
    uint32 fieldCount = 0;

    {
        ACE_Guard<ACE_Thread_Mutex> guard(m_Mutex);
        if (mysql_query(m_Mysql, sql))
        {
            uint32 lErrno = mysql_errno(m_Mysql);
            TC_LOG_INFO("sql.sql", "SQL: %s", sql);
            TC_LOG_ERROR("sql.sql", "SQL ERROR: %s", mysql_error(m_Mysql));

            if (_HandleMySQLErrno(lErrno)) // If it returns true, an error was handled successfully (i.e. reconnection)
                return Query(sql);          // Try again

            return NULL;
        }

        result = mysql_store_result(m_Mysql);
        rowCount = mysql_affected_rows(m_Mysql);
        fieldCount = mysql_field_count(m_Mysql);
    }

    if (!result)
        return NULL;

    if (!rowCount)
    {
        mysql_free_result(result);
        return NULL;
    }

    fields = mysql_fetch_fields(result);
    return new ResultSet(result, fields, rowCount, fieldCount);
}

PreparedResultSet* MySQLConnection::Query(PreparedStatement* stmt)
{
    if (!m_Mysql)
        return NULL;

    PreparedResultSet* result = NULL;

    {
        ACE_Guard<ACE_Thread_Mutex> guard(m_Mutex);
        PreparedStatementTask* task = new PreparedStatementTask(stmt);
        result = task->Query(m_Mysql);
        delete task;
    }

    return result;
}

bool MySQLConnection::_HandleMySQLErrno(uint32 errNo)
{
    switch (errNo)
    {
        case CR_SERVER_GONE_ERROR:
        case CR_SERVER_LOST:
        case CR_INVALID_CONN_HANDLE:
        case CR_SERVER_LOST_EXTENDED:
        {
            m_Mysql = NULL;
            if (m_reconnecting)
                return false;

            m_reconnecting = true;
            uint64 oldThreadId = mysql_thread_id(m_Mysql);

            TC_LOG_ERROR("sql.sql", "Lost the connection to the MySQL server!");

            while (!Open())
            {
                TC_LOG_ERROR("sql.sql", "Could not reconnect to the MySQL database, retrying in 5 seconds...");
                std::this_thread::sleep_for(std::chrono::seconds(5));
            }

            if (!PrepareStatements())
            {
                TC_LOG_FATAL("sql.sql", "Could not re-prepare statements after reconnecting to the MySQL database, terminating server.");
                exit(1);
            }

            TC_LOG_INFO("sql.sql", "MySQL connection reestablished to `%s`", m_connectionInfo.database.c_str());

            m_reconnecting = false;
            return true;
        }
        case ER_LOCK_DEADLOCK:
            return false;
        case ER_WRONG_VALUE_COUNT_ON_ROW:
        case ER_DUP_ENTRY:
            return false;
        default:
            TC_LOG_ERROR("sql.sql", "Unhandled MySQL errno %u. Unexpected behaviour possible.", errNo);
            return false;
    }
}
