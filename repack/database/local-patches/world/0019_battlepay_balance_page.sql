-- Emucoach-style Battle Pay balance page for the current Pandaria schema.
-- IDs 10000 and group 13 avoid collisions with the bundled catalog.
SET NAMES utf8mb4;

INSERT INTO `battle_pay_group` (`id`,`idx`,`name`,`icon`,`type`)
VALUES (13,13,'Balance',939381,1)
ON DUPLICATE KEY UPDATE
  `idx`=VALUES(`idx`),`name`=VALUES(`name`),`icon`=VALUES(`icon`),`type`=VALUES(`type`);

INSERT INTO `battle_pay_product`
  (`id`,`title`,`description`,`icon`,`price`,`discount`,`displayId`,`type`,`choiceType`,`flags`,`flagsInfo`)
VALUES
  (10000,'Balance','Current Battle Coin balance:\n\n{BALANCE}',939381,0,0,0,0,0,5,0)
ON DUPLICATE KEY UPDATE
  `title`=VALUES(`title`),`description`=VALUES(`description`),`icon`=VALUES(`icon`),
  `price`=VALUES(`price`),`discount`=VALUES(`discount`),`displayId`=VALUES(`displayId`),
  `type`=VALUES(`type`),`choiceType`=VALUES(`choiceType`),`flags`=VALUES(`flags`),`flagsInfo`=VALUES(`flagsInfo`);

INSERT INTO `battle_pay_entry`
  (`id`,`productId`,`groupId`,`idx`,`title`,`description`,`icon`,`displayId`,`banner`,`flags`)
VALUES
  (10000,10000,13,0,'Balance','Check the Battle Coins available on this account.',939381,0,2,0)
ON DUPLICATE KEY UPDATE
  `productId`=VALUES(`productId`),`groupId`=VALUES(`groupId`),`idx`=VALUES(`idx`),
  `title`=VALUES(`title`),`description`=VALUES(`description`),`icon`=VALUES(`icon`),
  `displayId`=VALUES(`displayId`),`banner`=VALUES(`banner`),`flags`=VALUES(`flags`);

INSERT INTO `battle_pay_group_locale` (`ID`,`Locale`,`Name`)
VALUES (13,'koKR','잔액')
ON DUPLICATE KEY UPDATE `Name`=VALUES(`Name`);

INSERT INTO `battle_pay_product_locale` (`ID`,`Locale`,`Title`,`Description`)
VALUES (10000,'koKR','잔액','현재 보유 중인 배틀코인입니다.\n\n{BALANCE}')
ON DUPLICATE KEY UPDATE `Title`=VALUES(`Title`),`Description`=VALUES(`Description`);

INSERT INTO `battle_pay_entry_locale` (`ID`,`Locale`,`Title`,`Description`)
VALUES (10000,'koKR','잔액','이 계정에서 사용할 수 있는 배틀코인을 확인합니다.')
ON DUPLICATE KEY UPDATE `Title`=VALUES(`Title`),`Description`=VALUES(`Description`);
