-- SmartAI validation fixes confirmed against this core's parameter layout.

-- Quest reward events use event_param2/event_param3 as cooldown min/max.
UPDATE `smart_scripts`
SET `event_param3` = `event_param2`
WHERE (`entryorguid`, `source_type`, `id`) IN
(
    (17214, 0, 0),
    (17215, 0, 2),
    (32423, 0, 0)
)
  AND `event_type` = 20
  AND `event_param2` > `event_param3`;

-- The creature no longer exists in the current world schema, so these rows
-- can never be attached to an AI instance.
DELETE FROM `smart_scripts`
WHERE `entryorguid` = 27754
  AND `source_type` = 0
  AND NOT EXISTS
      (SELECT 1 FROM `creature_template` WHERE `entry` = 27754);

-- Action 15 completes exploration/event objectives and requires this flag.
UPDATE `quest_template`
SET `SpecialFlags` = `SpecialFlags` | 2
WHERE `Id` IN (14482, 25924);

-- These actions reference spell IDs absent from build 18414 and are skipped by
-- the core. Remove only the exact invalid action rows.
DELETE FROM `smart_scripts`
WHERE (`entryorguid`, `source_type`, `id`, `action_type`, `action_param1`) IN
(
    (47403, 0, 2, 11, 90981),
    (47403, 0, 4, 11, 90982),
    (47404, 0, 2, 11, 90981),
    (47404, 0, 4, 11, 90982),
    (48278, 0, 14, 11, 91039),
    (48278, 0, 15, 11, 91039),
    (48417, 0, 14, 11, 90947),
    (48418, 0, 14, 11, 91006),
    (48419, 0, 1, 11, 91010),
    (53619, 0, 10, 34, 100101),
    (70021, 0, 1, 11, 223971),
    (70034, 0, 0, 11, 215377)
);
