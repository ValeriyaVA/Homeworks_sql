-- Практическое задание по теме “Транзакции, переменные, представления”

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

-- создадим базу данных sample с таблицей users, такой же как и в shop. 

DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;

USE sample;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) COMMENT 'Имя покупателя',
	birthday_at DATE COMMENT 'Дата рождения',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);

SELECT * FROM users;

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
COMMIT;

SELECT * FROM users;

-- P.S. изначально создала разные по формату таблицы users, транзацкия вылетает с ошибкой.
-- P.P.S. Можно ли отправить в транзакцию лишь общую для обеих таблиц часть, а "лишние" столбцы забить чем-нибудь по дефолту, например, NULL?

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.

USE shop;

CREATE OR REPLACE VIEW cat_view (product, catalog_name) AS 

SELECT
	p.name,
	c.name
FROM
	products AS p
LEFT JOIN
	catalogs AS c
ON
	p.catalog_id = c.id;

SELECT * 
FROM cat_view;

-- 3. Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

USE sample;

-- создадим таблицу с нужными полями

DROP TABLE IF EXISTS date_date;
CREATE TABLE date_date (
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO date_date VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-17'),
	('2018-08-25');

-- попытка решить через создание временной таблицы и join с ней

DROP TEMPORARY TABLE IF EXISTS calendar;
CREATE TEMPORARY TABLE calendar (
	days DATETIME
);

INSERT INTO calendar VALUES
	('2018-08-01'),	('2018-08-02'),	('2018-08-03'),	('2018-08-04'),	('2018-08-05'),	('2018-08-06'),	('2018-08-07'),
	('2018-08-08'),	('2018-08-09'),	('2018-08-10'),	('2018-08-11'),	('2018-08-12'),	('2018-08-13'),	('2018-08-14'),
	('2018-08-15'),	('2018-08-16'),	('2018-08-17'),	('2018-08-18'),	('2018-08-19'),	('2018-08-20'),	('2018-08-21'),
	('2018-08-22'),	('2018-08-23'),	('2018-08-24'),	('2018-08-25'),	('2018-08-26'),	('2018-08-27'),	('2018-08-28'),
	('2018-08-29'),	('2018-08-30'),	('2018-08-31');

SELECT
c.days,
CASE
	WHEN c.days = dd.created_at THEN 1
	ELSE 0
END AS 'true'
FROM calendar c
LEFT JOIN date_date dd ON dd.created_at = c.days;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- для решения запилим в samples таблицу с записями и датами

DROP TABLE IF EXISTS texts;
CREATE TABLE texts (
	id SERIAL PRIMARY KEY,
	body TEXT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);

INSERT INTO texts VALUES
	(1, 'Какой-то текст', '2021-11-01'),
	(2,'Какой-то текст', '2022-09-02'),
	(3,'Какой-то текст', '2010-11-03'),
	(4,'Какой-то текст', '2012-04-06'),
	(5,'Какой-то текст', '2021-12-08'),
	(6,'Какой-то текст', '2008-07-07'),
	(7,'Какой-то текст', '2016-02-26'),
	(8,'Какой-то текст', '2020-03-30'),
	(9,'Какой-то текст', '2018-05-28'),
	(10,'Какой-то текст', '2015-02-02');

-- видимо, нужно делать через транзакции или какой в этом смысл

START TRANSACTION;
PREPARE deletion FROM "DELETE FROM texts ORDER BY created_at LIMIT ?";
SET @cnt=(SELECT COUNT(1)-5 FROM texts);
EXECUTE deletion USING @cnt;
COMMIT;
SELECT * FROM texts;
