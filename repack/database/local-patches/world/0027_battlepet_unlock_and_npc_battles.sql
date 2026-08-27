-- Complete the Battle Pet Training unlock chain and expose NPC tamer battles.
-- The core supplies the dynamic localized gossip option and reads each team
-- from battlepet_npc_team_member.

SET NAMES utf8mb4;

DELETE FROM `spell_learn_spell`
WHERE `entry` = 119467 AND `SpellID` = 122026;
INSERT INTO `spell_learn_spell` (`entry`, `SpellID`, `Active`)
VALUES (119467, 122026, 1);

UPDATE `creature_template`
SET `npcflag` = `npcflag` | 1
WHERE `entry` IN (
    SELECT DISTINCT `NpcID`
    FROM `battlepet_npc_team_member`
);
