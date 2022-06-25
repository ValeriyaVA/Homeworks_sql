-- 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

USE vk;
SELECT
	m.from_user_id,
	COUNT(m.from_user_id) AS number_messages
FROM messages AS m
JOIN
	friend_requests fr ON (fr.target_user_id = 1 OR fr.initiator_user_id = 1) AND fr.status = 'approved' AND m.to_user_id = 1 AND (m.from_user_id = fr.initiator_user_id OR m.from_user_id = fr.target_user_id)
GROUP BY m.from_user_id
ORDER BY number_messages DESC
LIMIT 1;

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT
	COUNT(*) AS 'number_likes',
	gender
FROM profiles p
JOIN
	likes l ON l.user_id = p.user_id
GROUP BY gender;

