-- BattlePay uses 10,000 database units per coin.
-- Remove legacy fractional balances so displayed, charged and spent amounts
-- always remain whole Battle Coins.
UPDATE `account`
SET `dp` = (`dp` DIV 10000) * 10000
WHERE `dp` % 10000 <> 0;
