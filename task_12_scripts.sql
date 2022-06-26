USE MFI_synthesis_database;

-- посчитаем количество материалов со структурным типом MFI

SELECT
	COUNT(m.id_materials) AS materials_MFI 
FROM materials AS m
	WHERE m.structure_id = 1;
	
-- усложним задачу и посчитаем количество материалов с каждой структурой (смеси и бесструктурные материалы нас не интересуют)

SELECT
	s.code_structure AS type_structure,
	COUNT(m.id_materials) AS number_materials
FROM materials m 
JOIN structures s ON m.structure_id = s.code_id
WHERE s.code_structure = 'MFI'
UNION
SELECT
	s.code_structure AS type_structure,
	COUNT(m.id_materials) AS number_materials
FROM materials m 
JOIN structures s ON m.structure_id = s.code_id
WHERE s.code_structure  = 'MEL'
UNION
SELECT
	s.code_structure AS type_structure,
	COUNT(m.id_materials) AS number_materials
FROM materials m 
JOIN structures s ON m.structure_id = s.code_id
WHERE s.code_structure  = 'MOR'
UNION
SELECT
	s.code_structure AS type_structure,
	COUNT(m.id_materials) AS number_materials 
FROM materials m 
JOIN structures s ON m.structure_id = s.code_id
WHERE s.code_structure  = 'BEA';

-- посмотрим  список материалов и соответствующих им структур

SELECT
	m.id_materials,
	(SELECT
	s.code_structure
	FROM structures s
	WHERE s.code_id = m.structure_id) AS type_structure
FROM materials m;

-- посмотрим, какие структуры получали в статьях (во многих статьях получали материалы с одной структурой, но разными свойствами, из-за чего будут дубли, которые надо убрать)

SELECT DISTINCT 
	a.id, 
	a.article_name, 
	s.code_structure
FROM articles a
JOIN crystallization c
ON a.id = c.article_id
JOIN materials m
ON c.mode_id = m.id_conditions
JOIN structures s
ON m.structure_id = s.code_id;

-- усложним себе жизнь и сделаем тоже самое без JOIN

SELECT DISTINCT
	(SELECT
		a.id
	FROM articles a 
	WHERE (
		SELECT
			c.article_id
		FROM crystallization c
		WHERE m.id_conditions = c.mode_id) = a.id) AS id,
	(SELECT
		a.article_name
	FROM articles a 
	WHERE (
		SELECT
			c.article_id
		FROM crystallization c
		WHERE m.id_conditions = c.mode_id) = a.id) AS article_name,
	(SELECT
		s.code_structure
	FROM structures s
	WHERE s.code_id = m.structure_id) AS type_structure
FROM materials m;


-- количество публикаций по десятилетиям, отсортированные по убыванию

SELECT
	COUNT(*) AS number_articles_decades,
	SUBSTRING(a.accepted_date, 1, 3) AS decade
FROM
	articles a 
GROUP BY
	decade
ORDER BY
	number_articles_decades DESC;

-- найдём 10 реакционных смесей, которые дают наибольшую площадь поверхности BET

SELECT
	rm.RC_id,
	ss2.source Na_source,
	rm.Na2O,
	as2.source aluminum_source,
	rm.Al2O3,
	ss.source Si_source,
	rm.SiO2,
	t.source template,
	rm.R,
	rm.H2O,
	rm.seeds,
	p.BET_area 
FROM reaction_mixture rm
LEFT JOIN silicium_source ss
ON ss.Si_id = rm.Si_source
LEFT JOIN sodium_source ss2
ON ss2.Na_id = rm.Na_source
LEFT JOIN aluminum_source as2
ON as2.Al_id = rm.Al_source
LEFT JOIN templates t
ON t.template_id = rm.template 
JOIN materials m
ON m.id_reaction_mixture = rm.RC_id
RIGHT JOIN properties p
ON m.id_materials = p.material_id 
ORDER BY p.BET_area DESC
LIMIT 10;

-- ---------------------ПРЕДСТАВЛЕНИЯ

/*
Для анализа данных химику будет удобным представление, где будут отражены:
тип структуры, 
некоторые свойства материалов (кристалличность, площадь BET, объём микропор, общий объём пор, концентрации кислотных центров, Si/Al), 
doi статьи
Структуры без свойств нас не интересуют, поэтому используем просто JOIN
*/

CREATE OR REPLACE VIEW properties_of_materials (`тип структуры`, `кристалличность`, `площадь по BET`, `общий объём пор`, `объём микропор`, `концентрация сильных к.ц.`, `концентрация слабых к.ц.`, `общая концентрация к.ц.`, `Si/Al`, `Ref.`) AS 
SELECT 
	s.code_structure, 
	p.crystallinity,
	p.BET_area,
	p.volume_pore_total,
	p.volume_pore_micro,
	p.strong_acid,
	p.weak_acid,
	p.total_acidity,
	p.module,
	a.DOI
FROM articles a
JOIN crystallization c
ON a.id = c.article_id
JOIN materials m
ON c.mode_id = m.id_conditions
JOIN structures s
ON m.structure_id = s.code_id
JOIN properties p
ON p.material_id = m.id_materials;


SELECT * 
FROM properties_of_materials;

-- c точники зрения химика-синтетика интересно посмотреть как влияет способ кристаллизации на размер и форму кристаллов, создадим соответствующее представление

CREATE OR REPLACE VIEW mode_size (`время старения`, `температура старения`, `температура первой стадии`, 
	`время первой стадии`, `температура второй стадии`, `время второй стадии`, `размер кристаллов`, `форма кристаллов`) AS
