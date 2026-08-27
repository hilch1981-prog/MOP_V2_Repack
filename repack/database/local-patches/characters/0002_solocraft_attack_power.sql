-- Preserve the direct SoloCraft attack-power bonus so it can be removed cleanly.
SET @solocraft_attack_power_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'custom_solocraft_character_stats'
      AND COLUMN_NAME = 'attack_power'
);

SET @solocraft_attack_power_sql := IF(
    @solocraft_attack_power_exists = 0,
    'ALTER TABLE `custom_solocraft_character_stats` ADD COLUMN `attack_power` INT NOT NULL DEFAULT 0 AFTER `stats`',
    'SELECT 1'
);

PREPARE solocraft_attack_power_stmt FROM @solocraft_attack_power_sql;
EXECUTE solocraft_attack_power_stmt;
DEALLOCATE PREPARE solocraft_attack_power_stmt;
