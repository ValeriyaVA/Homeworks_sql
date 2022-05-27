DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;

USE shop;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Видеокарты'),
  (NULL, 'Память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

-- заменим тип внешнего ключа и свяжем таблицу заказов с таблицей пользователей (можно было редактировать и сам код, но раз уж наткнулась на ошибку несовместимости типов, использую материал лекции)

ALTER TABLE orders
	CHANGE COLUMN user_id user_id BIGINT(20) UNSIGNED NOT NULL;

ALTER TABLE orders ADD CONSTRAINT fk_user_id
	FOREIGN KEY (user_id) REFERENCES users(id)
	ON DELETE CASCADE ON UPDATE CASCADE;

-- теперь аналогично нужно связать заказанные товары с номерами заказов

ALTER TABLE orders_products
	CHANGE COLUMN order_id order_id BIGINT(20) UNSIGNED NOT NULL;

ALTER TABLE orders_products
	ADD CONSTRAINT fk_order_id FOREIGN KEY(order_id) REFERENCES orders(id)
	ON DELETE CASCADE ON UPDATE CASCADE;

-- P.S. в итоге это не пригодилось

-- теперь, наконец, заполним таблицу заказов и заказанных предметов

INSERT INTO orders (id, user_id, created_at, updated_at) VALUES
	('1', '1', '1970-09-05 06:48:07', '1996-01-09 07:47:09'),
	('2', '2', '2003-12-05 09:09:16', '2004-01-20 20:56:33'),
	('3', '3', '1981-06-19 09:51:21', '2001-11-08 08:32:11'),
	('4', '1', '2002-07-06 11:11:39', '1990-11-16 02:37:30'),
	('5', '1', '1994-05-26 19:17:43', '2019-02-28 05:50:07');

INSERT INTO orders_products (id, order_id, product_id, total, created_at, updated_at) VALUES
	('1', '1', '1', 1, '2001-06-18 08:45:18', '2012-12-27 19:47:17'),
	('2', '2', '5', 2, '1987-01-13 07:15:42', '1994-04-06 23:38:11'),
	('3', '3', '3', 3, '1986-08-20 23:46:21', '2005-01-23 09:41:59'),
	('4', '4', '2', 5, '2010-01-15 00:45:01', '2009-03-06 15:45:25'),
	('5', '5', '3', 1, '1976-08-25 08:23:07', '1981-08-25 23:54:39'),
	('6', '1', '2', 5, '1992-04-03 13:48:03', '1982-04-15 04:41:37'),
	('7', '2', '1', 3, '1971-09-08 15:17:15', '1998-10-23 07:56:37'),
	('8', '3', '1', 3, '1998-01-04 03:21:53', '2018-04-08 21:27:37'),
	('9', '4', '4', 2, '2017-11-21 15:41:50', '1977-06-04 21:13:38'),
	('10', '5', '5', 1, '1989-04-29 07:26:42', '2021-04-18 19:59:11');

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- из таблицы users находим пользователей, которые есть в таблице orders, дубли удаляем

SELECT DISTINCT
	u.name,
	u.birthday_at
FROM users AS u
JOIN
	orders AS o
ON u.id = o.user_id;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару

SELECT
	p.id,
	p.name,
	c.name AS catalog
FROM
	products AS p
JOIN
	catalogs AS c
ON
	p.catalog_id = c.id;

-- 3. Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

-- берём столбец from, находим его в cities label, выбираем соответствующий ему name. Аналогично столбец to
DROP TABLE IF EXISTS flights;
CREATE TABLE flights(
	id SERIAL PRIMARY KEY,
	`from` VARCHAR(255),
	`to` VARCHAR(255)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	label VARCHAR(255),
	name VARCHAR(255)
);

INSERT INTO flights(`from`, `to`) VALUES
	('moscow', 'omsk'),
	('novgorod', 'kazan'),
	('irkutsk', 'moscow'),
	('omsk', 'irkutsk'),
	('moscow', 'kazan');

INSERT INTO cities(label, name) VALUES
	('moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');

SELECT
	f.id,
	c_from.name AS `FROM`,
	c_to.name AS `TO`
FROM flights AS f
JOIN
	cities AS c_from
ON
	f.`from` = c_from.label
JOIN
	cities AS c_to
ON
	f.`to` = c_to.label
ORDER BY f.id;


