/* Задание 1
Установите СУБД MySQL. 
Создайте в домашней директории файл .my.cnf, 
задав в нем логин и пароль, который указывался при установке.*/

--в файле .my.cnf прописала:
[mysql]
user=root
password=...

Пароль больше не спрашивает:

valery@valery-System-Product-Name:~/Документы/SQL/Homeworks_sql$ sudo mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 15
Server version: 8.0.28-0ubuntu0.20.04.3 (Ubuntu)

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql> exit
Bye 

/*
Задание 2
Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.*/

CREATE DATABASE IF NOT EXISTS example;
USE example;
CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(255) COMMENT 'Имя пользователя');

/* Задание 3
Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.*/
-- предварительно создадим пустую базу данных sample

create database sample;

-- создадим дамп и проверим, что появился соответствующий файл

valery@valery-System-Product-Name:~$ sudo mysqldump example > sample.sql
valery@valery-System-Product-Name:~$ ls
 PycharmProjects   snap    Документы   Изображения   Общедоступные   Шаблоны
 sample.sql        Видео   Загрузки    Музыка       'Рабочий стол'

-- развернём дамп и проверим, что всё сработало
 
valery@valery-System-Product-Name:~$ sudo mysql sample < sample.sql
valery@valery-System-Product-Name:~$ sudo mysql
mysql> use sample
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> describe users;
+-------+-----------------+------+-----+---------+----------------+
| Field | Type            | Null | Key | Default | Extra          |
+-------+-----------------+------+-----+---------+----------------+
| id    | bigint unsigned | NO   | PRI | NULL    | auto_increment |
| name  | varchar(255)    | YES  |     | NULL    |                |
+-------+-----------------+------+-----+---------+----------------+
2 rows in set (0,00 sec)

/*Задание 4
Ознакомьтесь более подробно с документацией утилиты mysqldump. 
Создайте дамп единственной таблицы help_keyword базы данных mysql. 
Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.
*/

--сделаем дамп и убедимся, что появился соответвтсвующий файл:
valery@valery-System-Product-Name:~$ sudo mysqldump --opt --where="1 limit 100" mysql help_keyword > help_keyword.sql
valery@valery-System-Product-Name:~$ ls
 help_keyword.sql   snap        Загрузки      Общедоступные
 PycharmProjects    Видео       Изображения  'Рабочий стол'
 sample.sql         Документы   Музыка        Шаблоны
 
valery@valery-System-Product-Name:~$ wc -l help_keyword.sql 
53 help_keyword.sql
