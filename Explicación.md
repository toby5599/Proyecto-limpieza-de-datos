# Limpieza de datos


Crear una base de datos:

```sql
create database if not exists clean;
```

Luego importamos el archivo:

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/57d1ca83-11ec-4344-8ffc-c675d8a13779)


![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/67dc421e-daa6-4abb-9fd6-7acd9d186e6b)

Como vemos los datos vienen sucios:

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/0698effa-a00c-42da-b197-861d17729456)


## Objetivos
- **Estandarizar del idioma**: convertir todos los registros al idioma inglés para mantener la coherencia lingüística.
- **Corrección de encabezados**: revisar y corregir los nombres de los encabezados para asegurar que sean claron y descriptivos
- **Formateo de fechas**: ajustar las fechas para que estén en un formato de fecha adecuado en lugar de estar en formato de texto.
- **Formato del salario**: asegurarse de que el campo de salario esté en el formato numérico adecuado, eliminando cualquier formato de texto que pueda existir.
- **Eliminación de espacios extras en nombres**: detectar y eliminar los espacios adicionales en los nombres para mantener la consistencia y precisión en los registros.


Información de la tabla:

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/dd3fcf16-c213-497b-9940-42de02255243)


## Renombrar los nombres de las columnas con caracteres especiales

Para renombrar una columna:

```sql
ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_emp varchar (20) null;
```

## Verificar si hay registros duplicados

```sql
select Id_emp, count(*) as cantidad_duplicados 
from limpieza
group by Id_emp
having count(*) > 1;
```

si queremos contar la cantidad de valores duplicados podemos hacer una **subconsulta**

```sql
select count(*) as cantidad_duplicados
from (x) as subquery
```

En x tenemos que copiar la consulta anterior sin **;**:

```sql
select Id_emp, count(*) as cantidad_duplicados 
from limpieza
group by Id_emp
having count(*) > 1
```

## Crear una tabla temporal con valores únicos y luego hacerla permanente

Para renombrar la tabla:

```sql
rename table limpieza to conduplicados;
```

### Creación de una tabla temporal (sin datos nulos)

Una tabla temporal se caracteriza por su creación y existencia temporal durante la sesión actual de la base de datos. Al cerrar el programa o la sesión de la base de datos, esta tabla se elimina automáticamente.

```sql
create temporary table Temp_limpieza as
select distinct * from conduplicados;
```

Al seleccionar los distintos, va a seleccionar todos los valores no duplicados. Abajo selecciono los valores con duplicados.

```sql
select count(*) as original from conduplicados;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/773409ea-da99-4179-9585-e2f91298286a)


Seleccionamos nuestra tabla temporal y observamos los siguientes puntos:
1. Los valores duplicados han sido eliminados correctamente.
2. Faltan nueve filas en la tabla.

```sql
select count(*) as original from temp_limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/538baa22-3318-4569-879c-94dc33f300d9)


### Convertir la tabla temporal a permanente

```sql
create table limpieza as select * from temp_limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/bebf946f-78b6-4635-a62e-2b32097ad485)


Verificamos si aún hay duplicados nuevamente:

```sql
SELECT COUNT(*) AS cantidad_duplicados
FROM (
    SELECT Id_emp
    FROM conduplicados
    GROUP BY Id_emp
    HAVING COUNT(*) > 1
) AS subquery;
```

Eliminar tabla que contiene los duplicados:

```sql
drop table conduplicados;
```

## Activar/Desactivar modo seguro

Para desactivar el modo seguro que SQL trae por defecto y permitir realizar modificaciones, puedes utilizar el siguiente código:

```sql
set sql_safe_updates = 0;
```

## Renombrar los nombres de las columnas

```sql
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar(20) null;
ALTER TABLE limpieza CHANGE COLUMN Apellido Last_name varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date Start_date varchar(50) null;
```


## Revisar los tipos de datos de la tabla

```sql
describe limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/90d155c1-84ad-469b-946c-ece90c729d1b)


- Hay fechas con tipo de dato texto.

## Trabajando con texto (strings)

### Identificar espacios extra

```sql
select name from limpieza
where length(name) - length(trim(name)) > 0;
```

- ``trim`` se utiliza para eliminar espacios en blanco o caracteres específicos al inicio y/o al final de una cadena de texto.

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/06ac06ca-8cbe-44f9-b8a5-434d518a1b72)



