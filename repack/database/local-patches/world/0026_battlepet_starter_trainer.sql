-- Restore the MoP battle-pet starter trainers (Audrey Burnhep / Varzok).
-- The source data uses a trainer RaceMask so each race only sees its own
-- starter companion.  The column and data are kept idempotent for repack use.

SET @has_race_mask := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'npc_trainer'
      AND COLUMN_NAME = 'RaceMask'
);
SET @add_race_mask_sql := IF(
    @has_race_mask = 0,
    'ALTER TABLE `npc_trainer` ADD COLUMN `RaceMask` INT UNSIGNED NOT NULL DEFAULT 0 AFTER `reqlevel`',
    'SELECT 1'
);
PREPARE add_race_mask_stmt FROM @add_race_mask_sql;
EXECUTE add_race_mask_stmt;
DEALLOCATE PREPARE add_race_mask_stmt;

UPDATE `creature_template`
SET `npcflag` = 151,
    `trainer_type` = 2,
    `trainer_class` = 0,
    `trainer_race` = 0
WHERE `entry` IN (63596, 63626);

DELETE FROM `npc_trainer` WHERE `entry` IN (63596, 63626);
INSERT INTO `npc_trainer`
    (`entry`, `spell`, `spellcost`, `reqskill`, `reqskillvalue`, `reqlevel`, `RaceMask`)
VALUES
    (63596, 10676,  0, 0, 0, 0,        1), -- Human: Orange Tabby Cat
    (63596, 10707,  0, 0, 0, 0,        8), -- Night Elf: Great Horned Owl
    (63596, 10711,  0, 0, 0, 0,       68), -- Dwarf/Gnome: Snowshoe Rabbit
    (63596, 35907,  0, 0, 0, 0,     1024), -- Draenei: Blue Moth
    (63596, 123214, 0, 0, 0, 0,  2097152), -- Worgen: Gilnean Raven
    (63596, 125610, 0, 0, 0, 1,        0), -- Battle Pet Training
    (63596, 127816, 0, 0, 0, 0, 58720256), -- Pandaren: Jade Crane Chick
    (63626, 10688,  0, 0, 0, 0,       16), -- Undead: Undercity Cockroach
    (63626, 10709,  0, 0, 0, 0,       32), -- Tauren: Brown Prairie Dog
    (63626, 10714,  0, 0, 0, 0,      130), -- Orc/Troll: Black Kingsnake
    (63626, 36027,  0, 0, 0, 0,      512), -- Blood Elf: Golden Dragonhawk Hatchling
    (63626, 123212, 0, 0, 0, 0,      256), -- Goblin: Shore Crawler
    (63626, 125610, 0, 0, 0, 1,        0), -- Battle Pet Training
    (63626, 127816, 0, 0, 0, 0, 58720256); -- Pandaren: Jade Crane Chick

DELETE FROM `gossip_menu_option` WHERE `menu_id` = 14991 AND `id` IN (0, 1);
INSERT INTO `gossip_menu_option`
    (`menu_id`, `id`, `option_icon`, `option_text`, `option_text_female`,
     `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_poi_id`,
     `box_coded`, `box_money`, `box_text`, `box_text_female`)
VALUES
    (14991, 0, 2, 'I am interested in pet battle training.', NULL,
     5, 16, 0, 0, 0, 0, '', NULL),
    (14991, 1, 1, 'I want to browse your goods.', NULL,
     3, 128, 0, 0, 0, 0, '', NULL);

DELETE FROM `gossip_menu_option_locale`
WHERE `MenuID` = 14991 AND `OptionID` IN (0, 1) AND `Locale` = 'koKR';
INSERT INTO `gossip_menu_option_locale`
    (`MenuID`, `OptionID`, `Locale`, `OptionText`, `BoxText`)
VALUES
    (14991, 0, 'koKR', '전투 애완동물 훈련에 관심이 있습니다.', ''),
    (14991, 1, 'koKR', '상품을 보여 주세요.', '');

DELETE FROM `npc_vendor`
WHERE `entry` IN (63596, 63626) AND `item` = 98715;
INSERT INTO `npc_vendor`
    (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`, `type`)
VALUES
    (63596, 0, 98715, 0, 0, 4295, 1),
    (63626, 0, 98715, 0, 0, 4295, 1);
