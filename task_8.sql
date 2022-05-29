-- 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
USE vk;

SELECT
	m.from_user_id,
	COUNT(m.from_user_id) AS number_messages
FROM messages AS m
JOIN
	friend_requests fr ON fr.target_user_id = 1 AND fr.status = 'approved' AND m.to_user_id = 1 AND m.from_user_id = fr.initiator_user_id
GROUP BY m.from_user_id
UNION
SELECT
	m.from_user_id,
	COUNT(m.from_user_id) AS number_messages
FROM messages AS m
JOIN
	friend_requests fr ON fr.initiator_user_id = 1 AND fr.status = 'approved' AND m.to_user_id = 1 AND m.from_user_id = fr.target_user_id
GROUP BY m.from_user_id
ORDER BY number_messages DESC
LIMIT 1;

-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.

SELECT
	COUNT(m.id) AS number_likes
FROM media m
JOIN
	profiles p ON p.user_id = m.user_id
JOIN
	likes l ON l.media_id = m.id
WHERE
	TIMESTAMPDIFF(YEAR, p.birthday, NOW()) < 11;

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
-- это задание я уже делала, продублирую

SELECT
	CASE (p.gender)
		WHEN 'm' THEN 'лайки мужчин'
        WHEN 'f' THEN 'лайки женщин'
        ELSE 'другой'
    END AS gender,
    COUNT(p.gender) AS number_likes
FROM likes l
JOIN profiles p on l.user_id  = p.user_id
WHERE l.media_id IS NOT NULL AND p.gender = 'm'
UNION
SELECT
	CASE (p.gender)
		WHEN 'm' THEN 'лайки мужчин'
    	WHEN 'f' THEN 'лайки женщин'
        ELSE 'другой'
    END AS gender,
    COUNT(p.gender) AS number_likes
FROM likes l
JOIN profiles p on l.user_id  = p.user_id
WHERE l.media_id IS NOT NULL AND p.gender = 'f'