```sql
select name, trim(name) as name
from limpieza
where length(name) - length(trim(name)) > 0;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/ba3ad95d-6b14-4893-981d-1feb0f6b3593)


### Eliminar los espacios extra

**Modificando nombres**: ahora para modicar la tabla con los nombres sin espacios en blanco podemos:

```sql
update limpieza set name = trim(name)
where length(name) - length(trim(name)) > 0;
```

Apellido con espacios:

```sql
SELECT last_name, TRIM(Last_name) AS Last_name 
FROM limpieza
WHERE LENGTH(last_name) - LENGTH(TRIM(last_name)) > 0;
```

**Modificando apellidos**:

```sql
UPDATE limpieza
SET last_name = TRIM(Last_name)
WHERE LENGTH(Last_name) - LENGTH(TRIM(Last_name)) > 0;
```

### ¿Qué sucede si tenemos más de un espacio entre dos palablas?

Esto código es para agregar más espacios:

```sql
update limpieza set area = replace(area, ' ', '    ');
```

Este codigo es para ver que casillas tiene más de un espacio entre dos palabras:

```sql
select area from limpieza
where area regexp '\\s{2,}'
```

``regexp`` : expresion regular

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/a4c9c86b-17b7-473c-934b-cb19d95494ec)


#### Código de ensayo de eliminación de los espacios

```sql
select area, trim(regexp_replace(area, '\\s+', ' ')) as ensayo from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/17bdc27b-27c9-4312-a4bb-422a5e846d28)


#### Aplicar los cambios a la tabla

```sql
update limpieza set area = trim(regexp_replace(area, '\\s+', ' '));
```

## Buscar y reemplazar (textos)

1. Ensayar 
2. Actualizar tabla
3. Modificar propiedad (si es necesario)

Vamos a reemplazar todo al inglés

### Ensayo

```sql
select gender,
case
	when gender = 'hombre' then 'male'
    when gender = 'mujer' then 'female'
    else 'other'
end as gender1
from limpieza;
```
![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/95f7d931-f0ed-417f-b40e-a6ec0cd68190)


### Actualizar la tabla

```sql
update limpieza set gender = case
	when gender = 'hombre' then 'male'
    when gender = 'mujer' then 'female'
    else 'other'
end;
```

---

### Cambiar la propiedad de una columna

Ahora hay que modificar esta columna *type* y que admita texto no números:

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/4d11dea2-d2af-461a-b2a5-f7b3d3b020cd)


![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/b6b09894-864b-44e4-ae4f-eb84c3f8c653)



> [!NOTE] CONSEJO
> `ALTER TABLE limpieza CHANGE COLUMN` : se utiliza para cambiar el nombre de una columna y su tipo de dato.
> `ALTER TABLE limpieza MODIFY COLUMN`: se utiliza para modificar el tipo de datos y otras propiedades de una columna.

```sql
alter table limpieza modify column type text;
```

#### Ensayo

```sql
select type,
case
	when type = 1 then 'remote'
    when type = 0 then 'Hybrid'
    else 'other'
end as ejemplo
from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/ca1701ef-e0fc-4dbc-8b1d-203db699c96d)


#### Actualizar la tabla

```sql
update limpieza
set type = case
	when type = 1 then 'remote'
    when type = 0 then 'Hybrid'
    else 'other'
end;
```

---

### Ajustar formato números

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/3fdbb489-c62b-425b-af98-c8b30ee16c38)


#### Ensayo

consultar: reemplazar $ por un vacío y cambiar el separador de mil por vacío.

```sql
select salary,
	cast(trim(replace(replace(salary, '$', ''), ',', '')) as decimal (15,2)) as salary from limpieza;
```

- ``cast`` : es para agregar decimales
	- cantidad de digitos: 15
	- cantidad de decimales: 2
- ``trim``: si es que hay espacios de más
- ``replace``
	- para eliminar $
	- para eliminar la coma

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/f508da7b-6d36-4682-be33-3fa3d70ebe2f)

#### Actulizar la tabla

```sql
update limpieza set salary = cast(trim(replace(replace(salary, '$', ''), ',', '')) as decimal (15,2));
```

#### Modificar el tipo de dato

```sql
alter table limpieza modify column salary int null;
```

## Trabajando con fechas

### Dar formato a la fecha

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/4cda977f-13d8-4feb-8913-36f38f89b7ce)


#### Ensayo

```sql
select birth_date, case 
	when birth_date like '%/%'then date_format(str_to_date(birth_date, '%m/%d/%y'), '%Y-%m-%d')
	when birth_date like '%-%'then date_format(str_to_date(birth_date, '%m-%d-%y'), '%Y-%m-%d')
	else null
end as new_birth_date
from limpieza;
```

- El símbolo `%` se utiliza porque, por ejemplo, el día puede tener uno o dos dígitos.
- Se utiliza `WHEN` dos veces porque puede haber filas donde la fecha esté separada por un guion u otro delimitador.

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/2fc13506-c611-4012-a471-22274b274934)


#### Actualizar la tabla

```sql
update limpieza
set birth_date = case 
	when birth_date like '%/%'then date_format(str_to_date(birth_date, '%m/%d/%y'), '%Y-%m-%d')
	when birth_date like '%-%'then date_format(str_to_date(birth_date, '%m-%d-%y'), '%Y-%m-%d')
	else null
end;
```

### Cambiar el tipo de datos de la columna

```sql
alter table limpieza modify column birth_date date;
```

## Explorando otras funciones de fecha

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/d6a0cb28-703d-4a53-9d90-4b5cc2ba7005)


**Objetivo**:
- convertirlo al formato de fecha
- Y sacar UTC

### Prototipo

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') as fecha from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/e9288003-4673-4fc9-a6ae-5c9f399db374)


### Prototipo 2

- Para quedarme con el año, mes y dia, nada mas.

```sql
select finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') as fecha from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/7a2270f5-8351-49be-bd9f-e3f211491461)


