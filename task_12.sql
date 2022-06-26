/*
База данных по научным публикациям о синтезе цеолитов
Таблица articles включает информацию о статье
Таблица structures о типах получаемых структур
Таблица reaction-mixture - составы реакционных смесей и источники реагентов (источники помещены в таблицы silicium_source, sodium_source, aluminum_source, templates), а также затравка при её наличии
Таблица crystallization об условиях кристаллизаци реакционных смесей
Таблица materials - таблица полученных материалов, куда входит id реакционной смеси из таблицы reaction_mixture, id условий кристаллизации из crystallization и id полученной структуры из structures
Таблица properties - таблица свойств полученных материалов. Не каждый материал был охарактеризован
*/

DROP DATABASE IF EXISTS MFI_synthesis_database;
CREATE DATABASE MFI_synthesis_database;
USE MFI_synthesis_database;

-- Сюда входит информация о статье: название журнала, название статьи, DOI (идентификационный уникальный номер статьи), дата принятия в печать, номер журнала, страницы статьи в журнале
-- таблица статей связана с таблицами условий кристаллизации (crystallization), реакционных смесей (reaction_mixture)

DROP TABLE IF EXISTS articles;
CREATE TABLE articles(
  `id` SERIAL PRIMARY KEY,
  `journal_name` CHAR(255),
  `article_name` TEXT,
  `DOI` CHAR(255) COMMENT 'Digital Object Identifier',
  `accepted_date` DATE COMMENT 'дата выхода статьи',
  `volume` INT COMMENT 'номер журнала',
  `pages` CHAR(100) COMMENT 'номера страниц');

-- создаём таблицу с источниками натрия

DROP TABLE IF EXISTS sodium_source;
CREATE TABLE sodium_source(
	Na_id SERIAL PRIMARY KEY,
	source CHAR(50)
);

-- создаём таблицу с источниками алюминия

DROP TABLE IF EXISTS aluminum_source;
CREATE TABLE aluminum_source(
	Al_id SERIAL PRIMARY KEY,
	source CHAR(100)
);

-- создаём таблицу с источниками кремния

DROP TABLE IF EXISTS silicium_source;
CREATE TABLE silicium_source(
	Si_id SERIAL PRIMARY KEY,
	source CHAR(100)
);

-- создаём таблицу с темплатами 

DROP TABLE IF EXISTS templates;
CREATE TABLE templates(
	template_id SERIAL PRIMARY KEY,
	source CHAR(100)
);

-- создаём таблицу с условиями кристаллизации

