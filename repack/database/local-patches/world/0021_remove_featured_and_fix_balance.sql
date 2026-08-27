-- Remove the Featured category and its category-only storefront entries.
-- Product definitions remain available for entries assigned to other groups.
DELETE l
FROM `battle_pay_entry_locale` l
JOIN `battle_pay_entry` e ON e.`id` = l.`ID`
WHERE e.`groupId` = 1;

DELETE FROM `battle_pay_entry` WHERE `groupId` = 1;
DELETE FROM `battle_pay_group_locale` WHERE `ID` = 1;
DELETE FROM `battle_pay_group` WHERE `id` = 1;

-- Keep the remaining menu order contiguous and idempotent.
UPDATE `battle_pay_group`
SET `idx` = CASE `id`
    WHEN 13 THEN 0
    WHEN 2 THEN 1
    WHEN 3 THEN 2
    WHEN 4 THEN 3
    WHEN 5 THEN 4
    WHEN 6 THEN 5
    WHEN 7 THEN 6
    WHEN 8 THEN 7
    WHEN 9 THEN 8
    WHEN 10 THEN 9
    WHEN 11 THEN 10
    WHEN 12 THEN 11
    ELSE `idx`
END
WHERE `id` IN (2,3,4,5,6,7,8,9,10,11,12,13);

-- Keep the balance product dynamic after every upstream DB refresh.
UPDATE `battle_pay_product`
SET `title` = 'Balance',
    `description` = 'Current Battle Coin balance:\n\n{BALANCE}',
    `price` = 0,
    `discount` = 0
WHERE `id` = 10000;

INSERT INTO `battle_pay_product_locale` (`ID`,`Locale`,`Title`,`Description`)
VALUES (10000,'koKR','잔액','현재 보유 중인 배틀코인입니다.\n\n{BALANCE}')
ON DUPLICATE KEY UPDATE
  `Title` = VALUES(`Title`),
  `Description` = VALUES(`Description`);
