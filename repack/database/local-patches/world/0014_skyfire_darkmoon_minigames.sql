-- ProjectSkyfire 5.4.8 Darkmoon Faire mini-games, adapted for the Pandaria schema.
-- Adds only the five missing game implementations; unrelated custom data is preserved.

SET @DARKMOON_EVENT_ENTRY := 75;
SET @RING_ORIGINAL_GUID := 303666;
SET @RING_NEW_GUID_1 := 8202000;
SET @RING_NEW_GUID_2 := 8202001;
SET @CANNON_TARGET_GUID := 8200300;

START TRANSACTION;

-- Whack-a-Gnoll
DELETE FROM `smart_scripts`
WHERE (`source_type` = 0 AND `entryorguid` IN (54444,54466,54546,54549,54601,58570))
   OR (`source_type` = 9 AND `entryorguid` IN (5454600,5454601,5454602));

UPDATE `creature_template`
SET `AIName` = '',
    `ScriptName` = CASE `entry`
        WHEN 58570 THEN 'npc_whack_gnoll_bunny'
        WHEN 54601 THEN 'npc_whack_gnoll_mola'
        WHEN 54546 THEN 'npc_whack_gnoll_barrel'
        ELSE `ScriptName` END,
    `subname` = CASE WHEN `entry` = 54601 THEN 'Whack-a-Gnoll' ELSE `subname` END
WHERE `entry` IN (54546,54601,58570);

UPDATE `creature_template`
SET `AIName` = '', `ScriptName` = 'npc_whack_gnoll_target',
    `faction` = 2203, `minlevel` = 1, `maxlevel` = 1,
    `unit_flags` = 33555200, `unit_flags2` = 0
WHERE `entry` IN (54444,54466,54549);

DELETE FROM `spell_script_names`
WHERE `spell_id` IN (101604,101612)
   OR `ScriptName` IN ('spell_whack_gnoll_whack','spell_whack_gnoll_override_action');
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(101604,'spell_whack_gnoll_whack'),
(101612,'spell_whack_gnoll_override_action');

DELETE FROM `areatrigger_scripts`
WHERE `entry` = 7344 OR `ScriptName` = 'at_whack_a_gnoll_entrance';
INSERT INTO `areatrigger_scripts` (`entry`,`ScriptName`)
VALUES (7344,'at_whack_a_gnoll_entrance');

-- Shooting Gallery
DELETE FROM `smart_scripts`
WHERE (`source_type` = 0 AND `entryorguid` IN (14841,24171,54231))
   OR (`source_type` = 9 AND `entryorguid` IN (1484100,1484101,1484102));

UPDATE `creature_template`
SET `AIName` = '',
    `ScriptName` = CASE
        WHEN `entry` = 14841 THEN 'npc_darkmoon_rinling'
        WHEN `entry` = 54231 THEN 'npc_darkmoon_shooting_gallery_target'
        WHEN `entry` = 24171 THEN '' ELSE `ScriptName` END,
    `subname` = CASE WHEN `entry` = 14841 THEN 'Shooting Gallery' ELSE `subname` END
WHERE `entry` IN (14841,24171,54231);

UPDATE `creature_template`
SET `faction` = 35, `minlevel` = 1, `maxlevel` = 1,
    `unit_flags` = 33555200, `unit_flags2` = 2048,
    `InhabitType` = 3, `Health_mod` = 0.01
WHERE `entry` = 54231;

DELETE FROM `spell_script_names`
WHERE `spell_id` IN (101871,101872)
   OR `ScriptName` IN ('spell_darkmoon_shooting_gallery_override_action','spell_darkmoon_shooting_gallery_shoot');
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(101871,'spell_darkmoon_shooting_gallery_override_action'),
(101872,'spell_darkmoon_shooting_gallery_shoot');

-- Ring Toss. Keep the existing target and add two event-managed moving targets.
DELETE FROM `smart_scripts`
WHERE (`source_type` = 0 AND `entryorguid` IN (54485,54490))
   OR (`source_type` = 9 AND `entryorguid` = 5448500);

UPDATE `creature_template`
SET `AIName` = '', `ScriptName` = 'npc_darkmoon_jessica_rogers'
WHERE `entry` = 54485;
UPDATE `creature_template`
SET `AIName` = '', `ScriptName` = ''
WHERE `entry` = 54490;

