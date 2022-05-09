-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

DROP DATABASE IF EXISTS example;
CREATE DATABASE example;

USE example;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at DATETIME,
    updated_at DATETIME
);

INSERT INTO users(name) VALUES
	('Petr'),
	('Rita'),
	('Max');
	
UPDATE users
SET
	created_at = now(),
	updated_at = now();
	
/* 2. Таблица users была неудачно спроектирована. 
Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.*/

DROP TABLE IF EXISTS users_failed;
CREATE TABLE users_failed (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at VARCHAR(150),
    updated_at VARCHAR(150)
);

INSERT INTO users_failed(name, created_at, updated_at) VALUES
	('Petr', '20.10.2017 8:10', '22.10.2017 10:10'),
	('Rita', '21.11.2017 10:00', '24.11.2017 12:45'),
	('Max', '22.01.2018 23:27', '29.01.2018 18:16');

UPDATE users_failed
SET
	created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'),
	updated_at = STR_TO_DATE(updated_at,'%d.%m.%Y %H:%i');

/* 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.*/

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products(
	id SERIAL PRIMARY KEY,
	value INT
);

INSERT INTO storehouses_products(value) VALUES
	(0),
	(2500),
	(0),
	(30),
	(500),
	(1);

SELECT * FROM storehouses_products ORDER BY 
	CASE 
		WHEN value = 0 THEN 99999999999999
		ELSE value 
	END;

-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)

DROP TABLE IF EXISTS users_birth;
CREATE TABLE users_birth (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    birthday VARCHAR(100)
);

INSERT INTO users_birth(name, birthday) VALUES
	('Petr', '05 may 2020'),
	('Rita', '13 august 1996'),
	('Nina', '25 november 2001'),
	('Vasiliy', '17 may 1980'),
	('Max', '25 march 2000');

SELECT * FROM users_birth
WHERE
	birthday RLIKE '^[0-9]{2} may|august [0-9]{4}$';

/* 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.*/

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

INSERT INTO catalogs(name) VALUES
	('qwer'),
	('asdf'),
	('zxcv'),
	('tyui'),
	('ghjk'),
	('bnm');

SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1 ,2);

-- Практическое задание теме «Агрегация данных»
-- 1. Подсчитайте средний возраст пользователей в таблице users.

DROP TABLE IF EXISTS users_1;
CREATE TABLE users_1 (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
    birthday_at DATETIME
);

INSERT INTO users_1(name, birthday_at) VALUES
	('Petr', '2010-05-10 00:34:24'),
	('Rita', '2001-12-10 12:34:45'),
	('Nina', '2003-11-16 23:45:15'),
	('Vasiliy', '1985-06-25 09:18:54'),
	('Max', '1994-01-14 10:12:24');

SELECT  AVG(floor((to_days(now()) - to_days(birthday_at)) / 365.25)) as age from users_1;

-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT
	COUNT(*),
	DAYNAME(ADDDATE(birthday_at, INTERVAL + YEAR(NOW()) - YEAR(birthday_at) YEAR)) AS birth_day
FROM users_1
GROUP BY
	birth_day;

-- 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
-- работает только для положительных чисел

DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers(
	num INT
);

INSERT INTO numbers VALUES
	(1),
	(2),
	(3),
	(4),
	(5);

SELECT ROUND(EXP(SUM(LOG(num))), 0) FROM numbers;
