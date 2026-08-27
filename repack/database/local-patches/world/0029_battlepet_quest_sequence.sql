-- Battle-pet quest progression repair for MoP 5.4.8.
-- Keeps the faction tutorial linear, opens the two Azeroth circuits after
-- A Tamer's Homecoming, and then unlocks later continents in order.
-- Idempotent: safe to apply repeatedly.

-- Quest 31902 (Alliance Eastern Kingdoms circuit) is absent from the base
-- quest_template although its localized client strings are present.  Rebuild
-- it from the Horde twin, then restore the faction and chain fields.
DROP TEMPORARY TABLE IF EXISTS `_battlepet_quest_31902`;
CREATE TEMPORARY TABLE `_battlepet_quest_31902` LIKE `quest_template`;
INSERT INTO `_battlepet_quest_31902`
SELECT * FROM `quest_template` WHERE `Id` = 31903;
UPDATE `_battlepet_quest_31902`
SET `Id` = 31902,
    `RequiredRaces` = 18875469,
    `PrevQuestId` = 31917,
    `NextQuestId` = 31915,
    `ExclusiveGroup` = 0,
    `Title` = 'Battle Pet Tamers: Eastern Kingdoms';
REPLACE INTO `quest_template`
SELECT * FROM `_battlepet_quest_31902`;
DROP TEMPORARY TABLE `_battlepet_quest_31902`;

-- Native objective IDs immediately preceding the Horde twin's IDs.
DELETE FROM `quest_objective` WHERE `questId` = 31902;
INSERT INTO `quest_objective`
    (`questId`,`id`,`index`,`type`,`objectId`,`amount`,`flags`,`description`)
VALUES
    (31902,269176,5,11,66478,1,0,'Defeat David Kosse'),
    (31902,269177,6,11,66512,1,0,'Defeat Deiza Plaguehorn'),
    (31902,269178,7,11,66515,1,0,'Defeat Kortas Darkhammer'),
    (31902,269179,8,11,66518,1,0,'Defeat Everessa'),
    (31902,269180,9,11,66520,1,0,'Defeat Durin Darkhammer');

-- Keep the legacy locale table complete for tools that still inspect it.
DROP TEMPORARY TABLE IF EXISTS `_battlepet_locale_31902`;
CREATE TEMPORARY TABLE `_battlepet_locale_31902` LIKE `locales_quest`;
INSERT INTO `_battlepet_locale_31902`
SELECT * FROM `locales_quest` WHERE `Id` = 31903;
UPDATE `_battlepet_locale_31902`
SET `Id` = 31902,
    `Title_loc1` = '전투 애완동물 조련사: 동부 왕국',
    `Objectives_loc1` = '애완동물 대전에서 데이비드 코세, 데이자 플레이그혼, 코르타스 다크해머, 에버레사, 두린 다크해머를 꺾어야 합니다.',
    `Details_loc1` = '기술을 갈고닦았으니 이제 애완동물 대전의 세계를 만끽할 준비가 되었군요.$B$B동부 왕국에는 당신이 상대해줬으면 하는 조련사 다섯 명이 있어요. 동부 내륙지의 데이비드 코세, 동부 역병지대의 데이자 플레이그혼, 이글거리는 협곡의 코르타스 다크해머, 슬픔의 늪의 에버레사, 그리고 불타는 평원의 두린 다크해머를 찾아가세요.$B$B그들을 이길 수 있다면 한 발 더 나갈 준비가 된 거예요.';
REPLACE INTO `locales_quest`
SELECT * FROM `_battlepet_locale_31902`;
DROP TEMPORARY TABLE `_battlepet_locale_31902`;

INSERT INTO `quest_template_locale`
    (`ID`,`locale`,`Title`,`Details`,`Objectives`,`EndText`,`CompletedText`,
     `QuestGiverTextWindow`,`QuestGiverTargetName`,`QuestTurnTextWindow`,
     `QuestTurnTargetName`,`VerifiedBuild`)
VALUES
    (31902,'koKR','전투 애완동물 조련사: 동부 왕국',
     '기술을 갈고닦았으니 이제 애완동물 대전의 세계를 만끽할 준비가 되었군요.$B$B동부 왕국에는 당신이 상대해줬으면 하는 조련사 다섯 명이 있어요. 동부 내륙지의 데이비드 코세, 동부 역병지대의 데이자 플레이그혼, 이글거리는 협곡의 코르타스 다크해머, 슬픔의 늪의 에버레사, 그리고 불타는 평원의 두린 다크해머를 찾아가세요.$B$B그들을 이길 수 있다면 한 발 더 나갈 준비가 된 거예요.',
     '애완동물 대전에서 데이비드 코세, 데이자 플레이그혼, 코르타스 다크해머, 에버레사, 두린 다크해머를 꺾어야 합니다.',
     '','','','','','오드리 번헵',18414)
ON DUPLICATE KEY UPDATE
    `Title`=VALUES(`Title`), `Details`=VALUES(`Details`),
    `Objectives`=VALUES(`Objectives`),
    `QuestTurnTargetName`=VALUES(`QuestTurnTargetName`),
    `VerifiedBuild`=VALUES(`VerifiedBuild`);

