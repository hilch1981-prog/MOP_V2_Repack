-- Reorganize the complete BattlePay catalog by actual item type and provide
-- useful hover descriptions for every item-backed product.
SET NAMES utf8mb4;

DROP TEMPORARY TABLE IF EXISTS `_bp_catalog`;
CREATE TEMPORARY TABLE `_bp_catalog` (
  `entryId` INT UNSIGNED NOT NULL PRIMARY KEY,
  `productId` INT UNSIGNED NOT NULL,
  `itemId` INT UNSIGNED NOT NULL,
  `newGroupId` INT UNSIGNED NOT NULL,
  `baseName` VARCHAR(255) NOT NULL,
  `koName` VARCHAR(255) NOT NULL,
  `baseItemDescription` VARCHAR(255) NOT NULL,
  `koItemDescription` VARCHAR(255) NOT NULL,
  `class` TINYINT UNSIGNED NOT NULL,
  `subclass` TINYINT UNSIGNED NOT NULL,
  `inventoryType` TINYINT UNSIGNED NOT NULL,
  `quality` TINYINT UNSIGNED NOT NULL,
  `itemLevel` SMALLINT UNSIGNED NOT NULL,
  `requiredLevel` TINYINT UNSIGNED NOT NULL,
  `containerSlots` TINYINT UNSIGNED NOT NULL,
  `oldBaseDescription` VARCHAR(500) NOT NULL,
  `oldKoDescription` VARCHAR(500) NOT NULL
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO `_bp_catalog`
  (`entryId`,`productId`,`itemId`,`newGroupId`,`baseName`,`koName`,
   `baseItemDescription`,`koItemDescription`,`class`,`subclass`,`inventoryType`,
   `quality`,`itemLevel`,`requiredLevel`,`containerSlots`,`oldBaseDescription`,`oldKoDescription`)
SELECT
  e.`id`, e.`productId`, pi.`itemId`,
  CASE
    WHEN e.`groupId` IN (7,8,9,10,11) THEN e.`groupId`
    WHEN i.`class` = 15 AND i.`subclass` = 5 THEN 2
    WHEN i.`class` = 15 AND i.`subclass` = 2 THEN 4
    WHEN i.`class` = 1 THEN 3
    WHEN i.`class` = 2 THEN 5
    WHEN i.`class` = 4 AND i.`InventoryType` IN (2,11,12,16) THEN 12
    WHEN i.`class` = 4 THEN 6
    ELSE 8
  END,
  i.`name`, COALESCE(NULLIF(il.`Name`,''), NULLIF(el.`Title`,''), i.`name`),
  COALESCE(i.`description`,''), COALESCE(NULLIF(il.`Description`,''), i.`description`,''),
  i.`class`, i.`subclass`, i.`InventoryType`, i.`Quality`, i.`ItemLevel`,
  i.`RequiredLevel`, i.`ContainerSlots`, e.`description`,
  COALESCE(el.`Description`, e.`description`)
FROM `battle_pay_entry` e
JOIN `battle_pay_product_items` pi ON pi.`productId` = e.`productId`
JOIN `item_template` i ON i.`entry` = pi.`itemId`
LEFT JOIN `item_template_locale` il
  ON il.`ID` = i.`entry` AND il.`locale` = 'koKR'
LEFT JOIN `battle_pay_entry_locale` el
  ON el.`ID` = e.`id` AND el.`Locale` = 'koKR';

DROP TEMPORARY TABLE IF EXISTS `_bp_stats`;
CREATE TEMPORARY TABLE `_bp_stats` (
  `entryId` INT UNSIGNED NOT NULL PRIMARY KEY,
  `statsEn` VARCHAR(500) NOT NULL,
  `statsKo` VARCHAR(500) NOT NULL
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO `_bp_stats` (`entryId`,`statsEn`,`statsKo`)
SELECT
  s.`entryId`,
  GROUP_CONCAT(CONCAT('+',s.`statValue`,' ',
    CASE s.`statType`
      WHEN 0 THEN 'Mana' WHEN 1 THEN 'Health' WHEN 3 THEN 'Agility'
      WHEN 4 THEN 'Strength' WHEN 5 THEN 'Intellect' WHEN 6 THEN 'Spirit'
      WHEN 7 THEN 'Stamina' WHEN 12 THEN 'Defense rating' WHEN 13 THEN 'Dodge rating'
      WHEN 14 THEN 'Parry rating' WHEN 15 THEN 'Block rating' WHEN 31 THEN 'Hit rating'
      WHEN 32 THEN 'Critical strike rating' WHEN 35 THEN 'Resilience rating'
      WHEN 36 THEN 'Haste rating' WHEN 37 THEN 'Expertise rating'
      WHEN 38 THEN 'Attack power' WHEN 39 THEN 'Ranged attack power'
      WHEN 43 THEN 'Mana regeneration' WHEN 45 THEN 'Spell power'
      WHEN 49 THEN 'Mastery rating' WHEN 50 THEN 'Armor' WHEN 51 THEN 'Fire resistance'
      WHEN 52 THEN 'Frost resistance' WHEN 53 THEN 'Holy resistance'
      WHEN 54 THEN 'Shadow resistance' WHEN 55 THEN 'Nature resistance'
      WHEN 56 THEN 'Arcane resistance' WHEN 57 THEN 'PvP power'
      ELSE CONCAT('Stat ',s.`statType`)
    END) ORDER BY s.`slotNo` SEPARATOR ', '),
  GROUP_CONCAT(CONCAT(
    CASE s.`statType`
      WHEN 0 THEN '마나' WHEN 1 THEN '생명력' WHEN 3 THEN '민첩성'
      WHEN 4 THEN '힘' WHEN 5 THEN '지능' WHEN 6 THEN '정신력'
      WHEN 7 THEN '체력' WHEN 12 THEN '방어 숙련도' WHEN 13 THEN '회피 숙련도'
      WHEN 14 THEN '무기 막기 숙련도' WHEN 15 THEN '방패 막기 숙련도' WHEN 31 THEN '적중도'
      WHEN 32 THEN '치명타 및 극대화도' WHEN 35 THEN '탄력도'
      WHEN 36 THEN '가속도' WHEN 37 THEN '숙련도'
      WHEN 38 THEN '전투력' WHEN 39 THEN '원거리 전투력'
      WHEN 43 THEN '마나 회복' WHEN 45 THEN '주문력'
      WHEN 49 THEN '특화도' WHEN 50 THEN '방어도' WHEN 51 THEN '화염 저항력'
      WHEN 52 THEN '냉기 저항력' WHEN 53 THEN '신성 저항력'
      WHEN 54 THEN '암흑 저항력' WHEN 55 THEN '자연 저항력'
      WHEN 56 THEN '비전 저항력' WHEN 57 THEN 'PvP 위력'
      ELSE CONCAT('능력치 ',s.`statType`)
    END, ' +', s.`statValue`) ORDER BY s.`slotNo` SEPARATOR ', ')
FROM (
  SELECT c.`entryId`, n.`slotNo`,
    CASE n.`slotNo`
      WHEN 1 THEN i.`stat_type1` WHEN 2 THEN i.`stat_type2`
      WHEN 3 THEN i.`stat_type3` WHEN 4 THEN i.`stat_type4`
      WHEN 5 THEN i.`stat_type5` WHEN 6 THEN i.`stat_type6`
      WHEN 7 THEN i.`stat_type7` WHEN 8 THEN i.`stat_type8`
      WHEN 9 THEN i.`stat_type9` WHEN 10 THEN i.`stat_type10`
    END `statType`,
    CASE n.`slotNo`
      WHEN 1 THEN i.`stat_value1` WHEN 2 THEN i.`stat_value2`
      WHEN 3 THEN i.`stat_value3` WHEN 4 THEN i.`stat_value4`
      WHEN 5 THEN i.`stat_value5` WHEN 6 THEN i.`stat_value6`
      WHEN 7 THEN i.`stat_value7` WHEN 8 THEN i.`stat_value8`
      WHEN 9 THEN i.`stat_value9` WHEN 10 THEN i.`stat_value10`
    END `statValue`
  FROM `_bp_catalog` c
  JOIN `item_template` i ON i.`entry`=c.`itemId`
  CROSS JOIN (
    SELECT 1 `slotNo` UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  ) n
) s
WHERE s.`statValue`<>0
GROUP BY s.`entryId`;

-- Keep twelve compact categories so the 5.4.8 left menu does not overflow.
UPDATE `battle_pay_group` SET `idx`=0,  `name`='Balance',     `type`=1 WHERE `id`=13;
UPDATE `battle_pay_group` SET `idx`=1,  `name`='Weapons',     `type`=0 WHERE `id`=5;
UPDATE `battle_pay_group` SET `idx`=2,  `name`='Armor',       `type`=0 WHERE `id`=6;
UPDATE `battle_pay_group` SET `idx`=3,  `name`='Accessories', `type`=0 WHERE `id`=12;
UPDATE `battle_pay_group` SET `idx`=4,  `name`='Mounts',      `type`=0 WHERE `id`=2;
UPDATE `battle_pay_group` SET `idx`=5,  `name`='Battle Pets', `type`=0 WHERE `id`=4;
UPDATE `battle_pay_group` SET `idx`=6,  `name`='Bags',        `type`=0 WHERE `id`=3;
UPDATE `battle_pay_group` SET `idx`=7,  `name`='Toys',        `type`=0 WHERE `id`=8;
UPDATE `battle_pay_group` SET `idx`=8,  `name`='Boosts',      `type`=0 WHERE `id`=7;
UPDATE `battle_pay_group` SET `idx`=9,  `name`='Gold',        `type`=0 WHERE `id`=9;
UPDATE `battle_pay_group` SET `idx`=10, `name`='Currencies',  `type`=0 WHERE `id`=10;
UPDATE `battle_pay_group` SET `idx`=11, `name`='Services',    `type`=0 WHERE `id`=11;

INSERT INTO `battle_pay_group_locale` (`ID`,`Locale`,`Name`) VALUES
  (13,'koKR','잔액'),
  (5,'koKR','무기'),
  (6,'koKR','방어구'),
  (12,'koKR','장신구·망토'),
  (2,'koKR','탈것'),
  (4,'koKR','전투 애완동물'),
  (3,'koKR','가방'),
  (8,'koKR','장난감'),
  (7,'koKR','소모품·강화'),
  (9,'koKR','골드'),
  (10,'koKR','화폐·토큰'),
  (11,'koKR','캐릭터 서비스')
ON DUPLICATE KEY UPDATE `Name`=VALUES(`Name`);

UPDATE `battle_pay_entry` e
JOIN `_bp_catalog` c ON c.`entryId`=e.`id`
SET e.`groupId`=c.`newGroupId`;

DROP TEMPORARY TABLE IF EXISTS `_bp_descriptions`;
CREATE TEMPORARY TABLE `_bp_descriptions` (
  `entryId` INT UNSIGNED NOT NULL PRIMARY KEY,
  `baseDescription` VARCHAR(500) NOT NULL,
  `koDescription` VARCHAR(500) NOT NULL
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO `_bp_descriptions` (`entryId`,`baseDescription`,`koDescription`)
SELECT c.`entryId`,
  LEFT(CASE c.`newGroupId`
    WHEN 2 THEN CONCAT(IF(c.`subclass`=5,'Mount. ','Mount item. '),
      'Use this item to learn the mount.', IF(c.`baseItemDescription`<>'',CONCAT('\n',c.`baseItemDescription`),''))
    WHEN 4 THEN CONCAT('Battle pet. Use this item to add the pet to your journal.',
      IF(c.`baseItemDescription`<>'',CONCAT('\n',c.`baseItemDescription`),''))
    WHEN 3 THEN CONCAT(c.`containerSlots`,'-slot bag.',
      IF(c.`baseItemDescription`<>'',CONCAT('\n',c.`baseItemDescription`),''))
    WHEN 8 THEN CONCAT('Toy item.',IF(c.`baseItemDescription`<>'',CONCAT('\n',c.`baseItemDescription`),''))
    WHEN 5 THEN CONCAT(
      CASE c.`inventoryType` WHEN 13 THEN 'One-hand weapon' WHEN 15 THEN 'Ranged weapon'
        WHEN 17 THEN 'Two-hand weapon' WHEN 21 THEN 'Main-hand weapon'
        WHEN 22 THEN 'Off-hand weapon' WHEN 26 THEN 'Ranged weapon' ELSE 'Weapon' END,
      IF(c.`quality`=7,'. Heirloom: stats scale with character level.',
        CONCAT('.',IF(c.`itemLevel`>1,CONCAT('\nItem level ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\nRequires level ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsEn`,'')<>'',CONCAT('\n',s.`statsEn`),''))))
    WHEN 6 THEN CONCAT(
      CASE c.`inventoryType` WHEN 1 THEN 'Head armor' WHEN 3 THEN 'Shoulder armor'
        WHEN 5 THEN 'Chest armor' WHEN 7 THEN 'Leg armor' WHEN 20 THEN 'Robe' ELSE 'Armor' END,
      IF(c.`quality`=7,'. Heirloom: stats scale with character level.',
        CONCAT('.',IF(c.`itemLevel`>1,CONCAT('\nItem level ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\nRequires level ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsEn`,'')<>'',CONCAT('\n',s.`statsEn`),''))))
    WHEN 12 THEN CONCAT(
      CASE c.`inventoryType` WHEN 2 THEN 'Neck' WHEN 11 THEN 'Ring'
        WHEN 12 THEN 'Trinket' WHEN 16 THEN 'Cloak' ELSE 'Accessory' END,
      IF(c.`quality`=7,'. Heirloom: stats scale with character level.',
        CONCAT('.',IF(c.`itemLevel`>1,CONCAT('\nItem level ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\nRequires level ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsEn`,'')<>'',CONCAT('\n',s.`statsEn`),''))))
    WHEN 7 THEN IF(c.`oldBaseDescription` IN ('Purchase with Battle Coins.',''),
      CONCAT('Consumable or boost item.',IF(c.`baseItemDescription`<>'',CONCAT('\n',c.`baseItemDescription`),'')),c.`oldBaseDescription`)
    ELSE c.`oldBaseDescription`
  END,500),
  LEFT(CASE c.`newGroupId`
    WHEN 2 THEN CONCAT(IF(c.`subclass`=5,'탈것입니다. ','탈것 아이템입니다. '),
      '사용 시 계정에 탈것을 배웁니다.',IF(c.`koItemDescription`<>'',CONCAT('\n',c.`koItemDescription`),''))
    WHEN 4 THEN CONCAT('전투 애완동물입니다. 사용 시 애완동물을 배웁니다.',
      IF(c.`koItemDescription`<>'',CONCAT('\n',c.`koItemDescription`),''))
    WHEN 3 THEN IF(c.`oldKoDescription` NOT IN ('Purchase with Battle Coins.','배틀코인으로 구매할 수 있습니다.',''),
      c.`oldKoDescription`,CONCAT(c.`containerSlots`,'칸 가방입니다.',
        IF(c.`koItemDescription`<>'',CONCAT('\n',c.`koItemDescription`),'')))
    WHEN 8 THEN CONCAT('장난감입니다.',IF(c.`koItemDescription`<>'',CONCAT('\n',c.`koItemDescription`),''))
    WHEN 5 THEN CONCAT(
      CASE c.`inventoryType` WHEN 13 THEN '한손 무기' WHEN 15 THEN '원거리 무기'
        WHEN 17 THEN '양손 무기' WHEN 21 THEN '주장비 무기'
        WHEN 22 THEN '보조장비 무기' WHEN 26 THEN '원거리 무기' ELSE '무기' END,
      IF(c.`quality`=7,'입니다. 계승품으로 캐릭터 레벨에 따라 능력치가 증가합니다.',
        CONCAT('입니다.',IF(c.`itemLevel`>1,CONCAT('\n아이템 레벨 ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\n요구 레벨 ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsKo`,'')<>'',CONCAT('\n',s.`statsKo`),''))))
    WHEN 6 THEN CONCAT(
      CASE c.`inventoryType` WHEN 1 THEN '머리 방어구' WHEN 3 THEN '어깨 방어구'
        WHEN 5 THEN '가슴 방어구' WHEN 7 THEN '다리 방어구' WHEN 20 THEN '로브' ELSE '방어구' END,
      IF(c.`quality`=7,'입니다. 계승품으로 캐릭터 레벨에 따라 능력치가 증가합니다.',
        CONCAT('입니다.',IF(c.`itemLevel`>1,CONCAT('\n아이템 레벨 ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\n요구 레벨 ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsKo`,'')<>'',CONCAT('\n',s.`statsKo`),''))))
    WHEN 12 THEN CONCAT(
      CASE c.`inventoryType` WHEN 2 THEN '목걸이' WHEN 11 THEN '반지'
        WHEN 12 THEN '장신구' WHEN 16 THEN '망토' ELSE '장신구' END,
      IF(c.`quality`=7,'입니다. 계승품으로 캐릭터 레벨에 따라 능력치가 증가합니다.',
        CONCAT('입니다.',IF(c.`itemLevel`>1,CONCAT('\n아이템 레벨 ',c.`itemLevel`),''),
          IF(c.`requiredLevel`>0,CONCAT('\n요구 레벨 ',c.`requiredLevel`),''),
          IF(COALESCE(s.`statsKo`,'')<>'',CONCAT('\n',s.`statsKo`),''))))
    WHEN 7 THEN IF(c.`oldKoDescription` IN ('Purchase with Battle Coins.','배틀코인으로 구매할 수 있습니다.',''),
      CONCAT('소모품 또는 강화 아이템입니다. 사용하면 아이템 고유 효과가 적용됩니다.',
        IF(c.`koItemDescription`<>'',CONCAT('\n',c.`koItemDescription`),'')),c.`oldKoDescription`)
    ELSE c.`oldKoDescription`
  END,500)
FROM `_bp_catalog` c
LEFT JOIN `_bp_stats` s ON s.`entryId`=c.`entryId`;

UPDATE `battle_pay_entry` e
JOIN `_bp_catalog` c ON c.`entryId`=e.`id`
JOIN `_bp_descriptions` d ON d.`entryId`=e.`id`
SET e.`title`=c.`baseName`, e.`description`=d.`baseDescription`;

UPDATE `battle_pay_product` p
JOIN `_bp_catalog` c ON c.`productId`=p.`id`
JOIN `_bp_descriptions` d ON d.`entryId`=c.`entryId`
SET p.`title`=c.`baseName`, p.`description`=d.`baseDescription`;

INSERT INTO `battle_pay_entry_locale` (`ID`,`Locale`,`Title`,`Description`)
SELECT c.`entryId`,'koKR',c.`koName`,d.`koDescription`
FROM `_bp_catalog` c JOIN `_bp_descriptions` d ON d.`entryId`=c.`entryId`
ON DUPLICATE KEY UPDATE `Title`=VALUES(`Title`),`Description`=VALUES(`Description`);

INSERT INTO `battle_pay_product_locale` (`ID`,`Locale`,`Title`,`Description`)
SELECT c.`productId`,'koKR',c.`koName`,d.`koDescription`
FROM `_bp_catalog` c JOIN `_bp_descriptions` d ON d.`entryId`=c.`entryId`
ON DUPLICATE KEY UPDATE `Title`=VALUES(`Title`),`Description`=VALUES(`Description`);

-- This bag has no koKR item_template_locale row in the bundled database.
-- Preserve its established Korean store name explicitly.
UPDATE `battle_pay_entry_locale`
SET `Title`='포로르의 무한 저항 장비 보관함'
WHERE `ID`=13 AND `Locale`='koKR';
UPDATE `battle_pay_product_locale`
SET `Title`='포로르의 무한 저항 장비 보관함'
WHERE `ID`=13 AND `Locale`='koKR';

-- Rebuild a deterministic item-by-item order inside the newly assigned groups.
DROP TEMPORARY TABLE IF EXISTS `_bp_order`;
CREATE TEMPORARY TABLE `_bp_order` (
  `seq` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `entryId` INT UNSIGNED NOT NULL UNIQUE
);
INSERT INTO `_bp_order` (`entryId`)
SELECT e.`id`
FROM `battle_pay_entry` e
JOIN `battle_pay_group` g ON g.`id`=e.`groupId`
LEFT JOIN `battle_pay_product_items` pi ON pi.`productId`=e.`productId`
LEFT JOIN `item_template` i ON i.`entry`=pi.`itemId`
LEFT JOIN `battle_pay_entry_locale` el ON el.`ID`=e.`id` AND el.`Locale`='koKR'
ORDER BY g.`idx`, e.`groupId`, COALESCE(i.`InventoryType`,0),
         COALESCE(i.`subclass`,0), COALESCE(i.`ItemLevel`,0) DESC,
         COALESCE(el.`Title`,e.`title`), e.`id`;

UPDATE `battle_pay_entry` e
JOIN `_bp_order` o ON o.`entryId`=e.`id`
SET e.`idx`=o.`seq`-1;

-- Remove stale locale rows that no longer have a matching store group.
-- The bundled database can retain legacy group ID 1 although active groups are 2-13.
DELETE gl
FROM `battle_pay_group_locale` gl
LEFT JOIN `battle_pay_group` g ON g.`id`=gl.`ID`
WHERE g.`id` IS NULL;

DROP TEMPORARY TABLE IF EXISTS `_bp_order`;
DROP TEMPORARY TABLE IF EXISTS `_bp_descriptions`;
DROP TEMPORARY TABLE IF EXISTS `_bp_stats`;
DROP TEMPORARY TABLE IF EXISTS `_bp_catalog`;
