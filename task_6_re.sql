-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.

SELECT
	COUNT(user_id) AS 'Количество лайков'
FROM likes
	WHERE user_id IN (
	SELECT user_id FROM profiles WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11
	);
-- в итоге данный вариант считал, сколько лайков поставили пользователи младше 11 лет

SELECT
	COUNT(user_id) AS number_likes
FROM likes
WHERE media_id IN (
  SELECT id FROM media WHERE user_id IN (
  SELECT user_id FROM profiles WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11
  )
);

-- захожу также в лайки, иду к медиа с лайком, ищу хозяина медиа подходящего по условию младше 11 лет

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT gender,
	COUNT(user_id) AS 'Количество лайков'
FROM profiles WHERE user_id IN(
	SELECT user_id FROM likes
  )
GROUP BY gender;

-- данный вариант считал "уникальные" лайки пользователей

SELECT COUNT(*)
FROM likes l
JOIN profiles p on l.user_id  = p.user_id
WHERE l.media_id IS NOT NULL AND p.gender = 'm'
UNION
SELECT COUNT(*)
FROM likes l
JOIN profiles p on l.user_id  = p.user_id
WHERE l.media_id IS NOT NULL AND p.gender = 'f';

-- этот вариант лайки-то по гендеру посчитал, только столбцы не проименованы остаются(т.е. остаётся непонятно, чьи конкретно лайки), пришлось к каждому select дописать case:

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