UPDATE `gameobject_template` SET `data0` = 1729, `data1` = 80
WHERE `entry` = 210173 AND `type` = 5;
INSERT IGNORE INTO `game_event_gameobject` (`eventEntry`,`guid`)
SELECT @DARKMOON_EVENT_ENTRY,`guid` FROM `gameobject`
WHERE `id` = 210173 AND `map` = 974;

DELETE FROM `spell_script_names`
WHERE `spell_id` IN (101695,102058)
   OR `ScriptName` IN ('spell_darkmoon_ring_toss','spell_darkmoon_ring_toss_throw','spell_darkmoon_ring_toss_action');
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`) VALUES
(101695,'spell_darkmoon_ring_toss_throw'),
(102058,'spell_darkmoon_ring_toss_action');
UPDATE `quest_template` SET `RewardSpell` = 0, `RewardSpellCast` = 0 WHERE `Id` = 29455;

DELETE FROM `creature_addon` WHERE `guid` IN (@RING_NEW_GUID_1,@RING_NEW_GUID_2);
DELETE FROM `game_event_creature` WHERE `guid` IN (@RING_NEW_GUID_1,@RING_NEW_GUID_2);
DELETE FROM `creature` WHERE `guid` IN (@RING_NEW_GUID_1,@RING_NEW_GUID_2);
DELETE FROM `waypoint_data` WHERE `id` IN (@RING_NEW_GUID_1,@RING_NEW_GUID_2);

INSERT INTO `creature`
(`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`movement_type`,`npcflag`,`unit_flags`,`dynamicflags`)
VALUES
(@RING_NEW_GUID_1,54490,974,1,1,39038,0,-4290.30,6301.60,13.118,3.60,300,0,0,1,0,2,0,0,0),
(@RING_NEW_GUID_2,54490,974,1,1,39038,0,-4299.40,6289.40,13.118,1.00,300,0,0,1,0,2,0,0,0);

UPDATE `creature`
SET `position_x`=-4302.40,`position_y`=6299.20,`position_z`=13.118,
    `orientation`=5.10,`wander_distance`=0,`currentwaypoint`=0,`movement_type`=2
WHERE `guid`=@RING_ORIGINAL_GUID AND `id`=54490 AND `map`=974;

DELETE FROM `creature_addon`
WHERE `guid` IN (@RING_ORIGINAL_GUID,@RING_NEW_GUID_1,@RING_NEW_GUID_2);
INSERT INTO `creature_addon` (`guid`,`path_id`,`mount`,`bytes1`,`bytes2`,`emote`,`auras`) VALUES
(@RING_ORIGINAL_GUID,@RING_ORIGINAL_GUID,0,0,0,0,'101696'),
(@RING_NEW_GUID_1,@RING_NEW_GUID_1,0,0,0,0,'101696'),
(@RING_NEW_GUID_2,@RING_NEW_GUID_2,0,0,0,0,'101696');

DELETE FROM `waypoint_data`
WHERE `id` IN (@RING_ORIGINAL_GUID,@RING_NEW_GUID_1,@RING_NEW_GUID_2);
INSERT INTO `waypoint_data`
(`id`,`point`,`position_x`,`position_y`,`position_z`,`orientation`,`delay`,`move_flag`,`action`,`action_chance`,`wpguid`) VALUES
(@RING_ORIGINAL_GUID,1,-4302.40,6299.20,13.118,0,0,0,0,100,0),
(@RING_ORIGINAL_GUID,2,-4305.80,6294.00,13.118,0,0,0,0,100,0),
(@RING_ORIGINAL_GUID,3,-4303.00,6286.20,13.118,0,0,0,0,100,0),
(@RING_ORIGINAL_GUID,4,-4295.00,6284.00,13.118,0,0,0,0,100,0),
(@RING_ORIGINAL_GUID,5,-4290.50,6292.00,13.118,0,0,0,0,100,0),
(@RING_ORIGINAL_GUID,6,-4293.60,6301.20,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,1,-4290.30,6301.60,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,2,-4286.80,6295.50,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,3,-4288.60,6287.20,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,4,-4294.50,6282.80,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,5,-4300.40,6287.50,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_1,6,-4298.20,6297.60,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,1,-4299.40,6289.40,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,2,-4306.40,6291.80,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,3,-4305.70,6298.60,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,4,-4300.80,6303.40,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,5,-4293.30,6303.10,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,6,-4289.00,6296.00,13.118,0,0,0,0,100,0),
(@RING_NEW_GUID_2,7,-4292.80,6287.00,13.118,0,0,0,0,100,0);

