-- Keep the Battle Pay balance page Korean even when the client falls back to
-- the base product/entry strings instead of the koKR locale row.
SET NAMES utf8mb4;

-- The default trainer option can fall back to the base row on some 5.4.8
-- sessions.  Keep both the base and koKR rows Korean for Varzok/Audrey and
-- every other NPC that uses the shared trainer gossip option.
UPDATE `gossip_menu_option`
SET `option_text`='훈련을 받고 싶습니다.'
WHERE `menu_id`=0 AND `id`=3;

INSERT INTO `gossip_menu_option_locale` (`MenuID`,`OptionID`,`Locale`,`OptionText`,`BoxText`)
VALUES (0,3,'koKR','훈련을 받고 싶습니다.','')
ON DUPLICATE KEY UPDATE `OptionText`=VALUES(`OptionText`),`BoxText`=VALUES(`BoxText`);

UPDATE `gossip_menu_option`
SET `option_text`='전투 애완동물 훈련에 관심이 있습니다.'
WHERE `menu_id`=14991 AND `id`=0;

INSERT INTO `gossip_menu_option_locale` (`MenuID`,`OptionID`,`Locale`,`OptionText`,`BoxText`)
VALUES (14991,0,'koKR','전투 애완동물 훈련에 관심이 있습니다.','')
ON DUPLICATE KEY UPDATE `OptionText`=VALUES(`OptionText`),`BoxText`=VALUES(`BoxText`);

UPDATE `battle_pay_group`
SET `name`='잔액'
WHERE `id`=13;

INSERT INTO `battle_pay_group_locale` (`ID`,`Locale`,`Name`)
VALUES (13,'koKR','잔액')
ON DUPLICATE KEY UPDATE `Name`=VALUES(`Name`);

UPDATE `battle_pay_product`
SET `title`='배틀코인 잔액',
    `description`='현재 배틀코인 잔액:\n\n{BALANCE}',
    `price`=0,
    `discount`=0
WHERE `id`=10000;

INSERT INTO `battle_pay_product_locale` (`ID`,`Locale`,`Title`,`Description`)
VALUES (10000,'koKR','배틀코인 잔액','현재 배틀코인 잔액:\n\n{BALANCE}')
ON DUPLICATE KEY UPDATE
  `Title`=VALUES(`Title`),
  `Description`=VALUES(`Description`);

UPDATE `battle_pay_entry`
SET `title`='배틀코인 잔액',
    `description`='이 계정에서 사용할 수 있는 배틀코인 잔액입니다.'
WHERE `id`=10000;

INSERT INTO `battle_pay_entry_locale` (`ID`,`Locale`,`Title`,`Description`)
VALUES (10000,'koKR','배틀코인 잔액','이 계정에서 사용할 수 있는 배틀코인 잔액입니다.')
ON DUPLICATE KEY UPDATE
  `Title`=VALUES(`Title`),
  `Description`=VALUES(`Description`);
