-- DB 업데이트 후 배틀 상점의 공식 koKR 명칭과 서비스 예외를 복원합니다.
SET NAMES utf8mb4;

UPDATE `battle_pay_product_locale` AS p
JOIN (
    SELECT `productId`,MAX(`itemId`) AS `itemId`
    FROM `battle_pay_product_items`
    GROUP BY `productId`
    HAVING COUNT(DISTINCT `itemId`)=1
) AS x ON x.`productId`=p.`ID`
JOIN `item_template_locale` AS i
  ON i.`ID`=x.`itemId` AND i.`locale`='koKR' AND i.`Name`<>''
SET p.`Title`=i.`Name`
WHERE p.`Locale`='koKR';

UPDATE `battle_pay_product_locale`
SET `Title`=CASE `ID`
        WHEN 1 THEN '배틀코인 1개'
        WHEN 2 THEN '배틀코인 2개'
        WHEN 3 THEN '배틀코인 5개'
        WHEN 4 THEN '배틀코인 10개'
        WHEN 83 THEN '캐릭터 승급'
        ELSE `Title`
    END,
    `Description`=CASE `ID`
        WHEN 1 THEN '배틀코인 1개를 지급합니다.'
        WHEN 2 THEN '배틀코인 2개를 지급합니다.'
        WHEN 3 THEN '배틀코인 5개를 지급합니다.'
        WHEN 4 THEN '배틀코인 10개를 지급합니다.'
        ELSE `Description`
    END
WHERE `Locale`='koKR' AND `ID` IN (1,2,3,4,83);

INSERT INTO `battle_pay_entry_locale` (`ID`,`Locale`,`Title`,`Description`)
SELECT e.`id`,'koKR',p.`Title`,p.`Description`
FROM `battle_pay_entry` AS e
JOIN `battle_pay_product_locale` AS p
  ON p.`ID`=e.`productId` AND p.`Locale`='koKR'
ON DUPLICATE KEY UPDATE
  `Title`=VALUES(`Title`),`Description`=VALUES(`Description`);