DROP TABLE IF EXISTS crystallization;
CREATE TABLE crystallization (
  `mode_id` SERIAL PRIMARY KEY,
  `article_id` BIGINT UNSIGNED NULL,
  `ageing_time` INT COMMENT 'время старения в часах',
  `ageing_temp` INT COMMENT 'температура старения в градусах Цельсия',
  `1_step_temp` INT COMMENT 'температура первой стадии в Кельвинах',
  `2_step_temp` INT COMMENT 'температура второй стадии в Кельвинах',
  `1_step_time` FLOAT COMMENT 'время первой стадии в часах',
  `2_step_time` FLOAT COMMENT 'время второй стадии в часах',
  CONSTRAINT `fk_crystallization_1`
    FOREIGN KEY (`article_id`) REFERENCES `MFI_synthesis_database`.`articles` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- таблица структур: в каждой статье получают одну или несколько структур из данной таблицы, одни и те же структуры могут получать в разных статьях. 
-- Каждой структуре соответствует уникальный 3буквенный код
 
DROP TABLE IF EXISTS structures;
CREATE TABLE structures(
	code_id SERIAL PRIMARY KEY,
	code_structure VARCHAR(20) UNIQUE COMMENT 'Framework Type Code'
);

-- заполняем таблицу названиями структур

INSERT INTO structures (code_structure) VALUES
	('MFI'),
	('MEL'),
	('BEA'),
	('MOR'),
	('no structure'),
	('mixture structures');

-- создаём таблицу реакционных смесей

DROP TABLE IF EXISTS reaction_mixture;
CREATE TABLE reaction_mixture(
	RC_id SERIAL PRIMARY KEY,
	`article_id` BIGINT UNSIGNED NULL,
	Na_source BIGINT UNSIGNED DEFAULT NULL,
	Na2O FLOAT,
	Al_source BIGINT UNSIGNED DEFAULT NULL,
	Al2O3 FLOAT,
	Si_source BIGINT UNSIGNED DEFAULT NULL,
	SiO2 TINYINT,
	template BIGINT UNSIGNED DEFAULT NULL,
	R FLOAT,
	H2O FLOAT,
	`seeds` TEXT COMMENT 'количество масс.% от SiO2 и тип затравки',
  INDEX `Na_source` (`Na_source` ASC) VISIBLE,
  INDEX `Al_source` (`Al_source` ASC) VISIBLE,
  INDEX `Si_source` (`Si_source` ASC) VISIBLE,
  INDEX `template` (`template` ASC) VISIBLE,
  CONSTRAINT `reaction_mixture_ibfk_2`
    FOREIGN KEY (`Na_source`)
    REFERENCES `MFI_synthesis_database`.`sodium_source` (`Na_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `reaction_mixture_ibfk_3`
    FOREIGN KEY (`Al_source`)
    REFERENCES `MFI_synthesis_database`.`aluminum_source` (`Al_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `reaction_mixture_ibfk_4`
    FOREIGN KEY (`Si_source`)
    REFERENCES `MFI_synthesis_database`.`silicium_source` (`Si_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `reaction_mixture_ibfk_5`
    FOREIGN KEY (`template`)
    REFERENCES `MFI_synthesis_database`.`templates` (`template_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_reaction_mixture_1`
    FOREIGN KEY (`article_id`)
    REFERENCES `articles` (`id`)
   	ON DELETE CASCADE
    ON UPDATE CASCADE);

-- создаём таблицу полученных материалов
   
DROP TABLE IF EXISTS materials;
CREATE TABLE materials(
  `id_materials` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_reaction_mixture` BIGINT UNSIGNED NULL,
  `id_conditions` BIGINT UNSIGNED NULL,
  `structure_id` BIGINT UNSIGNED NULL,
  INDEX `fk_materials_1_idx` (`id_reaction_mixture` ASC) VISIBLE,
  INDEX `fk_materials_2_idx` (`id_conditions` ASC) VISIBLE,
  INDEX `fk_materials_3_idx` (`structure_id` ASC) VISIBLE,
  PRIMARY KEY (`id_materials`),
  CONSTRAINT `fk_materials_1`
    FOREIGN KEY (`id_reaction_mixture`)
    REFERENCES `MFI_synthesis_database`.`reaction_mixture` (`RC_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_materials_2`
    FOREIGN KEY (`id_conditions`)
    REFERENCES `MFI_synthesis_database`.`crystallization` (`mode_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_materials_3`
    FOREIGN KEY (`structure_id`)
    REFERENCES `MFI_synthesis_database`.`structures` (`code_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- создаём таблицу свойств материалов
   
DROP TABLE IF EXISTS `MFI_synthesis_database`.`properties` ;

CREATE TABLE IF NOT EXISTS `MFI_synthesis_database`.`properties` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `material_id` BIGINT UNSIGNED NULL,
  `crystallinity` FLOAT COMMENT 'кристалличность',
  `crystal_size` FLOAT COMMENT 'размер кристаллов в микрометрах',
  `shape` CHAR(100) COMMENT 'форма кристаллов',
  `BET_area` INT COMMENT 'площадь BET',
  `volume_pore_total` FLOAT COMMENT 'общий объём пор',
  `volume_pore_micro` FLOAT COMMENT 'объём микропор',
  `strong_acid` FLOAT COMMENT 'концентрация сильных кислотных центров по ТПД мкмоль/г',
  `weak_acid` FLOAT COMMENT 'концентрация слабых кислотных центров по ТПД мкмоль/г',
  `total_acidity` FLOAT COMMENT 'общая кислотность по ТПД мкмоль/г',
  `module` FLOAT COMMENT 'мольное отношение SiO2/Al2O3',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id` (`id` ASC) VISIBLE,
  INDEX `fk_properties_1_idx` (`material_id` ASC) VISIBLE,
  CONSTRAINT `fk_properties_1`
    FOREIGN KEY (`material_id`)
    REFERENCES `MFI_synthesis_database`.`materials` (`id_materials`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- ------- Заполняем таблицы данными   

USE MFI_synthesis_database;

INSERT INTO sodium_source (source) VALUES
	('NaOH'),
	('Na free'),
	('NaAlO2'),
	('Na2SiO3'),
	('water glass'),
	('alternative source cation');
	
INSERT INTO aluminum_source (source) VALUES
	('NaAlO2'),
	('kaoline'),
	('Al2(SO4)3*18H2O'),
	('Al(NO3)3*9H2O'),
	('Al(iPr)3'),
	('metal'),
	('Al(OH)3'),
	('Al free'),
	('Al(NO3)3*9H2O');

INSERT INTO silicium_source (source) VALUES
	('silicagel'),
	('aerosil'),
	('TEOS'),
	('silicasol'),
	('colloidal silica'),
	('silicic acid'),
	('I-SR(purified illite)'),
	('rice husk'),
	('Sylobloc 47'),
	('sodium silicate'),
	('fumed silica');

INSERT INTO templates (source) VALUES
	('tetrapropylammonium hydroxide'),
	('1,4-diaminobutane'),
	('n-propylamine'),
	('Diethylamine'),
	('1,6-diaminohexane'),
	('tetrapropylammonium bromide'),
	('1,8-diaminooctane'),
	('cetyltrimethylammonium'),
	('n-butylamine'),
	('triethylamine'),
	('ethylamine'),
	('isopropylamine'),
	('L-tartaric acid'),
	('DL-tartaric acid'),
	('L-arginine'),
	('L-ascorbic acid'),
	('D-sogium gluconate'),
	('template free'),
	('ethanol'),
	('2,2-dieth-oxyethyltrimethylammonium'),
	('tetrabutylammonium hydroxide'),
	('N,N-diethyl-3,5-dimethylpiperidinium'),
	('1-ethyl-6-azonia-spiro-[5,5]-undecane'),
	('hexamethylene diamine'),
	('tetraethylammonia hydroxide');

INSERT INTO articles (journal_name, article_name, DOI, accepted_date, volume, pages) VALUES
	('Microporous and Mesoporous Materials', 'A fast organic template-free, ZSM-11 seed-assisted synthesis of ZSM-5 with good performance in methanol-to-olefin', 
	'10.1016/j.micromeso.2013.07.034', '2013-11-15', 181, '192-200'),
	('Journal of the Chemical Society, Chemical Communications', 'A novel method for the preparation of zeolite ZSM-5', '10.1039/c39900000755', '1990-01-01', 10, '755-756'),
	('Microporous and Mesoporous Materials', 'A seed surface crystallization approach for rapid synthesis of submicron ZSM-5 zeolite with controllable crystal size and morphology', 
	'10.1016/j.micromeso.2009.12.009', '2009-12-11', 131, '103-114'),
	('Microporous and Mesoporous Materials', 'Anomalous crystallization mechanism in the synthesis of nanocrystalline ZSM-5',
	'10.1016/S1387-1811(00)00190-6', '1999-02-25', 39, '135-147'),
	('Fuel Processing Technology', 'Controllable synthesis of ultra-tiny nano-ZSM-5 catalyst based on the control of crystal growth for methanol to hydrocarbon reaction',
	'10.1016/j.fuproc.2020.106594', '2020-09-03', 211, '106594'),
	('Inorganica Chimica Acta', 'Layered silicate formation during chiral acid templated ZSM-5 synthesis', '/10.1016/j.ica.2020.120140', '2020-11-10', 516, '120140'),
	('Journal of Natural Gas Chemistry', 'Optimization of hydrothermal synthesis of H-ZSM-5 zeolite for dehydration of methanol to dimethyl ether using full factorial design',
	'10.1016/S1003-9953(11)60375-7', '2011-12-29', 3, '344-351'),
	('Journal of Porous Materials', 'In-situ synthesis of hierarchical lamellar ZSM-5 zeolite with enhanced MTP catalytic performance by a facile seed-assisted method',
	'10.1007/s10934-020-00898-w', '2020-05-23', 5, '1265-1275'),
	('Journal of CO2 Utilization', 'Identifying correlations in Fischer-Tropsch synthesis and CO2 hydrogenation over Fe-based ZSM-5 catalysts',
	'10.1016/j.jcou.2020.101290', '2020-08-16', 41, '101290'),
	('Catalysis Letters', 'Influence of Silanol Defects of ZSM-5 Zeolites on Trioxane Synthesis from Formaldehyde',
	'10.1007/s10562-019-03040-x', '2020-11-20', 150, '1445-1453'),
	('Catalysis Science & Technology', 'High yield synthesis of nanoscale high-silica ZSM-5 zeolites via interzeolite transformation with a new strategy',
	'10.1039/D0CY01345E', '2020-09-11', 10, '7904-7913'),
	('Microporous and Mesoporous Materials', 'Intra-crystalline mesoporous ZSM-5 zeolite by grinding synthesis method',
	'10.1016/j.micromeso.2020.110437', '2020-06-24', 306, '110437'),
	('Microporous and Mesoporous Materials', 'Fast synthesis of submicron ZSM-5 zeolite from leached illite clay using a seed-assisted method',
	'10.1016/j.micromeso.2018.08.028', '2018-08-25', 275, '223-228'),
	('Microporous and Mesoporous Materials', 'Insight into seed-assisted template free synthesis of ZSM-5 zeolites',
	'10.1016/j.micromeso.2016.10.040', '2016-10-25', 239, '444-452'),
	('Materials Letters', 'A facile synthesis of ZSM-11 zeolite particles using rice husk ash as silica source',
	'10.1016/j.matlet.2012.07.079', '2012-06-23', 87, '87-89'),
	('Studies in Surface Science and Catalysis', 'Defect-free MEL-type zeolites synthesized in the presence of an azoniaspiro-compound',
	'0.1016/S0167-2991(02)80012-X', '2002-01-01',142, '61-68'),
	('Fuel Processing Technology', 'Differences between ZSM-5 and ZSM-11 zeolite catalysts in 1-hexene aromatization and isomerization',
	'10.1016/j.fuproc.2009.12.003', '2009-12-01', 91, '449-455'),
	('Journal of Colloid and Interface Science', 'Synthesis and morphological studies of nanocrystalline MOR type zeolite material',
	'https://doi.org/10.1016/j.jcis.2008.05.058', '2008-05-30', 325, '547-557'),
	('Industrial & engineering chemistry research', 'Synthesis and Evaluation of Pure-Silica-Zeolite BEA as Low Dielectric Constant Material for Microprocessors',
	'https://doi.org/10.1021/ie034062k', '2003-12-31', 43, '2946-2949');


INSERT INTO reaction_mixture (article_id, Na_source, Na2O, Al_source, Al2O3, Si_source,	SiO2, template, R, H2O, seeds) VALUES
	(1, 1, 0.139, 3, 0.016, 5, 1, 9, 0.0163, 20, NULL),
	(1, 1, 0.139, 3, 0.016, 5, 1, 9, 0.0163, 20, 'ZSM-11 hierarchical 0.06'),
	(1, 1, 0.139, 3, 0.016, 5, 1, 9, 0.0163, 20, 'ZSM-11 mesoporous 0.06'),
	(1, 1, 0.139, 3, 0.016, 5, 1, 9, 0.0163, 20, 'ZSM-5 mesoporous 0.06'),
	(2, 1, 0.03, 3, 0.022, 4, 1, 10, 0.10, 5.2, NULL),
	(2, 1, 0.017, 3, 0.0116, 4, 1, 10, 0.09, 3.9, NULL),
	(2, 1, 0.017, 3, 0.0116, 4, 1, 10, 0.09, 0.12, NULL),
	(3, 1, 0.28, 3, 0.01, 5, 1, 18, 0, 40, 'silicalite-90 nm 23'),
	(3, 1, 0.28, 3, 0.01, 5, 1, 18, 0, 40, 'silicalite-180 nm 23'),
	(3, 1, 0.28, 3, 0.01, 5, 1, 18, 0, 40, 'silicalite-220 nm 23'),
	(3, 1, 0.28, 3, 0.01, 5, 1, 18, 0, 40, 'silicalite-260 nm 23'),
	(3, 1, 0.28, 3, 0.01, 5, 1, 18, 0, 40, 'silicalite-690 nm 23'),
	(4, 2, 0, 3, 0.0167, 3, 1, 1, 3.357, 10.8, NULL),
	(4, 2, 0, 4, 0.0167, 3, 1, 1, 3.357, 10.8, NULL),
	(4, 2, 0, 5, 0.0167, 3, 1, 1, 3.357, 10.8, NULL),
	(4, 2, 0, 5, 0.0167, 3, 1, 1, 3.357, 50, NULL),
	(4, 2, 0, 5, 0.0167, 3, 1, 1, 0.713, 10.8, NULL),
	(4, 1, 0.155, 5, 0.0167, 3, 1, 1, 3.357, 21.7, NULL),
	(4, 1, 0.388, 5, 0.0167, 3, 1, 1, 3.357, 50, NULL),
	(5, 1, 0.0917, 1, 0.0167, 4, 1, 1, 0.3, 12.5, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 13, 0.01, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 13, 0.02, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 13, 0.03, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 13, 0.04, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 13, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 5, 1, 14, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 13, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.001, 6, 1, 13, 0.05, 50, NULL),
	(6, 1, 0.188, 8, 0, 6, 1, 18, 0, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 15, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.001, 6, 1, 15, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 16, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.001, 6, 1, 16, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 17, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.001, 6, 1, 17, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 6, 0.05, 50, NULL),
	(6, 1, 0.188, 3, 0.01, 6, 1, 18, 0, 50, NULL),
	(7, 2, 0, 9, 0.01, 3, 1, 1, 0.357, 10.8, NULL),
	(7, 2, 0, 9, 0.008, 3, 1, 1, 0.357, 10.8, NULL),
	(7, 2, 0, 9, 0.0067, 3, 1, 1, 0.357, 10.8, NULL),
	(8, 5, 0.067, 3, 0.017, 5, 1, 18, 0, 50, 'ZSM-5 5'),
	(9, 1, 0.05, 4, 0.017, 3, 1, 1, 0.25, 8.3, NULL),
	(10, 2, 0, 4, 0.01, 3, 1, 1, 0.377, 27, NULL),
	(10, 6, 0.02, 4, 0.01, 3, 1, 1, 0.377, 27, NULL),
	(10, 6, 0.08, 4, 0.01, 3, 1, 1, 0.377, 27, NULL),
	(10, 6, 0.15, 4, 0.01, 3, 1, 1, 0.377, 27, NULL),
	(11, 1, 0.06, 3, 0.003, 3, 1, 1, 0.923, 166.7, 'BEA 1'),
	(12, 1, 0.113, 1, 0.033, 5, 1, 6, 0.12, 2.33, NULL),
	(12, 1, 0.153, 1, 0.033, 5, 1, 6, 0.12, 2.33, NULL),
	(12, 1, 0.193, 1, 0.033, 5, 1, 6, 0.12, 2.33, NULL),
	(12, 1, 0.053, 1, 0.033, 5, 1, 6, 0.12, 2.33, NULL),
	(12, 1, 0.073, 1, 0.033, 5, 1, 6, 0.12, 2.33, NULL),
	(13, 1, 0.16, 1, 0.0125, 7, 1, 19, 1.875, 30, 'imported CBV8014 7'),
	(13, 1, 0.16, 1, 0.0125, 7, 1, 19, 1.875, 30, 'ZSM-5 (Domestic Nankai) 7'),
	(13, 1, 0.16, 1, 0.0125, 7, 1, 19, 1.875, 30, 'self made ZSM-5 7'),
	(14, 1, 0.417, 1, 0.05, 4, 1, 18, 0, 50, 'ZSM-5 250 nm 0.35'),
	(14, 1, 0.417, 1, 0.05, 4, 1, 18, 0, 50, 'ZSM-5 70 nm 0.35'),
	(14, 1, 0.25, 1, 0.05, 4, 1, 18, 0, 50, 'ZSM-5 70 nm 0.35'),
	(14, 1, 0.417, 1, 0.05, 4, 1, 18, 0, 50, 'ZSM-5 70 nm 0.2'),
	(14, 1, 0.417, 1, 0.05, 4, 1, 18, 0, 50, 'ZSM-5 90m 0.35'),
	(15, 1, 0.04, 1, 0.01, 8, 1, 21, 0.35, 12, NULL),
	(16, 1, 0.05, 8, 0, 9, 1, 23, 0.2, 45, NULL),
	(16, 1, 0.05, 3, 0.01, 9, 1, 23, 0.2, 45, NULL),
	(16, 1, 0.05, 3, 0.02, 9, 1, 23, 0.2, 45, NULL),
	(16, 1, 0.05, 3, 0.04, 9, 1, 23, 0.2, 45, NULL),
	(16, 1, 0.05, 8, 0, 9, 1, 23, 0.2, 20, NULL),
	(16, 1, 0.05, 8, 0, 9, 1, 23, 0.2, 30, NULL),
	(16, 1, 0.05, 8, 0, 9, 1, 23, 0.2, 60, NULL),
	(16, 1, 0.05, 3, 0.01, 9, 1, 23, 0.2, 30, NULL),
	(16, 2, 0, 8, 0, 9, 1, 23, 0.2, 30, NULL),
	(16, 1, 0.05, 8, 0, 9, 1, 23, 0.35, 45, NULL),
	(18, 1, 1, 9, 1, 10, 10, 18, 0, 48, NULL),
	(18, 1, 1, 9, 1, 3, 10, 18, 0, 48, NULL),
	(19, 2, 0, 8, 0, 11, 1, 25, 0.6, 9.8, NULL);
	
	
INSERT INTO crystallization (article_id, ageing_time, ageing_temp, 1_step_temp, 2_step_temp, 1_step_time, 2_step_time) VALUES
	(1, NULL, NULL, 90, 170, 24, 24),
	(1, NULL, NULL, 90, 170, 24, 7),
	(1, NULL, NULL, 90, 170, 24, 12),
	(1, NULL, NULL, 90, 170, 24, 16),
	(1, NULL, NULL, 90, 170, 24, 20),
	(1, NULL, NULL, 90, 170, 24, 28),
	(1, NULL, NULL, 90, 170, 24, 32),
	(1, NULL, NULL, 90, 170, 24, 36),
	(1, 48, 25, 170, NULL, 18, NULL),
	(1, 48, 25, 170, NULL, 24, NULL),
	(2, NULL, NULL, 200, NULL, 120, NULL),
	(2, NULL, NULL, 180, NULL, 168, NULL),
	(3, NULL, NULL, 210, NULL, 0.5, NULL),
	(3, NULL, NULL, 210, NULL,1, NULL),
	(3, NULL, NULL, 210, NULL,1.5, NULL),
	(3, NULL, NULL, 210, NULL,2, NULL),
	(3, NULL, NULL, 210, NULL,2.5, NULL),
	(3, NULL, NULL, 210, NULL,3, NULL),
	(4, 16, 25, 170, NULL, 72, NULL),
	(4, 40, 25, 170, NULL, 72, NULL),
	(4, 66, 25, 170, NULL, 72, NULL),
	(4, 40, 25, 170, NULL, 6, NULL),
	(4, 40, 25, 170, NULL, 12, NULL),
	(4, 40, 25, 170, NULL, 18, NULL),
	(4, 40, 25, 170, NULL, 20, NULL),
	(4, 40, 25, 170, NULL, 22, NULL),
	(4, 40, 25, 170, NULL, 24, NULL),
	(4, 40, 25, 170, NULL, 48, NULL),
	(4, 40, 25, 170, NULL, 96, NULL),
	(4, 40, 25, 170, NULL, 108, NULL),
	(4, 40, 25, 170, NULL, 120, NULL),
	(5, 24, 35, 110, NULL, 72, NULL),
	(5, 24, 35, 110, NULL, 96, NULL),
	(5, 24, 35, 110, NULL, 120, NULL),
	(5, 24, 35, 110, NULL, 144, NULL),
	(5, 24, 35, 110, NULL, 192, NULL),
	(5, 24, 35, 110, NULL, 240, NULL),
	(6, NULL, NULL, 165, NULL, 48, NULL),
	(7, 3, 25, 170, NULL, 72, NULL),
	(7, 3, 25, 180, NULL, 72, NULL),
	(7, 3, 25, 190, NULL, 72, NULL),
	(8, 24, 60, 150, NULL, 96, NULL),
	(9, NULL, NULL, 170, NULL, 24, NULL),
	(10, NULL, NULL, 170, NULL, 168, NULL),
	(11, NULL, NULL, 150, NULL, 3, NULL),
	(12, NULL, NULL, 170, NULL, 24, NULL),
	(12, NULL, NULL, 170, NULL, 6, NULL),
	(12, NULL, NULL, 170, NULL, 12, NULL),
	(12, NULL, NULL, 170, NULL, 96, NULL),
	(13, NULL, NULL, 170, NULL, 3, NULL),
	(14, NULL, NULL, 165, NULL, 24, NULL),
	(14, NULL, NULL, 165, NULL, 14, NULL),
	(15, NULL, NULL, 100, NULL, 288, NULL),
	(16, NULL, NULL, 155, NULL, 168, NULL),
	(16, NULL, NULL, 170, NULL, 168, NULL),
	(16, NULL, NULL, 155, NULL, 336, NULL),
	(16, NULL, NULL, 170, NULL, 336, NULL),
	(16, NULL, NULL, 170, NULL, 96, NULL),
	(16, NULL, NULL, 170, NULL, 144, NULL),
	(18, NULL, NULL, 170, NULL, 24, NULL),
	(19, NULL, NULL, 130, NULL, 336, NULL);
	
INSERT INTO materials(id_reaction_mixture, id_conditions, structure_id) VALUES
	(1, 1, 1),	(1, 2, 1),	(1, 3, 1),	(1, 4, 1),	(1, 5, 1),	(1, 6, 1),	(1, 7, 1), (1, 8, 1), (2, 9, 1), (3, 9, 1), (4, 10, 1),
	(5, 11, 1),	(6, 12, 1),	(7, 12, 1),
	(8, 13, 1),	(8, 14, 1),	(8, 15, 1),	(8, 16, 1),	(8, 17, 1),	(8, 18, 1),	(9, 18, 1),	(10, 18, 1), (11, 13, 1), (11, 14, 1), (11, 15, 1),	(11, 16, 1), 
		(11, 17, 1), (11, 18, 1), (12, 13, 1), (12, 14, 1), (12, 15, 1), (12, 16, 1), (12, 17, 1), (12, 18, 1),
	(13, 19, 1), (13, 20, 1), (14, 21, 1), (14, 19, 1), (15, 19, 1), (16, 19, 1), (17, 19, 1), (18, 19, 1), (19, 19, 1), (15, 19, 1), (15, 22, 5),
		(15, 23, 5), (15, 24, 1), (15, 25, 1), (15, 26, 1),	(15, 27, 1), (15, 28, 1), (15, 19, 1), (15, 29, 1),	(15, 30, 1), (15, 31, 1),
	(20, 32, 1), (20, 33, 1), (20, 34, 1), (20, 35, 1),	(20, 36, 1), (20, 37, 1),
	(21, 38, 1), (22, 38, 1), (23, 38, 1), (24, 38, 1), (25, 38, 1), (26, 38, 1), (27, 38, 1), (28, 38, 1), (29, 38, 1), (30, 38, 1), (31, 38, 1),
		(32, 38, 1), (33, 38, 1), (34, 38, 1), (35, 38, 1), (36, 38, 1), (37, 38, 1),
	(38, 39, 1), (38, 40, 1), (38, 41, 1), (38, 39, 1), (39, 40, 1), (39, 41, 1), (39, 39, 1), (40, 40, 1), (40, 41, 1),
	(41, 42, 1),
	(42, 43, 1),
	(43, 44, 1), (44, 44, 1), (45, 44, 1), (46, 44, 1),
	(47, 45, 1),
	(48, 46, 1), (49, 46, 1), (50, 46, 1), (51, 46, 1), (52, 46, 1), (48, 47, 1), (48, 48, 1), (48, 49, 1),
	(53, 50, 1), (54, 50, 1), (55, 50, 1),
	(56, 51, 1), (57, 51, 1), (57, 52, 1), (58, 51, 1), (59, 51, 1), (60, 51, 1),
	(61, 53, 2),
	(62, 57, 5), (62, 54, 2), (62, 56, 2), (63, 57, 5), (63, 54, 2), (63, 56, 2), (64, 57, 5), (65, 57, 5),
		(66, 56, 5), (67, 57, 5), (68, 57, 2), (69, 57, 2), (70, 57, 2), (70, 57, 2), (71, 58, 6), (71, 59, 6), (71, 57, 2),
	(72, 60, 4), (73, 60, 4),
	(74, 61, 3);
	
	
INSERT INTO properties (material_id, crystallinity, crystal_size, shape, BET_area, volume_pore_total, volume_pore_micro, strong_acid, weak_acid, total_acidity, module) VALUES
	(1, 72, 6, 'no shape', 356, 0.19, 0.15, NULL, NULL, NULL, 50.2),
	(2, 22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),	
	(3, 25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(4, 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(5, 58, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(6, 83, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(7, 95, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(8, 94, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(9, NULL, 2, 'prisma', 321, 0.18, 0.12, 0.21, 0.31, NULL, 56.4),
	(10, NULL, 5, 'prisma', 329, 0.17, 0.12, 0.21, 0.33, NULL, 55.6),
	(11, NULL, 5, 'prisma', 322, 0.17, 0.12, 0.25, 0.34, NULL, 51.8),
	(12, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 44.8),
	(13, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86),
	(14, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 86.4),
	(15, 12, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(16, 13, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(17, 97, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(18, 99, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(19, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(20, 100, 0.27, 'prisma', 321, NULL, 0.12, NULL, NULL, NULL, 42),
	(21, 99, 0.35, 'prisma', 318, NULL, 0.13, NULL, NULL, NULL, 36),
	(22, 98, 0.44, 'prisma', 309, NULL, 0.11, NULL, NULL, NULL, 38),
	(23, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(24, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(25, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(26, 95, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(27, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(28, 100, 0.52, 'prisma', 327, NULL, 0.13, NULL, NULL, NULL, 32),
	(29, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(30, 19, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(31, 29, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(32, 53, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(33, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(34, 100, 1.1, 'prisma', 310, NULL, 0.12, NULL, NULL, NULL, 44),
	(35, 98, 0.11, NULL, NULL, NULL, NULL, NULL, NULL, 0.513, 60),
	(36, 98.2, 0.09, NULL, NULL, NULL, NULL, NULL, NULL, 0.503, 60.2),
	(37, 97.7, 0.09, NULL, NULL, NULL, NULL, NULL, NULL, 0.506, 59.8),
	(38, 100, 0.09, NULL, NULL, NULL, NULL, NULL, NULL, 0.487, 62.2),
	(39, 97, 0.07, NULL, NULL, NULL, NULL, NULL, NULL, 0.506, 60.6),
	(40, 97.3, 0.06, NULL, NULL, NULL, NULL, NULL, NULL, 0.466, 62.2),
	(41, 74.1, 0.17, NULL, NULL, NULL, NULL, NULL, NULL, 0.305, 60.6),
	(42, 93.5, 0.3, NULL, NULL, NULL, NULL, NULL, NULL, 0.558, 42.4),
	(43, 72.7, 0.14, NULL, NULL, NULL, NULL, NULL, NULL, 0.302, 57),
	(44, 92.5, 0.05, NULL, NULL, NULL, NULL, NULL, NULL, 0.410, 60.8),
	(47, 18, NULL, NULL, 646, 1.134, 0.119, NULL, NULL, NULL, NULL),
	(48, 55, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(49, 65, 0.02, 'sphere', 485, 0.439, 0.149, NULL, NULL, NULL, NULL),
	(50, 97, NULL, NULL, 469, 0.472, 0.174, NULL, NULL, NULL, NULL),
	(51, 00, 0.1, 'prisma', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(52, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(53, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(53, 100, 1, 'prisma', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(55, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(56, 20, 0.017, 'no shape', 247, 0.55, 0.03, 0.36, 0.25, 0.61, 48.4),
	(57, 54, 0.015, 'no shape', 356, 0.5, 0.05, 0.39, 0.37, 0.76, 49.4),
	(58, 90, 0.022, 'no shape', 363, 0.31, 0.1, 0.46, 0.37, 0.83, 50.2),
	(59, 95, 0.03, 'no shape', 422, 0.38, 0.12, 0.55, 0.46, 1.01, 49.8),
	(60, 100, 0.041, 'no shape', 418, 0.43, 0.12, 0.56, 0.47, 1.03, 47.6),
	(61, 100, 0.062, 'no shape', 412, 0.44, 0.12, 0.57, 0.5, 1.07, 48.8),
	(79, 90, 0.0197, 'sphere', 486, 0.67, NULL, 0.247, 0.316, 0.563, NULL),
	(82, 95, 0.0198, 'sphere', 480, 0.56, NULL, 0.246, 0.293, 0.539, NULL),
	(85, 95, 0.0202, 'sphere', 477, 0.47, NULL, 0.258, 0.263, 0.521, NULL),
	(86, 95, 0.0214, 'sphere', 405, 0.36, NULL, 0.244, 0.193, 0.437, NULL),
	(87, 95, 0.0238, 'sphere', 396, 0.22, NULL, 0.242, 0.183, 0.425, NULL),
	(88, NULL, 2, 'hexagonal', 248, 0.16, 0.09, NULL, NULL, NULL, NULL),
	(89, NULL, NULL, NULL, 325, 0.55, 0.12, NULL, NULL, NULL, NULL),
	(90, 98.5, 0.23, 'sphere', 480, 0.367, NULL, NULL, NULL, NULL, 102),
	(91, 94, 0.234, 'hexagonal', 459, 0.357, NULL, NULL, NULL, NULL, 110),
	(92, 96.6, 0.255, 'hexagonal', 458, 0.357, NULL, NULL, NULL, NULL, 113),
	(93, 100, 0.26, 'hexagonal', 450, 0.361, NULL, NULL, NULL, NULL, 114),
	(94, 43.5, 0.06, 'sphere', 478, 0.51, NULL, NULL, NULL, NULL, 243),
	(95, NULL, 0.025, NULL, 393, 0.35, 0.15, NULL, NULL, NULL, 16.5),
	(96, NULL, 0.035, 387, 0.22, NULL, NULL, NULL, NULL, NULL, NULL),
	(97, NULL, 0.035, 370, 0.17, NULL, NULL, NULL, NULL, NULL, NULL),
	(98, NULL, 0.01, 398, 0.22, NULL, NULL, NULL, NULL, NULL, NULL),
	(99, NULL, 0.01, 395, 0.19, NULL, NULL, NULL, NULL, NULL, NULL),
	(101, NULL, NULL, 395, 0.35, NULL, NULL, NULL, NULL, NULL, NULL),
	(102, NULL, NULL, 396, 0.41, NULL, NULL, NULL, NULL, NULL, NULL),
	(103, 115, NULL, 'no shape', 382, NULL, NULL, NULL, NULL, 0.33, 70),
	(104, 90, NULL, 'no shape', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(105, 92, NULL, 'no shape', 362, NULL, NULL, NULL, NULL, 0.24, 70),
	(106, 92, 0.31, 'no shape', 250, NULL, NULL, NULL, NULL, NULL, NULL),
	(107, 98, 0.26, 'no shape', 280, NULL, NULL, NULL, NULL, NULL, NULL),
	(108, 94, 0.280, 'no shape', 250, NULL, NULL, NULL, NULL, NULL, NULL),
	(111, 95, 0.71, 'no shape', 240, NULL, NULL, NULL, NULL, NULL, NULL),
	(112, NULL, 0.2, 'sphere', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(113, NULL, NULL, NULL, 440, 0.208, 0.169, NULL, NULL, NULL, 5),
	(114, NULL, NULL, NULL, 387, 0.198, 0.187, NULL, NULL, NULL, 5.1);
   


