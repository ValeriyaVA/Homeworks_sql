-- 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
USE vk;

SELECT from_user_id,
	COUNT(from_user_id) as number_messages
FROM messages
  WHERE to_user_id = 1
  GROUP BY from_user_id
  ORDER BY number_messages DESC
 LIMIT 1;

-- потом до меня дошло, что по заданию нужны сообщения от друзей, а не от всех пользователей:

SELECT from_user_id,
	COUNT(from_user_id) as number_messages
FROM messages
  WHERE to_user_id = 1 AND from_user_id IN (
  SELECT initiator_user_id FROM friend_requests WHERE (target_user_id = 1) AND status='approved'
  union
  SELECT target_user_id FROM friend_requests WHERE (initiator_user_id = 1) AND status='approved'
)
  GROUP BY from_user_id
  ORDER BY number_messages DESC
 LIMIT 1;

-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.

SELECT
	COUNT(user_id) AS 'Количество лайков'
FROM likes
	WHERE user_id IN (
	SELECT user_id FROM profiles WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11
	);
-- GROUP BY user_id; <--- не нужно, т.к. считаем общее количество лайков, безотносительно юзеров

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT gender, 
COUNT(user_id) AS 'Количество лайков'
FROM profiles WHERE user_id IN(
	SELECT user_id FROM likes
  )
GROUP BY gender;


