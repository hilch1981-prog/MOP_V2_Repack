-- Pandaria 5.4.8 build 18414
-- Restore only bindings whose spell IDs are explicitly confirmed by the core source.
-- Multiple scripts on one spell are intentional.

DELETE FROM `spell_script_names`
WHERE `ScriptName` IN
(
    'spell_pal_blessing_of_kings',
    'spell_pal_blessing_of_might',
    'spell_dru_mark_of_the_wild_stats',
    'spell_pri_power_word_fortitude_stats',
    'spell_mage_arcane_brilliance_stats',
    'spell_mage_dalaran_brilliance',
    'spell_gen_replenishment',
    'spell_gen_deserter',
    'spell_warr_last_stand',
    'spell_pal_divine_storm',
    'spell_warl_haunt'
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(57669, 'spell_gen_replenishment'),
(26013, 'spell_gen_deserter'),
(53385, 'spell_pal_divine_storm'),
(48181, 'spell_warl_haunt');