INSERT INTO `locales_quest_objective` (`id`,`locale`,`description`) VALUES
    (269176,1,'데이비드 코세 처치'),
    (269177,1,'데이자 플레이그혼 처치'),
    (269178,1,'코르타스 다크해머 처치'),
    (269179,1,'에버레사 처치'),
    (269180,1,'두린 다크해머 처치')
ON DUPLICATE KEY UPDATE `description`=VALUES(`description`);

-- Tutorial: only Learning the Ropes is initially available.  The capital
-- breadcrumb follows Got one!, then the level 2-11 faction tamer circuit.
UPDATE `quest_template` SET `NextQuestId`=32008 WHERE `Id`=31593;
UPDATE `quest_template` SET `PrevQuestId`=31593, `NextQuestId`=31316 WHERE `Id`=32008;
UPDATE `quest_template` SET `NextQuestId`=32009 WHERE `Id`=31590;
UPDATE `quest_template` SET `PrevQuestId`=31590, `NextQuestId`=31812 WHERE `Id`=32009;

-- Both Azeroth circuits unlock after the faction homecoming quest.  Their
-- grand-master quests collect both faction variants through NextQuestId.
UPDATE `quest_template` SET `PrevQuestId`=31917, `NextQuestId`=31897 WHERE `Id`=31889;
UPDATE `quest_template` SET `PrevQuestId`=31918, `NextQuestId`=31897 WHERE `Id`=31891;
UPDATE `quest_template` SET `PrevQuestId`=31918, `NextQuestId`=31915 WHERE `Id`=31903;
UPDATE `quest_template` SET `PrevQuestId`=31891 WHERE `Id`=31897;
UPDATE `quest_template` SET `PrevQuestId`=31903 WHERE `Id`=31915;

-- The Returning Champion has one variant per grand master and faction.  All
-- four share an exclusive group, so the first completed route unlocks the
-- correct faction's Outland quest without displaying both return quests.
UPDATE `quest_template` SET `PrevQuestId`=31897, `NextQuestId`=31919, `ExclusiveGroup`=31975 WHERE `Id`=31975;
UPDATE `quest_template` SET `PrevQuestId`=31915, `NextQuestId`=31919, `ExclusiveGroup`=31975 WHERE `Id`=31976;
UPDATE `quest_template` SET `PrevQuestId`=31897, `NextQuestId`=31921, `ExclusiveGroup`=31975 WHERE `Id`=31977;
UPDATE `quest_template` SET `PrevQuestId`=31915, `NextQuestId`=31921, `ExclusiveGroup`=31975 WHERE `Id`=31980;

-- Later continents are strictly linear: Outland -> Northrend -> Cataclysm
-- -> Pandaria.  Player quest level stays retail-like (1); opponent pet levels
-- already rise from 20 through 25 in battlepet_npc_team_member.
UPDATE `quest_template` SET `PrevQuestId`=31976, `NextQuestId`=31920 WHERE `Id`=31919;
UPDATE `quest_template` SET `PrevQuestId`=31980, `NextQuestId`=31920 WHERE `Id`=31921;
UPDATE `quest_template` SET `PrevQuestId`=31920, `NextQuestId`=31927 WHERE `Id`=31981;
UPDATE `quest_template` SET `PrevQuestId`=31920, `NextQuestId`=31929 WHERE `Id`=31982;
UPDATE `quest_template` SET `PrevQuestId`=31981, `NextQuestId`=31928 WHERE `Id`=31927;
UPDATE `quest_template` SET `PrevQuestId`=31982, `NextQuestId`=31928 WHERE `Id`=31929;
UPDATE `quest_template` SET `PrevQuestId`=31928, `NextQuestId`=31967 WHERE `Id`=31983;
UPDATE `quest_template` SET `PrevQuestId`=31928, `NextQuestId`=31966 WHERE `Id`=31984;
UPDATE `quest_template` SET `PrevQuestId`=31984, `NextQuestId`=31970 WHERE `Id`=31966;
UPDATE `quest_template` SET `PrevQuestId`=31983, `NextQuestId`=31970 WHERE `Id`=31967;
UPDATE `quest_template` SET `PrevQuestId`=31970, `NextQuestId`=31930 WHERE `Id`=31985;
UPDATE `quest_template` SET `PrevQuestId`=31970, `NextQuestId`=31952 WHERE `Id`=31986;
UPDATE `quest_template` SET `PrevQuestId`=31985, `NextQuestId`=31951 WHERE `Id`=31930;
UPDATE `quest_template` SET `PrevQuestId`=31986, `NextQuestId`=31951 WHERE `Id`=31952;

-- The level-25 PvP weekly is an endgame follow-up, not a starter quest.
UPDATE `quest_template` SET `PrevQuestId`=31951 WHERE `Id`=32863;

-- Missing quest-giver links that are required to finish both branches.
INSERT IGNORE INTO `creature_queststarter` (`id`,`quest`) VALUES
    (63596,31902),
    (66466,31975),
    (66824,31970),(66824,31971),(66824,31985),(66824,31986);

INSERT IGNORE INTO `creature_questender` (`id`,`quest`) VALUES
    (66824,31970),(66824,31971);

