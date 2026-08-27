-- Restore high-confidence script bindings whose C++ implementation exists in
-- the current 5.4.8 core under a different registration name.

START TRANSACTION;

UPDATE `gameobject_template`
SET `ScriptName` = 'go_alchemy_bottle_white'
WHERE `ScriptName` = 'go_polyformic_acid_potion';

UPDATE `creature_template`
SET `ScriptName` = 'npc_greenstone_terror'
WHERE `ScriptName` = 'npc_greenstone_belligerent_blossom';

UPDATE `creature_template`
SET `ScriptName` = 'npc_greenstone_cursed_brew'
WHERE `ScriptName` = 'npc_greenstone_cursed_jade';

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_unseen_strike_aura';

INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES (122982, 'spell_unseen_strike');

-- These bindings came from custom/Battle for Azeroth content and point to
-- spell records that do not exist in the 5.4.8 build 18414 client.
DELETE FROM `spell_script_names`
WHERE (`spell_id`, `ScriptName`) IN (
    (100115, 'spell_afd_royale_in_map'),
    (100116, 'spell_afd_royale_leaving_game'),
    (100117, 'spell_afd_royale_drop'),
    (100118, 'spell_afd_royale_out_of_ring_damage_aura'),
    (100119, 'spell_afd_royale_buff_trigger'),
    (100125, 'spell_afd_royale_portal_trigger'),
    (249921, 'spell_ataldazar_soulrend_selector'),
    (250050, 'spell_ataldazar_echoes_of_shadra_selector'),
    (253582, 'spell_ataldazar_fiery_enchant_selector'),
    (257407, 'spell_ataldazar_pursuit')
);

COMMIT;
