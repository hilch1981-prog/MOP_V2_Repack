-- 18414 spell validation cleanup confirmed against the current DBC and SkyFire core.

-- These legacy Incanter's Absorption handlers expect absorb/mana-shield effects
-- that the bound MoP spells do not have. SkyFire no longer registers them.
DELETE FROM `spell_script_names`
WHERE `ScriptName` IN
(
    'spell_mage_incanters_absorbtion_absorb',
    'spell_mage_incanters_absorbtion_manashield'
);
