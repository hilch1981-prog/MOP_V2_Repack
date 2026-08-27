-- Emucoach BattlePay 카탈로그 중 Pandaria에 없는 호환 상품을 추가합니다.
-- 실제 지급 아이템이 현재 world.item_template에 존재하는 경우에만 상품을 만듭니다.
-- 기존 상품 ID와 충돌하지 않도록 상품/항목 ID는 200000 + itemId를 사용합니다.

DROP TEMPORARY TABLE IF EXISTS `_emucoach_battlepay_import`;
CREATE TEMPORARY TABLE `_emucoach_battlepay_import` (
  `itemId` INT UNSIGNED NOT NULL PRIMARY KEY,
  `groupId` INT UNSIGNED NOT NULL,
  `price` INT UNSIGNED NOT NULL,
  `icon` INT UNSIGNED NOT NULL,
  `displayId` INT UNSIGNED NOT NULL DEFAULT 0,
  `count` INT UNSIGNED NOT NULL DEFAULT 1
);

INSERT INTO `_emucoach_battlepay_import` (`itemId`, `groupId`, `price`, `icon`, `displayId`, `count`) VALUES
  (49912, 4, 50, 913566, 38484, 1),
  (42943, 12, 62, 135275, 0, 1),
  (42946, 12, 62, 135490, 0, 1),
  (42947, 12, 62, 135275, 0, 1),
  (42949, 12, 62, 133076, 0, 1),
  (42950, 12, 62, 133076, 0, 1),
  (42951, 12, 62, 133076, 0, 1),
  (42952, 12, 62, 133076, 0, 1),
  (42984, 12, 62, 133076, 0, 1),
  (42985, 12, 62, 133076, 0, 1),
  (44091, 12, 62, 135346, 0, 1),
  (48677, 12, 62, 133112, 0, 1),
  (48683, 12, 62, 133112, 0, 1),
  (48685, 12, 62, 133112, 0, 1),
  (48687, 12, 62, 133112, 0, 1),
  (48689, 12, 62, 133112, 0, 1),
  (48691, 12, 62, 133112, 0, 1),
  (61931, 12, 62, 133110, 0, 1),
  (61935, 12, 62, 133110, 0, 1),
  (61936, 12, 62, 133110, 0, 1),
  (61937, 12, 62, 133110, 0, 1),
  (61942, 12, 62, 133110, 0, 1),
  (61958, 12, 62, 133110, 0, 1),
  (62023, 12, 62, 133111, 0, 1),
  (62024, 12, 62, 133111, 0, 1),
  (62025, 12, 62, 133111, 0, 1),
  (62026, 12, 62, 133111, 0, 1),
  (62027, 12, 62, 133111, 0, 1),
  (62029, 12, 62, 133111, 0, 1),
  (69887, 12, 62, 133110, 0, 1),
  (69888, 12, 62, 133111, 0, 1),
  (69889, 12, 62, 133112, 0, 1),
  (69890, 12, 62, 133076, 0, 1),
  (42944, 12, 62, 135346, 0, 1),
  (44096, 12, 62, 135346, 0, 1),
  (42948, 12, 62, 135346, 0, 1),
  (42992, 12, 62, 133858, 0, 1),
  (50255, 12, 62, 133351, 0, 1),
  (44098, 12, 62, 133858, 0, 1),
  (44097, 12, 62, 133858, 0, 1),
  (44092, 12, 62, 135275, 0, 1),
  (42991, 12, 62, 133858, 0, 1),
  (44094, 12, 62, 135346, 0, 1),
  (44093, 12, 62, 135490, 0, 1),
  (48716, 12, 62, 135346, 0, 1),
  (103557, 7, 7, 236883, 0, 1),
  (19019, 5, 200, 135349, 0, 1),
  (102245, 6, 200, 852265, 0, 1),
  (102246, 6, 200, 852263, 0, 1),
  (102247, 6, 200, 874780, 0, 1),
  (102248, 6, 200, 852267, 0, 1),
  (102249, 6, 200, 852267, 0, 1),
  (102250, 6, 200, 852265, 0, 1);

INSERT INTO `battle_pay_product`
  (`id`, `title`, `description`, `icon`, `price`, `discount`, `displayId`, `type`, `choiceType`, `flags`, `flagsInfo`)
SELECT
  200000 + s.`itemId`, CONCAT('Shop: ', i.`name`), 'Purchase with Battle Coins.',
  s.`icon`, s.`price`, 0, s.`displayId`, 0, 1, 47, 0
