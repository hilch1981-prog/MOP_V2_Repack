-- Repair accounts on which spell 125610 was learned without executing its
-- SPELL_EFFECT_UNLOCK_BATTLE_PETS effect.

INSERT IGNORE INTO `account_spell` (`account`, `spell`, `active`, `disabled`)
SELECT `account`, 119467, 1, 0 FROM `account_spell` WHERE `spell` = 125610;
INSERT IGNORE INTO `account_spell` (`account`, `spell`, `active`, `disabled`)
SELECT `account`, 122026, 1, 0 FROM `account_spell` WHERE `spell` = 125610;
INSERT IGNORE INTO `account_spell` (`account`, `spell`, `active`, `disabled`)
SELECT `account`, 125439, 1, 0 FROM `account_spell` WHERE `spell` = 125610;

INSERT INTO `account_battle_pet_slots` (`accountId`, `slot1`, `slot2`, `slot3`, `flags`)
SELECT trained.`account`, COALESCE(MIN(pet.`id`), 0), 0, 0, 1
FROM `account_spell` trained
LEFT JOIN `account_battle_pet` pet ON pet.`accountId` = trained.`account`
WHERE trained.`spell` = 125610
GROUP BY trained.`account`
ON DUPLICATE KEY UPDATE
    `slot1` = IF(`slot1` = 0, VALUES(`slot1`), `slot1`),
    `flags` = `flags` | 1;

UPDATE `characters` characterRow
INNER JOIN `account_spell` trained
    ON trained.`account` = characterRow.`account` AND trained.`spell` = 125610
SET characterRow.`playerFlags` = characterRow.`playerFlags` | 16777216;
