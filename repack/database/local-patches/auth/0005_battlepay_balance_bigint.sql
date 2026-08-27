-- Battle Coin raw balances use 10,000 database units per coin.
-- Add the column on a fresh auth database, or widen an existing column.
SET @has_dp := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'account'
    AND column_name = 'dp'
);
SET @dp_sql := IF(
  @has_dp = 0,
  'ALTER TABLE `account` ADD COLUMN `dp` BIGINT UNSIGNED NOT NULL DEFAULT 0',
  'ALTER TABLE `account` MODIFY COLUMN `dp` BIGINT UNSIGNED NOT NULL DEFAULT 0'
);
PREPARE dp_statement FROM @dp_sql;
EXECUTE dp_statement;
DEALLOCATE PREPARE dp_statement;
