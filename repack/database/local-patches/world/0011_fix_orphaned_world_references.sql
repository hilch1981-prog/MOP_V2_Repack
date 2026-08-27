-- Pandaria 5.4.8 build 18414: remove or persist data rejected by ObjectMgr.
-- Every statement is idempotent so this file can run after each upstream update.

START TRANSACTION;

-- Linked respawns and pools cannot work without their referenced spawn/template.
DELETE lr
FROM `linked_respawn` AS lr
LEFT JOIN `creature` AS c1 ON c1.`guid` = lr.`guid`
LEFT JOIN `creature` AS c2 ON c2.`guid` = lr.`linkedGuid`
WHERE c1.`guid` IS NULL OR c2.`guid` IS NULL;

DELETE pc
FROM `pool_creature` AS pc
LEFT JOIN `creature` AS c ON c.`guid` = pc.`guid`
WHERE c.`guid` IS NULL;

DELETE pq
FROM `pool_quest` AS pq
LEFT JOIN `quest_template` AS q ON q.`Id` = pq.`entry`
WHERE q.`Id` IS NULL;

DELETE gec
FROM `game_event_creature` AS gec
LEFT JOIN `creature` AS c ON c.`guid` = gec.`guid`
WHERE c.`guid` IS NULL;

-- Remove quest-gated spell-area records whose quest is absent from this DB.
DELETE sa
FROM `spell_area` AS sa
LEFT JOIN `quest_template` AS qs ON qs.`Id` = sa.`quest_start`
LEFT JOIN `quest_template` AS qe ON qe.`Id` = sa.`quest_end`
WHERE (sa.`quest_start` <> 0 AND qs.`Id` IS NULL)
   OR (sa.`quest_end` <> 0 AND qe.`Id` IS NULL);

-- ObjectMgr already clears missing heroic key requirements in memory. Persist it.
UPDATE `access_requirement` AS ar
LEFT JOIN `item_template` AS i ON i.`entry` = ar.`item`
SET ar.`item` = 0
WHERE ar.`item` <> 0 AND i.`entry` IS NULL;

UPDATE `access_requirement` AS ar
LEFT JOIN `item_template` AS i ON i.`entry` = ar.`item2`
SET ar.`item2` = 0
WHERE ar.`item2` <> 0 AND i.`entry` IS NULL;

-- Persist quest flags otherwise added only in memory at every startup.
UPDATE `quest_template`
SET `SpecialFlags` = (`SpecialFlags` | 1)
WHERE `Id` = 31539;

UPDATE `quest_template`
SET `SpecialFlags` = (`SpecialFlags` | 2)
WHERE `Id` IN
(
    869,13564,14066,25621,26512,26930,27007,27152,27610,
    29392,29415,29536,29539,30470,32640,32641
);

-- These seasonal LFG rows have no entrance AreaTrigger for map 734 and never load.
DELETE FROM `lfg_dungeon_template`
WHERE `dungeonId` IN (299,310);

-- These rows target effects which are not TARGET_DEST_DB in build 18414.
DELETE FROM `spell_target_position`
WHERE (`id`,`effIndex`) IN
(
    (65042,2),(100679,2),(49986,1),
    (66925,0),(66836,0),(105002,0)
);

-- Server/custom spells absent from the 18414 Spell.dbc cannot be linked.
DELETE FROM `spell_linked_spell`
WHERE ABS(`spell_trigger`) IN (203754,200002,200003)
   OR ABS(`spell_effect`) IN (203754,200002,200003);

-- Loot templates without their owning creature template are never reachable.
DELETE FROM `creature_loot_template`
WHERE `Entry` IN (60491,62346);

-- Conditions rejected because their referenced creature/template/item is absent.
DELETE FROM `conditions`
WHERE (`ConditionTypeOrReference` = 31 AND `ConditionValue2` IN (27754,33909,33906,40684,31317))
   OR (`SourceTypeOrReferenceId` = 18 AND `SourceGroup` IN (35431,35433))
   OR (`SourceTypeOrReferenceId` = 1 AND `SourceGroup` = 60491)
   OR (`SourceTypeOrReferenceId` = 1 AND `SourceEntry` IN (-738,-777));

-- Spell implicit-target condition groups rejected in their entirety by the core.
DELETE FROM `conditions`
WHERE `SourceTypeOrReferenceId` = 13
  AND `SourceGroup` = 1
  AND `SourceEntry` IN
      (77782,77925,77932,77937,86911,87517,92831,96931,119841,139848);

-- Path 64249 is zero-based; SmartWaypointMgr requires point IDs starting at one.
SET @fix_path_64249 :=
    (SELECT COUNT(*) FROM `waypoints` WHERE `entry` = 64249 AND `pointid` = 0);
UPDATE `waypoints`
SET `pointid` = `pointid` + 1000
WHERE `entry` = 64249 AND @fix_path_64249 > 0;
UPDATE `waypoints`
SET `pointid` = `pointid` - 999
WHERE `entry` = 64249 AND `pointid` >= 1000 AND @fix_path_64249 > 0;

COMMIT;