FROM `_emucoach_battlepay_import` s
JOIN `item_template` i ON i.`entry` = s.`itemId`
ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`), `description` = VALUES(`description`), `icon` = VALUES(`icon`),
  `price` = VALUES(`price`), `discount` = VALUES(`discount`), `displayId` = VALUES(`displayId`),
  `type` = VALUES(`type`), `choiceType` = VALUES(`choiceType`), `flags` = VALUES(`flags`),
  `flagsInfo` = VALUES(`flagsInfo`);

INSERT INTO `battle_pay_product_items` (`id`, `itemId`, `count`, `productId`)
SELECT 200000 + s.`itemId`, s.`itemId`, s.`count`, 200000 + s.`itemId`
FROM `_emucoach_battlepay_import` s
JOIN `item_template` i ON i.`entry` = s.`itemId`
ON DUPLICATE KEY UPDATE
  `itemId` = VALUES(`itemId`), `count` = VALUES(`count`), `productId` = VALUES(`productId`);

INSERT INTO `battle_pay_entry`
  (`id`, `productId`, `groupId`, `idx`, `title`, `description`, `icon`, `displayId`, `banner`, `flags`)
SELECT
  200000 + s.`itemId`, 200000 + s.`itemId`, s.`groupId`, s.`itemId`,
  i.`name`, 'Purchase with Battle Coins.', s.`icon`, s.`displayId`, 2, 0
FROM `_emucoach_battlepay_import` s
JOIN `item_template` i ON i.`entry` = s.`itemId`
ON DUPLICATE KEY UPDATE
  `productId` = VALUES(`productId`), `groupId` = VALUES(`groupId`), `idx` = VALUES(`idx`),
  `title` = VALUES(`title`), `description` = VALUES(`description`), `icon` = VALUES(`icon`),
  `displayId` = VALUES(`displayId`), `banner` = VALUES(`banner`), `flags` = VALUES(`flags`);

INSERT INTO `battle_pay_product_locale` (`ID`, `Locale`, `Title`, `Description`)
SELECT 200000 + s.`itemId`, 'koKR', l.`Name`, '배틀코인으로 구매하는 상품입니다.'
FROM `_emucoach_battlepay_import` s
JOIN `item_template_locale` l ON l.`ID` = s.`itemId` AND l.`locale` = 'koKR'
ON DUPLICATE KEY UPDATE `Title` = VALUES(`Title`), `Description` = VALUES(`Description`);

INSERT INTO `battle_pay_entry_locale` (`ID`, `Locale`, `Title`, `Description`)
SELECT 200000 + s.`itemId`, 'koKR', l.`Name`, '배틀코인으로 구매하는 상품입니다.'
FROM `_emucoach_battlepay_import` s
JOIN `item_template_locale` l ON l.`ID` = s.`itemId` AND l.`locale` = 'koKR'
ON DUPLICATE KEY UPDATE `Title` = VALUES(`Title`), `Description` = VALUES(`Description`);

DROP TEMPORARY TABLE IF EXISTS `_emucoach_battlepay_import`;

-- 잔액 메뉴를 항상 최상단에 두고, 이전 패치가 만든 추가 분류를 정리합니다.
UPDATE `battle_pay_group` SET `idx` = 0 WHERE `id` = 13;
UPDATE `battle_pay_entry` SET `groupId` = 7 WHERE `productId` = 303557;
UPDATE `battle_pay_entry` SET `groupId` = 5 WHERE `productId` = 219019;
UPDATE `battle_pay_entry` SET `groupId` = 6 WHERE `productId` BETWEEN 302245 AND 302250;
DELETE FROM `battle_pay_group_locale` WHERE `ID` IN (100,101);
DELETE FROM `battle_pay_group` WHERE `id` IN (100,101);

-- 서비스 상품은 실제 지급 아이템이 없습니다. 이전 DB의 더미 아이템 연결을 제거합니다.
DELETE pi
FROM `battle_pay_product_items` pi
JOIN `battle_pay_product` p ON p.`id` = pi.`productId`
WHERE p.`type` = 1;

-- 상품 카드의 한글 이름과 실제 지급되는 아이템의 한글 이름을 일치시킵니다.
UPDATE `battle_pay_product_locale` pl
JOIN `battle_pay_product_items` pi ON pi.`productId` = pl.`ID`
JOIN `item_template_locale` il ON il.`ID` = pi.`itemId` AND il.`locale` = 'koKR'
SET pl.`Title` = il.`Name`
WHERE pl.`Locale` = 'koKR';

UPDATE `battle_pay_entry_locale` el
JOIN `battle_pay_entry` e ON e.`id` = el.`ID`
JOIN `battle_pay_product_items` pi ON pi.`productId` = e.`productId`
JOIN `item_template_locale` il ON il.`ID` = pi.`itemId` AND il.`locale` = 'koKR'
SET el.`Title` = il.`Name`
WHERE el.`Locale` = 'koKR';