### Para separar solo la fecha

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d') as fd from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/eb6bea6b-7744-4ce2-9137-87eb60c89eda)


### Separar solo la hora

```sql
select finish_date, date_format(finish_date, '%H:%i:%s') as hour_stamp from limpieza;
```

- Para obtener solo la hora hay que usar ``date_format``, si utilizamos ``str_to_data``, no va a funcionar

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/c87e3d2f-7aa8-4e7e-bc44-65944cf407ea)


### Dividiendo los elementos de la hora en en distintas columnas

```sql
select finish_date,
	date_format(finish_date, '%H') as hora,
    date_format(finish_date, '%i') as minutos,
    date_format(finish_date, '%s') as segundos,
    date_format(finish_date, '%H:%i:%s') as hour_stamp
from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/f17894ab-7525-4b06-8747-090f8aa268c7)


## Hacer una copia de seguridad de una columna

```sql
alter table limpieza add column date_backup text;
```

Para que los elementos sean los mismos

```sql
update limpieza set date_backup = finish_date
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/6972eb48-334e-4234-b0c8-4b5df5a98b21)


---

### Renombramos y cambiamos el formato

#### Prototipo

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') as fecha from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/34a8c1b8-b2c7-4066-8446-1a3c673b4f16)


#### Actualizar la tabla

```sql
update limpieza set finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')
where finish_date <>'';
```

- <> : significa diferente
- El segundo argumento que termina en UTC tiene que ser igual a la columna original.

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/5b893463-ba72-4ef2-863c-05ee5cdff0da)


### Ahora separar en una columna la fecha y en otra la hora

Primero creamos las columnas:

```sql
alter table limpieza
	add column fecha date,
    add column hora time;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/8869cd35-b70e-456a-ac36-fd90991d2012)


Para evitar errores debemos llenar las casillas sin nada con valores *null*:

```sql
update limpieza set finish_date = null where finish_date = ''
```

```sql
update limpieza
set fecha = date(finish_date),
	hora = time(finish_date)
where finish_date is not null and finish_date <> '';
```


> [!NOTE] consejo
> Todas estas operaciones se realizaron utilizando `finish_date`, cuyo formato siempre ha estado en texto y no en ``datetime``. Por lo tanto, ahora vamos a cambiar su formato a ``datetime``, que es el correcto.

```sql
alter table limpieza modify column finish_date datetime;
```

## Calculos con fechas

### Conocer la edad de ingresos de nuestros empleados

Primero añadimos una columna para las edades:

```sql
alter table limpieza add column age int;
```

Se calculo: birth_date $-$ start_date

```sql
select name, birth_date, start_date, timestampdiff(year, birth_date, start_date) as edad_de_ingreso from limpieza;
```

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/4735f1e3-cbca-40f2-8c34-ea1ae45aab35)


- ``timestampdiff()`` : no toma en cuenta los meses y días.

### Calcular la edad de los empleados actualmente

```sql
update limpieza
set age = timestampdiff(year, birth_date, curdate())
```


## Funciones de texto

Si queremos crear una columna email donde tome las iniciales del nombre, del apellido y del tipo (hibrido o remoto): 

```sql
select concat(substring_index(name, ' ', 1), '_', substring(last_name, 1,2), '.', substring(type, 1, 1), '@consulting.com') as email from limpieza;
```

- En `(name, ' ', 1)`, se toma el nombre hasta que se encuentra un espacio. El tercer argumento, que es 1, indica que se detiene la búsqueda en la primera ocurrencia de dicho espacio.
- En `(last_name, 1, 2)`, se captura el apellido hasta el segundo carácter.
- `SUBSTRING(type, 1, 1)`: Solo se extrae el primer carácter del campo "type".

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/89b9e46f-303a-4fe5-a766-ff536daa5fb3)


Creamos la columna email:

```sql
alter table limpieza add column email varchar(100);
```

Actualizamos la tabla:

```sql
update limpieza set email = concat(substring_index(name, ' ', 1), '_', substring(last_name, 1,2), '.', substring(type, 1, 1), '@consulting.com');
```


## Seleccionamos las columnas que deseamos conservar.

```sql
select Id_emp, name, last_name, age, gender, area, salary, email, finish_date from limpieza
where finish_date <= curdate() or finish_date is null
order by area, name;
```

- ``curdate()`` : fecha actual

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/9407f2a2-c843-4fa3-8ff4-b817b9a05ac5)


### Contar la cantidad de empleados que hay en cada area

```sql
select area, count(*) as cantidad_empleados from limpieza
group by area
order by cantidad_empleados desc;
```
![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/edb6e732-8ec7-4a5f-9991-1c633de02306)

## Exportar datos

Para exportar la configuración anterior o la de arriba de los empleados, procedemos a:

![image](https://github.com/toby5599/Proyecto-limpieza-de-datos/assets/131751919/81b6fb47-a2e1-4ec6-a0c3-13cd8003dd6a)

