-- Restore the four MoP battle-pet daily quests that existed in
-- quest_template/objectives but had no creature start/end relation.
-- Safe to run repeatedly.
SET NAMES utf8mb4;

DELETE FROM `creature_queststarter`
WHERE (`id`,`quest`) IN (
    (66819,31972), -- Brok
    (66815,31973), -- Bordin Steadyfist
    (66822,31974), -- Goz Banefury
    (68464,32440)  -- Whispering Pandaren Spirit
);

INSERT INTO `creature_queststarter` (`id`,`quest`) VALUES
    (66819,31972),
    (66815,31973),
    (66822,31974),
    (68464,32440);

DELETE FROM `creature_questender`
WHERE (`id`,`quest`) IN (
    (66819,31972),
    (66815,31973),
    (66822,31974),
    (68464,32440)
);

INSERT INTO `creature_questender` (`id`,`quest`) VALUES
    (66819,31972),
    (66815,31973),
    (66822,31974),
    (68464,32440);

-- Every NPC represented in the trainer-team table now owns at least one
-- quest.  Keep both QUESTGIVER (1) and GOSSIP (2) enabled so the client opens
-- a quest/gossip menu instead of treating a questless one-option NPC as a
-- direct battle interaction.
UPDATE `creature_template` c
JOIN (SELECT DISTINCT `NpcID` FROM `battlepet_npc_team_member`) t
  ON t.`NpcID`=c.`entry`
SET c.`npcflag`=c.`npcflag`|3;