INSERT IGNORE INTO `game_event_creature` (`eventEntry`,`guid`)
SELECT @DARKMOON_EVENT_ENTRY,`guid` FROM `creature`
WHERE `guid` IN (@RING_ORIGINAL_GUID,@RING_NEW_GUID_1,@RING_NEW_GUID_2)
  AND `id`=54490 AND `map`=974;

-- Tonk Challenge. Do not remove unrelated low-GUID custom spawns.
DELETE FROM `conditions`
WHERE `SourceTypeOrReferenceId`=22
  AND ((`SourceId`=0 AND `SourceEntry` IN (33081,54605))
    OR (`SourceId`=9 AND `SourceEntry`=5460500));
DELETE FROM `smart_scripts`
WHERE (`source_type`=0 AND `entryorguid` IN (33081,54605))
   OR (`source_type`=9 AND `entryorguid`=5460500);
UPDATE `creature_template`
SET `AIName`='',`ScriptName`='npc_darkmoon_finlay_coolshot' WHERE `entry`=54605;
UPDATE `creature_template`
SET `AIName`='',`ScriptName`='npc_darkmoon_tonk_cannon_target' WHERE `entry`=33081;
UPDATE `creature_template`
SET `unit_flags`=16809984,`unit_flags2`=2048,`VehicleId`=1734,
    `spell1`=102292,`spell2`=102297,`AIName`='',`ScriptName`='npc_darkmoon_steam_tonk'
WHERE `entry`=54588;
DELETE FROM `spell_script_names`
WHERE `spell_id`=100752 OR `ScriptName`='spell_darkmoon_tonk_controller';
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`)
VALUES (100752,'spell_darkmoon_tonk_controller');

-- Humanoid Cannonball
DELETE FROM `creature_addon` WHERE `guid`=@CANNON_TARGET_GUID;
DELETE FROM `game_event_creature` WHERE `guid`=@CANNON_TARGET_GUID;
DELETE FROM `creature` WHERE `guid`=@CANNON_TARGET_GUID;
INSERT INTO `creature`
(`guid`,`id`,`map`,`spawnMask`,`phaseMask`,`modelid`,`equipment_id`,`position_x`,`position_y`,`position_z`,`orientation`,`spawntimesecs`,`wander_distance`,`currentwaypoint`,`curhealth`,`curmana`,`movement_type`,`npcflag`,`unit_flags`,`dynamicflags`)
VALUES
(@CANNON_TARGET_GUID,54224,974,1,1,0,0,-4440.18,6211.33,0.224782,0,300,0,0,1,0,0,0,0,0);
INSERT IGNORE INTO `game_event_creature` (`eventEntry`,`guid`)
VALUES (@DARKMOON_EVENT_ENTRY,@CANNON_TARGET_GUID);

DELETE FROM `smart_scripts`
WHERE `source_type`=0 AND `entryorguid` IN (15303,57850);
UPDATE `creature_template`
SET `AIName`='',`ScriptName`='npc_darkmoon_maxima_blastenheimer',
    `gossip_menu_id`=6575,`npcflag`=`npcflag` | 3
WHERE `entry`=15303;
UPDATE `creature_template`
SET `AIName`='',`ScriptName`='npc_darkmoon_cannon_target'
WHERE `entry`=54224;
UPDATE `creature_template`
SET `AIName`='',`ScriptName`='npc_darkmoon_fozlebub',
    `gossip_menu_id`=13352,`npcflag`=`npcflag` | 1
WHERE `entry`=57850;
DELETE FROM `spell_script_names`
WHERE `ScriptName`='spell_darkmoon_cannon_preparation'
   OR (`spell_id`=102112 AND `ScriptName`<>'spell_darkmoon_cannon_preparation');
INSERT INTO `spell_script_names` (`spell_id`,`ScriptName`)
VALUES (102112,'spell_darkmoon_cannon_preparation');

COMMIT;
