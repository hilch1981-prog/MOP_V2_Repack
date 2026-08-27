-- Pandaria 5.4.8 build 18414: final startup compatibility fixes.
-- Idempotent and safe to reapply after upstream database updates.

START TRANSACTION;

-- The two seasonal LFG entries are present in LFGDungeons.dbc but map 734 has
-- no entrance AreaTrigger.  These are the official SkyFire entrance coords.
INSERT INTO `lfg_dungeon_template`
    (`dungeonId`,`name`,`position_x`,`position_y`,`position_z`,`orientation`,`requiredItemLevel`)
VALUES
    (299,'Prince Sarsarun',-9132.12,1599.28,26.848,5.31086,0),
    (310,'Prince Sarsarun',-9132.12,1599.28,26.848,5.31086,0)
ON DUPLICATE KEY UPDATE
    `position_x`=VALUES(`position_x`),
    `position_y`=VALUES(`position_y`),
    `position_z`=VALUES(`position_z`),
    `orientation`=VALUES(`orientation`),
    `requiredItemLevel`=VALUES(`requiredItemLevel`);

-- Spell 23218 has no area-aura effect in the 18414 client data, therefore
-- this handler can never execute and must not be bound.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 23218
  AND `ScriptName` = 'spell_dru_shapeshift_move_speed';

-- Achievement ID 0 means that these two guild rewards have no achievement
-- requirement.  Store it as an empty list so the loader does not parse 0 as
-- a missing achievement.
UPDATE `guild_rewards`
SET `achievements` = ''
WHERE `entry` IN (69209,69210)
  AND `achievements` = '0';

COMMIT;

-- Existing AHBot auctions were written with character GUIDs 2/3 in the
-- auctioneer field by the old core.  With cross-faction AH enabled, use the
-- valid neutral auctioneer spawn from this world database.
UPDATE `characters`.`auctionhouse`
SET `auctioneerguid` = 274539
WHERE `auctioneerguid` IN (2,3);
