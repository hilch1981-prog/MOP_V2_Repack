-- Prevent deleted or reset AHBot characters from leaking auction returns to
-- newly created characters that later receive the same low GUID.
-- Rows owned by character GUID 0 are valid internal AHBot auctions.

START TRANSACTION;

DELETE ii
FROM `item_instance` AS ii
INNER JOIN `mail_items` AS mi ON mi.`item_guid` = ii.`guid`
LEFT JOIN `characters` AS c ON c.`guid` = mi.`receiver`
WHERE c.`guid` IS NULL;

DELETE mi
FROM `mail_items` AS mi
LEFT JOIN `characters` AS c ON c.`guid` = mi.`receiver`
WHERE c.`guid` IS NULL;

DELETE m
FROM `mail` AS m
LEFT JOIN `characters` AS c ON c.`guid` = m.`receiver`
WHERE c.`guid` IS NULL;

DELETE ii
FROM `item_instance` AS ii
INNER JOIN `auctionhouse` AS a ON a.`itemguid` = ii.`guid`
LEFT JOIN `characters` AS c ON c.`guid` = a.`itemowner`
WHERE a.`itemowner` <> 0
  AND c.`guid` IS NULL;

DELETE a
FROM `auctionhouse` AS a
LEFT JOIN `characters` AS c ON c.`guid` = a.`itemowner`
WHERE a.`itemowner` <> 0
  AND c.`guid` IS NULL;

UPDATE `auctionhouse` AS a
LEFT JOIN `characters` AS c ON c.`guid` = a.`buyguid`
SET a.`buyguid` = 0,
    a.`lastbid` = 0
WHERE a.`buyguid` <> 0
  AND c.`guid` IS NULL;

COMMIT;