SELECT
	c.ageing_time,
	c.ageing_temp,
	c.`1_step_temp`,
	c.`1_step_time`,
	c.`2_step_temp`,
	c.`2_step_time`,
	p.crystal_size,
	p.shape
FROM crystallization c
JOIN materials m
ON m.id_conditions = c.mode_id
JOIN properties p
ON p.material_id = m.id_materials;

SELECT * 
FROM mode_size;

-- найдём режим, при котором образуются самые большие кристаллыы

SELECT *
FROM mode_size ms
ORDER BY ms.`размер кристаллов` DESC LIMIT 1;

-- также интересно посмотреть на влияние тех или иных источников на кристалличность структуры (возьму в качестве примера источники натрия, остальные будут выглядеть аналогично)

CREATE OR REPLACE VIEW Na_source_crystallinity (`id материала`, `источник натрия`, `кристалличность`) AS
SELECT
	m.id_materials,
	ss.source,
	p.crystallinity
FROM materials m 
JOIN properties p ON m.id_materials = p.material_id
JOIN structures s ON m.structure_id = s.code_id
JOIN reaction_mixture rm ON m.id_reaction_mixture = rm.RC_id
JOIN sodium_source ss ON ss.Na_id = rm.Na_source;

SELECT *
FROM Na_source_crystallinity;

-- найдём максимальную кристалличность при использовании различных источников натрия

SELECT *
FROM Na_source_crystallinity nsc ORDER BY nsc.`кристалличность` DESC LIMIT 1;

-- ---------- ХРАНИМЫЕ ПРОЦЕДУРЫ И ТРИГГЕРЫ--------

-- процедура, которая находит публикации с n года

DELIMITER //
DROP PROCEDURE IF EXISTS date_pub//
CREATE PROCEDURE date_pub(IN N INT)
BEGIN
	SELECT
		COUNT(a.id) AS 'Количество публикаций'
	FROM articles a 
	WHERE 
		TIMESTAMPDIFF(YEAR, a.accepted_date , NOW()) < N;
END// 

DELIMITER ;

CALL date_pub(5);

-- процедура, которая выводит список публикаций, где получены материалы с заданной кристалличностью и больше

DELIMITER //
DROP PROCEDURE IF EXISTS art_RC//
CREATE PROCEDURE art_RC(IN N INT)
BEGIN
	SELECT
		a.article_name,
		p.crystallinity
	FROM articles a
	JOIN reaction_mixture rm ON rm.article_id = a.id
	JOIN materials m ON m.id_reaction_mixture = rm.RC_id
	RIGHT JOIN properties p
	ON m.id_materials = p.material_id
	WHERE p.crystallinity > N
	ORDER BY p.crystallinity;
END// 

DELIMITER ;

CALL art_RC(50);

-- процедура, которая по DOI статьи выведет данные о полученных в ней материалах

DELIMITER //
DROP PROCEDURE IF EXISTS doi_search//
CREATE PROCEDURE doi_search(IN doi_info CHAR(255))
BEGIN
	SELECT *
	FROM properties_of_materials pom
	WHERE pom.`Ref.` = doi_info;
END// 

DELIMITER ;

CALL doi_search('10.1016/j.micromeso.2013.07.034');

-- -------ТРИГГЕРЫ----------------

-- создадим триггер, который запрещает добавлять полностью NULL-строку в таблицу свойств материалов (properties)
-- а также триггер, который не даёт обновлять все свойства на NULL

DELIMITER //

DROP TRIGGER IF EXISTS check_null_insert//
CREATE TRIGGER check_null_insert BEFORE INSERT ON properties
FOR EACH ROW 
BEGIN
	IF CONCAT(NEW.crystallinity, NEW.crystal_size, NEW.shape, NEW.BET_area, NEW.volume_pore_total, NEW.volume_pore_micro, NEW.strong_acid, NEW.weak_acid, NEW.total_acidity, NEW.module) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'нельзя добавить все NULL в свойства материала';
	END IF;
END//

DROP TRIGGER IF EXISTS check_null_update//
CREATE TRIGGER check_null_update BEFORE INSERT ON properties
FOR EACH ROW 
BEGIN
	IF CONCAT(NEW.crystallinity, NEW.crystal_size, NEW.shape, NEW.BET_area, NEW.volume_pore_total, NEW.volume_pore_micro, NEW.strong_acid, NEW.weak_acid, NEW.total_acidity, NEW.module) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'нельзя добавить все NULL в свойства материала';
	END IF;
END//

DELIMITER ;

-- закомментировано для проверки триггеров
/*
INSERT INTO properties (material_id, crystallinity, crystal_size, shape, BET_area, volume_pore_total, volume_pore_micro, strong_acid, weak_acid, total_acidity, module) VALUES 
	(113, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
*/

-- триггер, который не даёт удалять статью, если в ней заполнены все поля свойств материала

DELIMITER //
DROP TRIGGER IF EXISTS not_del//
CREATE TRIGGER not_del BEFORE DELETE ON articles
FOR EACH ROW 
BEGIN
IF
	(SELECT
		SUM(CONCAT(pom.`кристалличность`, pom.`площадь по BET` , pom.`общий объём пор` , pom.`общий объём пор` , 
		pom.`объём микропор`, pom.`концентрация сильных к.ц.`, pom.`концентрация слабых к.ц.`, pom.`общая концентрация к.ц.`, pom.`Si/Al`) is NOT NULL) AS chec
	FROM articles a
	JOIN properties_of_materials pom ON pom.`Ref.` = OLD.DOI
	WHERE a.DOI = OLD.DOI) > 0
	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'нельзя удалить статью с полностью охарактеризованными цеолитами';
END IF;
END//


-- закомментировано для проверки триггера
-- DELETE FROM articles WHERE articles.id = 5;

