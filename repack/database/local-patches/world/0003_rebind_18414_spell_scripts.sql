-- Rebind driver/trigger spell scripts to the actual build 18414 SpellEffect rows.

-- Rain Dance 124860 triggers missile 124864; the destination selector belongs
-- to the missile effect (EFFECT_0, TARGET_DEST_CASTER_RANDOM).
DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_brawlers_guild_rain_dance'
  AND `spell_id` = 124860;
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES (124864, 'spell_brawlers_guild_rain_dance');

-- Titan Gas 116779 is only the periodic trigger driver. The valid scripts are
-- already connected to its triggered auras 116803 and 118327.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 116779
  AND `ScriptName` IN ('spell_titan_gas', 'spell_titan_gas2');

-- Apparitions 111698 is the periodic trigger aura. 112060 is the triggered
-- absorb spell and must not instantiate the driver AuraScript.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 112060
  AND `ScriptName` = 'spell_shadopan_apparitions';

-- 77827 is the parent discharge driver; directional cone scripts are already
-- connected to 77939, 77942, 77943 and 77944.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 77827
  AND `ScriptName` = 'spell_onyxia_lightning_discharge';

-- Fixate and bombard selectors belong to the triggered area spells.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 123740
  AND `ScriptName` = 'spell_dark_of_night_fixate';
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES
    (123742, 'spell_dark_of_night_fixate'),
    (120202, 'spell_rimok_saboteur_bombard'),
    (117914, 'spell_total_annihilation');
