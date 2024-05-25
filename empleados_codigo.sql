CREATE DATABASE IF NOT EXISTS clean;

USE clean;

Select * from limpieza;

ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_emp varchar(20) null;

SELECT Id_emp, COUNT(*) AS cantidad_duplicados
FROM limpieza
GROUP BY Id_emp  
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS cantidad_duplicados
FROM (
    SELECT Id_emp
    FROM limpieza
    GROUP BY Id_emp
    HAVING COUNT(*) > 1
) AS subquery;

RENAME TABLE limpieza TO conduplicados;

CREATE TEMPORARY TABLE temp_limpieza AS 									
SELECT DISTINCT *  FROM conduplicados; 	

SELECT COUNT(*) AS original FROM conduplicados;
SELECT COUNT(*) AS temporal FROM temp_limpieza;

CREATE TABLE limpieza AS
SELECT * FROM temp_limpieza;

SELECT COUNT(*) AS cantidad_duplicados
FROM (
    SELECT Id_emp
    FROM conduplicados
    GROUP BY Id_emp
    HAVING COUNT(*) > 1
) AS subquery;

DROP TABLE conduplicados;

SET sql_safe_updates = 0;  

ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar(20) null;
ALTER TABLE limpieza CHANGE COLUMN Apellido Last_name varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date Start_date varchar(50) null;

DESCRIBE limpieza;

SELECT Name FROM limpieza WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0; 

SELECT name, TRIM(name) AS Name
FROM limpieza
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

UPDATE limpieza
SET name = TRIM(name)
WHERE LENGTH(name) - LENGTH(TRIM(name)) > 0;

SELECT last_name, TRIM(Last_name) AS Last_name 
FROM limpieza
WHERE LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;

UPDATE limpieza
SET last_name = TRIM(Last_name)
WHERE LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;

UPDATE limpieza SET area = REPLACE(area, ' ', '       '); 

SELECT area FROM limpieza 
WHERE area REGEXP '\\s{2,}';  

Select area, TRIM(REGEXP_REPLACE(area, '\\s+', ' ')) as ensayo 
FROM limpieza; 

UPDATE limpieza SET area = TRIM(REGEXP_REPLACE(area, '\\s+', ' '));

SELECT gender,  
CASE
    WHEN gender = 'hombre' THEN 'Male'
    WHEN gender = 'mujer' THEN 'Female'
    ELSE 'Other'
END as gender1
FROM limpieza;

UPDATE Limpieza
SET Gender = CASE
    WHEN gender = 'hombre' THEN 'Male'
    WHEN gender = 'mujer' THEN 'Female'
    ELSE 'Other'
END;

ALTER TABLE limpieza MODIFY COLUMN Type TEXT;

SELECT type,
CASE 
	WHEN type = 1 THEN 'Remote'
    WHEN type = 0 THEN 'Hybrid'
    ELSE 'Other'
END as ejemplo
FROM limpieza;

UPDATE limpieza
SET Type = CASE
	WHEN type = 1 THEN 'Remote'
    WHEN type = 0 THEN 'Hybrid'
    ELSE 'Other'
END;

SELECT salary,  CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL(15, 2)) from limpieza;

UPDATE limpieza SET salary = CAST(TRIM(REPLACE(REPLACE(salary, '$', ''), ',', '')) AS DECIMAL(15, 2));

SELECT birth_date FROM limpieza;

SELECT birth_date, CASE
    WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END AS new_birth_date
FROM limpieza;

UPDATE limpieza
SET birth_date = CASE
	WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE limpieza MODIFY COLUMN birth_date date;

SELECT start_date FROM limpieza;

SELECT start_date, CASE
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END AS new_start_date
FROM limpieza;

UPDATE limpieza
SET start_date = CASE
	WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date, '%m/%d/%Y'),'%Y-%m-%d')
    WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date, '%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE limpieza MODIFY COLUMN start_date DATE;

SELECT finish_date FROM limpieza;

SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza;
SELECT finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') AS fecha FROM limpieza;
SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd FROM limpieza;
SELECT  finish_date, str_to_date(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza;
SELECT  finish_date, date_format(finish_date, '%H:%i:%s') AS hour_stamp FROM limpieza;

SELECT finish_date,
    date_format(finish_date, '%H') AS hora,
    date_format(finish_date, '%i') AS minutos,
    date_format(finish_date, '%s') AS segundos,
    date_format(finish_date, '%H:%i:%s') AS hour_stamp
FROM limpieza;

ALTER TABLE limpieza ADD COLUMN date_backup TEXT;
UPDATE limpieza SET date_backup = finish_date;

SELECT finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') AS formato FROM limpieza;

UPDATE limpieza
	SET finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC') 
	WHERE finish_date <> '';

ALTER TABLE limpieza
	ADD COLUMN fecha DATE,
	ADD COLUMN hora TIME;

UPDATE limpieza
SET fecha = DATE(finish_date),
    hora = TIME(finish_date)
WHERE finish_date IS NOT NULL AND finish_date <> '';

UPDATE limpieza SET finish_date = NULL WHERE finish_date = '';

ALTER TABLE limpieza MODIFY COLUMN finish_date DATETIME;

SELECT * FROM limpieza; 

ALTER TABLE limpieza ADD COLUMN age INT;

SELECT name,birth_date, start_date, TIMESTAMPDIFF(YEAR, birth_date, start_date) AS edad_de_ingreso
FROM limpieza;

UPDATE limpieza
SET age = timestampdiff(YEAR, birth_date, CURDATE()); 

SELECT CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com') AS email FROM limpieza;

ALTER TABLE limpieza
ADD COLUMN email VARCHAR(100);

UPDATE limpieza 
SET email = CONCAT(SUBSTRING_INDEX(Name, ' ', 1),'_', SUBSTRING(Last_name, 1, 4), '.',SUBSTRING(Type, 1, 1), '@consulting.com'); 

SELECT * FROM limpieza
WHERE finish_date <= CURDATE() OR finish_date IS NULL
ORDER BY area, Name;

SELECT area, COUNT(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;