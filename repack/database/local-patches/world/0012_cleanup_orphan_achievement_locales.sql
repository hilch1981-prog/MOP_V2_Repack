-- Locale rows without a base achievement_reward are rejected by ObjectMgr.
-- This also removes stale rows reintroduced by localization imports.

DELETE l
FROM `achievement_reward_locale` AS l
LEFT JOIN `achievement_reward` AS r ON r.`entry` = l.`ID`
WHERE r.`entry` IS NULL;
