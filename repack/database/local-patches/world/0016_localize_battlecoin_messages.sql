-- Korean BattlePay balance and purchase messages.
-- Reapplied automatically after upstream database updates.

UPDATE `trinity_string`
SET `content_loc1`='|cff1eff00현재 배틀코인 잔액:'
WHERE `entry`=15005;

UPDATE `trinity_string`
SET `content_loc1`='구매가 완료되었습니다. 남은 배틀코인:'
WHERE `entry`=15006;

UPDATE `trinity_string`
SET `content_loc1`='배틀코인이 부족합니다.'
WHERE `entry`=15007;
