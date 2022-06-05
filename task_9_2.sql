/* 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */

-- не знаю о чём эта настройка, но без этой строки не работает, dbeaver предложил эту настройку в описании, без этой строки была ошибка к deterministic

SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT NOT DETERMINISTIC
BEGIN
	-- закинем время в переменную, на тот случай, если час сменится пока работает код (хотя маловероятно, в принципе можно было бы прямо в CASE прописать HOUR(NOW())
 	SET @T = HOUR(NOW());
	CASE
		WHEN @T >= 0 AND @T < 6 THEN
			RETURN 'Доброй ночи';
		WHEN @T >= 6 AND @T < 12 THEN
			RETURN 'Добрый утро';
		WHEN @T >= 12 AND @T < 18 THEN
			RETURN 'Добрый день';
		WHEN @T >= 18 AND @T < 24 THEN
			RETURN 'Добрый вечер';
	END CASE;
END//

SELECT hello() AS 'приветствие'//

/*
В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
Допустимо присутствие обоих полей или одно из них. 
Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/

-- предварительно проверила, что CONCAT(NULL, NULL) возвращает NULL, это и будет использовано

USE shop;

DELIMITER //

DROP TRIGGER IF EXISTS check_null_insert//
CREATE TRIGGER check_null_insert BEFORE INSERT ON products
FOR EACH ROW 
BEGIN
	IF CONCAT(NEW.name, NEW.description) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'name and description is NULL';
	END IF;
END//

-- тоже самое надо провернуть для update

DROP TRIGGER IF EXISTS check_null_update// 
CREATE TRIGGER check_null_update BEFORE UPDATE ON products
FOR EACH ROW BEGIN
	IF CONCAT(NEW.name, NEW.description) IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET message_text = 'name and description is NULL';
	END IF;
END//

DELIMITER ;

-- закомментированы строки для проверки

/*
INSERT INTO products (name, description, price, catalog_id) VALUES (NULL, NULL, 10000, 8);

UPDATE products
	SET name = NULL, description = NULL;
*/

/*
3. Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55
*/

-- очень неудобно, что нельзя сразу параллельно изменить две величины, как в python, пришлось создать дополнительную переменную @F

DELIMITER //

DROP FUNCTION IF EXISTS FIBONACCI//
CREATE FUNCTION FIBONACCI (num INT)
RETURNS INT DETERMINISTIC
BEGIN
	SET @F1 = 1;
	SET @F2 = 1;
	WHILE num > 2 DO
		SET @F = @F1;
		SET @F1 = @F2;
		SET @F2 = @F + @F2;
		SET num = num - 1;
	END WHILE;
	RETURN @F2;
END//

SELECT FIBONACCI(10)//

