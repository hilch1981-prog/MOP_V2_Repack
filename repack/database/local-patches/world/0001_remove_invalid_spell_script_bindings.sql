-- Pandaria 5.4.8 (18414) local compatibility fixes.
-- Keep valid primary spell bindings and remove only obsolete or unrelated rows.

DELETE FROM `spell_script_names`
WHERE (`ScriptName` = 'spell_rog_vanish' AND `spell_id` = 18461)
   OR (`ScriptName` = 'spell_mage_mirror_image' AND `spell_id` IN (63093, 88091, 88092))
   OR (`ScriptName` IN ('spell_mage_incanters_absorbtion_absorb', 'spell_mage_incanters_absorbtion_manashield'))
   OR (`ScriptName` = 'spell_gen_replenishment' AND `spell_id` = 57669)
   OR (`ScriptName` = 'spell_pal_divine_storm' AND `spell_id` = 53385)
   OR (`ScriptName` = 'spell_warr_last_stand' AND `spell_id` = 12975);

-- Build 18414 already defines these class buffs as direct area-aura effects.
-- The legacy conversion scripts expect an obsolete dummy effect and can never run.
DELETE FROM `spell_script_names`
WHERE (`spell_id`, `ScriptName`) IN
(
    (1126,  'spell_dru_mark_of_the_wild_stats'),
    (1459,  'spell_mage_arcane_brilliance_stats'),
    (61316, 'spell_mage_dalaran_brilliance'),
    (20217, 'spell_pal_blessing_of_kings'),
    (19740, 'spell_pal_blessing_of_might'),
    (21562, 'spell_pri_power_word_fortitude_stats')
);

-- 20243 is Devastate in build 18414, not the Sword and Board proc aura.
-- Keep the valid 46953 binding.
DELETE FROM `spell_script_names`
WHERE `spell_id` = 20243
  AND `ScriptName` = 'spell_warr_sword_and_board';

-- These exact rows are attached to a non-area spell or to the triggered heal
-- instead of the valid aura driver, so their registered hooks cannot run.
DELETE FROM `spell_script_names`
WHERE (`spell_id`, `ScriptName`) IN
(
    (23218,  'spell_dru_shapeshift_move_speed'),
    (115399, 'spell_monk_healing_elixirs'),
    (69409,  'spell_dk_soul_reaper')
);
