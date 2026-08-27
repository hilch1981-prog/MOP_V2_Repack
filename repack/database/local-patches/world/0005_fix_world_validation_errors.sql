-- Pandaria 5.4.8 build 18414: repair rows that the core rejects or rewrites at startup.
-- This patch changes invalid source data; it does not suppress server logging.

START TRANSACTION;

-- Persist the same creature-template corrections that ObjectMgr otherwise makes
-- only in memory on every startup.
UPDATE `creature_template`
SET `flags_extra` = (`flags_extra` & ~4194304)
WHERE `entry` = 32930;

UPDATE `creature_template`
SET `flags_extra` = (`flags_extra` & ~536870912)
WHERE `entry` = 34519;

UPDATE `creature_template`
SET `flags_extra` = (`flags_extra` & ~1073741824)
WHERE `entry` = 37921;

UPDATE `creature_template`
SET `unit_class` = 1
WHERE `entry` = 59637 AND `unit_class` = 0;

DELETE cta
FROM `creature_template_addon` AS cta
LEFT JOIN `creature_template` AS ct ON ct.`entry` = cta.`entry`
WHERE ct.`entry` IS NULL;

UPDATE `creature_template_addon`
SET `emote` = 0
WHERE `entry` = 64249 AND `emote` = 1;

-- Rows without a matching template are discarded by the core and can never spawn.
DELETE c
FROM `creature` AS c
LEFT JOIN `creature_template` AS ct ON ct.`entry` = c.`id`
WHERE ct.`entry` IS NULL;

DELETE ca
FROM `creature_addon` AS ca
LEFT JOIN `creature` AS c ON c.`guid` = ca.`guid`
WHERE c.`guid` IS NULL;

UPDATE `creature`
SET `wander_distance` = 0
WHERE `movement_type` = 0 AND `wander_distance` <> 0;

-- These objectives reference post-18414 or otherwise absent client records and
-- are rejected before localization is loaded. Remove the unusable objectives and
-- their locale rows together so all locales stay consistent.
DELETE FROM `quest_objective_locale`
WHERE `ID` IN (267730,268034,269192,269193,269194,270827,272423,273866,280563,280564,284684,284686);

DELETE FROM `quest_objective`
WHERE `id` IN (267730,268034,269192,269193,269194,270827,272423,273866,280563,280564,284684,284686);

-- Objectives of explicitly disabled (NYI) quests are intentionally not loaded
-- by ObjectMgr. Their locale rows would otherwise be reported as invalid even
-- though the objective definitions are retained for future implementation.
DELETE qol
FROM `quest_objective_locale` AS qol
JOIN `quest_objective` AS qo ON qo.`id` = qol.`ID`
JOIN `disables` AS d ON d.`sourceType` = 1 AND d.`entry` = qo.`questId`;

-- Remove quest relations whose quest template is absent.
DELETE r
FROM `creature_queststarter` AS r
LEFT JOIN `quest_template` AS q ON q.`Id` = r.`quest`
WHERE q.`Id` IS NULL;

DELETE r
FROM `creature_questender` AS r
LEFT JOIN `quest_template` AS q ON q.`Id` = r.`quest`
WHERE q.`Id` IS NULL;

DELETE r
FROM `gameobject_queststarter` AS r
LEFT JOIN `quest_template` AS q ON q.`Id` = r.`quest`
WHERE q.`Id` IS NULL;

DELETE r
FROM `gameobject_questender` AS r
LEFT JOIN `quest_template` AS q ON q.`Id` = r.`quest`
WHERE q.`Id` IS NULL;

-- Every creature used as a quest starter/ender must expose the questgiver flag.
UPDATE `creature_template` AS ct
JOIN (
    SELECT `id` FROM `creature_queststarter`
    UNION
    SELECT `id` FROM `creature_questender`
) AS qg ON qg.`id` = ct.`entry`
SET ct.`npcflag` = (ct.`npcflag` | 2)
WHERE (ct.`npcflag` & 2) = 0;

-- Invalid or inert SmartAI rows identified by the 18414 validator.
DELETE FROM `smart_scripts`
WHERE `entryorguid` = 53619 AND `source_type` = 0 AND `id` = 10
  AND `event_type` = 31 AND `event_param1` = 100101;

DELETE FROM `smart_scripts`
WHERE `entryorguid` = 55283 AND `source_type` = 0 AND `id` = 0
  AND `action_type` = 208;

-- These creatures are controlled by their named C++ scripts, so their ignored
-- SmartAI rows are stale duplicates.
DELETE FROM `smart_scripts`
WHERE `source_type` = 0 AND `entryorguid` IN (64267,64656);

-- Timed action list 3304100 is invoked on spawn and despawns after five seconds.
-- Its former 0/33041/5/0 timing tuple was invalid and the row was skipped.
UPDATE `smart_scripts`
SET `event_param1` = 5000,
    `event_param2` = 5000,
    `event_param3` = 0,
    `event_param4` = 0
WHERE `entryorguid` = 3304100 AND `source_type` = 9 AND `id` = 0;

-- The referenced spell effect is neither DUMMY nor SCRIPT_EFFECT in build 18414.
DELETE FROM `spell_scripts`
WHERE `id` = 130973 AND `effIndex` = 0;

COMMIT;
