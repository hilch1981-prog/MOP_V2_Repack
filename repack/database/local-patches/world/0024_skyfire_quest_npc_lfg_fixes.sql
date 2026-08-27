-- Selected ProjectSkyfire world-data fixes adapted for the Pandaria 5.4.8 schema.
-- Sources: 2026_08_17_world_01/02, 2026_08_18_world_00,
--          2026_08_20_world_00/02/03/04/06.
-- Idempotent: this local patch is reapplied by Update-Database.ps1.

START TRANSACTION;

-- Northshire: restore the sniffed Blackrock Battle Worg reaction.
-- SkyFire faction_A/faction_H are represented by one faction column in this DB.
UPDATE `creature_template`
SET `faction` = 32, `npcflag` = 0
WHERE `entry` = 49871;

UPDATE `creature_template`
SET `npcflag` = 0
WHERE `entry` = 42940;

DELETE FROM `creature_queststarter`
WHERE `id` = 42940 AND `quest` = 26391;

-- Extinguishing Hope becomes available after Blackrock Invasion is accepted.
UPDATE `quest_template`
SET `PrevQuestId` = -26389
WHERE `Id` = 26391;

-- Missing quest request/reward dialogue.
UPDATE `quest_template`
SET `RequestItemsText` = 'I can see why the Horde hates these little nuisances. Have you taken on Three-Tooth yet?',
    `OfferRewardText` = '...Torn limb from limb!? Well, I\'d almost feel bad but the burning hatred gets in the way. She got what she deserved.$B$B<Corporal Teegan takes the Bramblestaff and snaps it over his knee.>$B$BProblem solved.'
WHERE `Id` = 25027;

UPDATE `quest_template`
SET `RequestItemsText` = 'What is it, $c? This here camp ain\'t fit for sight-seein\'.',
    `OfferRewardText` = 'Hey, you\'re tougher than you look. These terrortooth hides reflect arrows and turn axe-blades - they don\'t go down easy, but their hides are worth their weight in silver in these light-forsaken Barrens. Nice work.'
WHERE `Id` = 25000;

UPDATE `quest_template`
SET `OfferRewardText` = 'Ah, $n! I\'ve been talking you up to the General here. Thank you again for saving my life.'
WHERE `Id` = 25034;

UPDATE `quest_template`
SET `OfferRewardText` = 'Good work. Gaines passed through here not long ago on his way to Northwatch and a warm bath.$B$BThe mission wasn\'t a total loss, though. We\'ve learned a good deal about these quilboar and their leadership structure.$B$BNow we can handle things ... MY way.'
WHERE `Id` = 25022;

UPDATE `quest_template`
SET `OfferRewardText` = 'Orders! Let\'s see what we have here... hah! He wants me to deal with the infestation of rat men. We\'re already in the middle of that, so no real deviation there.$B$BCare to lend a hand?'
WHERE `Id` = 13636;

UPDATE `quest_template`
SET `OfferRewardText` = 'We haven\'t gotten much in the way of reinforcements lately. We can use every pair of hands we can get.'
WHERE `Id` = 28565;

UPDATE `quest_template`
SET `RequestItemsText` = 'Do you have it? Is the poor thing intact?',
    `OfferRewardText` = 'Thank the Makers! It\'s downright pristine. Those orcs couldn\'t figure out the tap-lock, it seems...and couldn\'t hack through the mastercraft work of Ironforge\'s keg-crafters with their crude weapons!'
WHERE `Id` = 25395;

UPDATE `quest_template`
SET `OfferRewardText` = 'That\'ll show \'em!  Nice work!'
WHERE `Id` = 25211;

UPDATE `quest_template`
SET `RequestItemsText` = 'Aye? What\'ve you got for me there?',
    `OfferRewardText` = 'Hah! Nice to see those addlebrained mountaineers knew to hand the ale off to a real man to get the job done.$B$BWelcome to my survey. If you\'re of the mind to help Ironforge by takin\' over the intended jobs of some useless, lazy sods that call themselves dwarves, you\'re in the right place!'
WHERE `Id` = 25770;

UPDATE `quest_template`
SET `OfferRewardText` = 'Stoutfist sent you, eh? He\'s a good captain, runs his men well. Just wish he\'d stop starin\' at my midriff.$B$BDon\'t let me catch you doin\' it either. We\'ve work to take care of here!'
WHERE `Id` = 26980;

-- MOP_Repack has lfg_dungeon_template, but not SkyFire's lfg_entrances table.
INSERT INTO `lfg_dungeon_template`
    (`dungeonId`,`name`,`position_x`,`position_y`,`position_z`,`orientation`,`requiredItemLevel`)
VALUES
    (163,'Scarlet Halls',820.743,607.812,13.6389,0,0),
    (164,'Scarlet Monastery',1124.64,512.467,0.989549,1.5708,0),
    (285,'The Headless Horseman',1124.64,512.467,0.989549,1.5708,0)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `position_x` = VALUES(`position_x`),
    `position_y` = VALUES(`position_y`),
    `position_z` = VALUES(`position_z`),
    `orientation` = VALUES(`orientation`),
    `requiredItemLevel` = VALUES(`requiredItemLevel`);

COMMIT;
