-- Correct spell_script_names rows by comparing them with build 18414
-- Spell.dbc and SpellEffect.dbc. These are binding corrections, not log filters.

START TRANSACTION;

-- 120124 is Healing Potion. The Crossbow selector is the area-entry dummy
-- spell 120139.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 120124
  AND `ScriptName` = 'spell_crossbow_xin';
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES (120139, 'spell_crossbow_xin');

-- Devastating Arc 117006 already uses its DBC cone dummy plus triggered damage
-- spell 116835. Its obsolete AuraScript expects an aura effect that does not
-- exist in build 18414.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 117006
  AND `ScriptName` = 'spell_devastating_arc';

-- 95247 is the valid Ride Hot Air Balloon aura. 128815 has effect 160 and is
-- unrelated to the AuraScript.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 128815
  AND `ScriptName` = 'spell_grab_air_balloon';

-- Inhale 122852 is already the native stacking aura in this DBC. Its remaining
-- script-effect row has no spell value, so the obsolete script attached to
-- Tempest Slash 122853 must be removed rather than moved.
--
-- Mutate Primordius belongs to Mutation 136178, whose script-effect drives the
-- mutation handler. 136203 is the Living Fluid energize spell.
DELETE FROM `spell_script_names`
WHERE (`spell_id`, `ScriptName`) IN
(
    (122853, 'spell_inhale'),
    (136203, 'spell_mutation_primordius')
);
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES
    (136178, 'spell_mutation_primordius');

COMMIT;
