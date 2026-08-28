-- Restore missing profession trainer lists and make every usable profession
-- trainer expose a trainer gossip option.  Safe to run repeatedly.
SET NAMES utf8mb4;

-- This database materialized the upstream shared trainer lists into individual
-- NPC rows, but several higher-rank and specialization trainers lost their
-- shared-list link.  Rebuild the canonical lists from complete local donors.
DELETE FROM `npc_trainer` WHERE `entry` IN (200401,200407,200408,200433);

INSERT INTO `npc_trainer`
    (`entry`,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,`RaceMask`)
SELECT 200401,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,0
FROM `npc_trainer` WHERE `entry`=1241 AND `spell`>0;

INSERT INTO `npc_trainer`
    (`entry`,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,`RaceMask`)
SELECT 200407,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,0
FROM `npc_trainer` WHERE `entry`=1385 AND `spell`>0;

INSERT INTO `npc_trainer`
    (`entry`,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,`RaceMask`)
SELECT 200408,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,0
FROM `npc_trainer` WHERE `entry`=1701 AND `spell`>0;

INSERT INTO `npc_trainer`
    (`entry`,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,`RaceMask`)
SELECT 200433,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,0
FROM `npc_trainer` WHERE `entry`=8126 AND `spell`>0;

DELETE FROM `npc_trainer`
WHERE `entry` IN (6297,7232,7866,7867,8738) AND `spell`<0;

INSERT INTO `npc_trainer`
    (`entry`,`spell`,`spellcost`,`reqskill`,`reqskillvalue`,`reqlevel`,`RaceMask`)
VALUES
    (6297,-200408,0,0,0,0,0), -- Kurdram Stonehammer: Mining
    (7232,-200401,0,0,0,0,0), -- Borgus Steelhand: Blacksmithing
    (7866,-200407,0,0,0,0,0), -- Peter Galen: Leatherworking
    (7867,-200407,0,0,0,0,0), -- Thorkaf Dragoneye: Leatherworking
    (8738,-200433,0,0,0,0,0)  -- Vazario Linkgrease: Goblin Engineering
ON DUPLICATE KEY UPDATE
    `spellcost`=VALUES(`spellcost`),`reqskill`=VALUES(`reqskill`),
    `reqskillvalue`=VALUES(`reqskillvalue`),`reqlevel`=VALUES(`reqlevel`),
    `RaceMask`=VALUES(`RaceMask`);

-- Keep the five repaired NPCs marked as usable profession trainers.
UPDATE `creature_template`
SET `npcflag`=`npcflag`|16, `trainer_type`=2
WHERE `entry` IN (6297,7232,7866,7867,8738);

-- Add a database-side trainer choice to every non-default profession gossip
-- menu that has real trainer data but no trainer choice.  Slot 63 is reserved
-- for this repair; if a custom menu already uses it, the core fallback handles
-- that menu without overwriting custom content.
INSERT INTO `gossip_menu_option`
    (`menu_id`,`id`,`option_icon`,`option_text`,`option_text_female`,`option_id`,
     `npc_option_npcflag`,`action_menu_id`,`action_poi_id`,`box_coded`,`box_money`,
     `box_text`,`box_text_female`)
SELECT DISTINCT
    c.`gossip_menu_id`,63,3,'훈련을 받고 싶습니다.','Train me.',5,
    16,0,0,0,0,NULL,NULL
FROM `creature_template` c
WHERE c.`trainer_type`=2
  AND (c.`npcflag` & 16)<>0
  AND c.`gossip_menu_id`<>0
  AND EXISTS (SELECT 1 FROM `npc_trainer` n WHERE n.`entry`=c.`entry`)
  AND NOT EXISTS (
      SELECT 1 FROM `gossip_menu_option` g
      WHERE g.`menu_id`=c.`gossip_menu_id` AND g.`option_id`=5)
  AND NOT EXISTS (
      SELECT 1 FROM `gossip_menu_option` g
      WHERE g.`menu_id`=c.`gossip_menu_id` AND g.`id`=63);

-- Korean text for both the default option and every explicit profession
-- trainer option, including cooking, fishing, first aid, and archaeology.
UPDATE `gossip_menu_option` g
JOIN `creature_template` c ON c.`gossip_menu_id`=g.`menu_id`
SET g.`option_text`='훈련을 받고 싶습니다.'
WHERE c.`trainer_type`=2 AND (c.`npcflag` & 16)<>0 AND g.`option_id`=5;

UPDATE `gossip_menu_option`
SET `option_text`='훈련을 받고 싶습니다.'
WHERE `menu_id`=0 AND `id`=3 AND `option_id`=5;

INSERT INTO `gossip_menu_option_locale`
    (`MenuID`,`OptionID`,`Locale`,`OptionText`,`BoxText`)
SELECT DISTINCT g.`menu_id`,g.`id`,'koKR','훈련을 받고 싶습니다.',''
FROM `gossip_menu_option` g
JOIN `creature_template` c ON c.`gossip_menu_id`=g.`menu_id`
WHERE c.`trainer_type`=2 AND (c.`npcflag` & 16)<>0 AND g.`option_id`=5
ON DUPLICATE KEY UPDATE
    `OptionText`=VALUES(`OptionText`),`BoxText`=VALUES(`BoxText`);

INSERT INTO `gossip_menu_option_locale`
    (`MenuID`,`OptionID`,`Locale`,`OptionText`,`BoxText`)
VALUES (0,3,'koKR','훈련을 받고 싶습니다.','')
ON DUPLICATE KEY UPDATE
    `OptionText`=VALUES(`OptionText`),`BoxText`=VALUES(`BoxText`);
