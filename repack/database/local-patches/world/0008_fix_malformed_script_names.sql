-- Fix two malformed ScriptName values found by the core validator.

UPDATE `creature_template`
SET `ScriptName` = ''
WHERE `entry` = 41027 AND `ScriptName` = '0';

UPDATE `conditions`
SET `ScriptName` = ''
WHERE `ScriptName` = '0';

UPDATE `spell_script_names`
SET `ScriptName` = 'spell_howling_gale_howling_gale'
WHERE `spell_id` = 85084
  AND `ScriptName` = '85084spell_howling_gale_howling_gale';
