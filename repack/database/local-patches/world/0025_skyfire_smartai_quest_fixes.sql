-- Selected ProjectSkyfire SmartAI/quest fixes adapted for the Pandaria schema.
-- Sources: 2026_08_24_world_03 and 2026_08_25_world_01.
-- Adaptations: remove SkyFire-only event_param5 and replace foreign spawn GUIDs
-- with template/coordinate matching against the MOP world database.
-- Idempotent: this local patch is reapplied by Update-Database.ps1.

START TRANSACTION;

-- Quest object 204777: summon the Lurking Worgen when the mound is activated.
UPDATE `gameobject_template`
SET `data3` = 30000, `AIName` = 'SmartGameObjectAI'
WHERE `entry` = 204777;

DELETE FROM `smart_scripts`
WHERE `entryorguid` = 204777 AND `source_type` = 1;

INSERT INTO `smart_scripts`
(`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,
 `event_param1`,`event_param2`,`event_param3`,`event_param4`,
 `action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,
 `target_type`,`target_param1`,`target_param2`,`target_param3`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`)
VALUES
(204777,1,0,0,70,0,100,0,2,0,0,0,12,43799,6,0,1,0,0,8,0,0,0,-11127.5,-518.424,35.2569,0.436332,'Mound of Loose Dirt - On Activate - Summon Lurking Worgen');

-- The source SQL used SkyFire spawn GUID 192110.  In MOP that GUID belongs to
-- another NPC, so target the actual Lurking Worgen at the sniffed coordinates.
DELETE FROM `creature`
WHERE `id` = 43799 AND `map` = 0
  AND ABS(`position_x` - (-11127.5)) < 0.1
  AND ABS(`position_y` - (-518.424)) < 0.1
  AND ABS(`position_z` - 35.2569) < 0.1;

DELETE FROM `creature_template_addon` WHERE `entry` = 43799;
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 43799;

DELETE FROM `smart_scripts`
WHERE `entryorguid` = 43799 AND `source_type` = 0;

INSERT INTO `smart_scripts`
(`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,
 `event_param1`,`event_param2`,`event_param3`,`event_param4`,
 `action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,
 `target_type`,`target_param1`,`target_param2`,`target_param3`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`)
VALUES
(43799,0,0,0,0,0,100,1,0,0,0,0,11,81957,0,0,0,0,0,2,0,0,0,0,0,0,0,'Lurking Worgen - In Combat - Cast Stunning Pounce');

-- Breaking Waves of Change: add the missing speak-to-Vesprystus objectives.
DELETE FROM `quest_objective` WHERE `questId` IN (26383,26385);
INSERT INTO `quest_objective`
(`questId`,`id`,`index`,`type`,`objectId`,`amount`,`flags`,`description`)
VALUES
(26383,2638300,0,10,0,0,0,'Use the teleportation tree in western Darnassus to reach Rut''theran Village, then speak to Vesprystus to secure a ride to Lor''danel.'),
(26385,2638500,0,10,0,0,0,'Speak to Vesprystus in Rut''theran Village to secure a ride to Lor''danel.');

UPDATE `quest_template`
SET `SpecialFlags` = (`SpecialFlags` | 2)
WHERE `Id` IN (26383,26385);

DELETE FROM `smart_scripts`
WHERE `entryorguid` = 3838 AND `source_type` = 0 AND `id` IN (3,4);

INSERT INTO `smart_scripts`
(`entryorguid`,`source_type`,`id`,`link`,`event_type`,`event_phase_mask`,`event_chance`,`event_flags`,
 `event_param1`,`event_param2`,`event_param3`,`event_param4`,
 `action_type`,`action_param1`,`action_param2`,`action_param3`,`action_param4`,`action_param5`,`action_param6`,
 `target_type`,`target_param1`,`target_param2`,`target_param3`,`target_x`,`target_y`,`target_z`,`target_o`,`comment`)
VALUES
(3838,0,3,0,64,0,100,0,0,0,0,0,15,26383,0,0,0,0,0,7,0,0,0,0,0,0,0,'Vesprystus - On Gossip Hello - Credit quest 26383'),
(3838,0,4,0,64,0,100,0,0,0,0,0,15,26385,0,0,0,0,0,7,0,0,0,0,0,0,0,'Vesprystus - On Gossip Hello - Credit quest 26385');

COMMIT;
