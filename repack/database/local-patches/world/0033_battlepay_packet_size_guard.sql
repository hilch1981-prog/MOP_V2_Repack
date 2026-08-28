-- Keep the 5.4.8 BattlePay product-list packet below the legacy packet limit.
-- The client tooltip uses battle_pay_entry.Description.  Product descriptions
-- duplicated the same text and added more than 32 KiB without adding UI detail.

UPDATE `battle_pay_product`
SET `description` = ''
WHERE `description` <> '';

UPDATE `battle_pay_product_locale`
SET `Description` = ''
WHERE `Description` <> '';
