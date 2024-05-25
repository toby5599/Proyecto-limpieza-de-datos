
Crear una base de datos:

```sql
create database if not exists clean;
```

Luego importamos el archivo:

![[Pasted image 20240314211936.png]]

![[Pasted image 20240314212049.png]]

Como vemos los datos vienen sucios:

![[Pasted image 20240314212139.png]]

## Objetivos
---
- **Estandarizar del idioma**: convertir todos los registros al idioma inglés para mantener la coherencia lingüística.
- **Corrección de encabezados**: revisar y corregir los nombres de los encabezados para asegurar que sean claron y descriptivos
- **Formateo de fechas**: ajustar las fechas para que estén en un formato de fecha adecuado en lugar de estar en formato de texto.
- **Formato del salario**: asegurarse de que el campo de salario esté en el formato numérico adecuado, eliminando cualquier formato de texto que pueda existir.
- **Eliminación de espacios extras en nombres**: detectar y eliminar los espacios adicionales en los nombres para mantener la consistencia y precisión en los registros.


Información de la tabla:

![[Pasted image 20240314213530.png]]

## Renombrar los nombres de las columnas con caracteres especiales
---

Para renombrar una columna:

```sql
ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` Id_emp varchar (20) null;
```

## Verificar si hay registros duplicados
---

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
---

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

![[Pasted image 20240314224233.png]]

Seleccionamos nuestra tabla temporal y observamos los siguientes puntos:
1. Los valores duplicados han sido eliminados correctamente.
2. Faltan nueve filas en la tabla.

```sql
select count(*) as original from temp_limpieza;
```

![[Pasted image 20240314224403.png]]

### Convertir la tabla temporal a permanente

```sql
create table limpieza as select * from temp_limpieza;
```

![[Pasted image 20240314224855.png]]

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
---

Para desactivar el modo seguro que SQL trae por defecto y permitir realizar modificaciones, puedes utilizar el siguiente código:

```sql
set sql_safe_updates = 0;
```

## Renombrar los nombres de las columnas
---

```sql
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` Gender varchar(20) null;
ALTER TABLE limpieza CHANGE COLUMN Apellido Last_name varchar(50) null;
ALTER TABLE limpieza CHANGE COLUMN star_date Start_date varchar(50) null;
```


## Revisar los tipos de datos de la tabla
---

```sql
describe limpieza;
```

![[Pasted image 20240314230925.png]]

- Hay fechas con tipo de dato texto.

## Trabajando con texto (strings)
---
### Identificar espacios extra

```sql
select name from limpieza
where length(name) - length(trim(name)) > 0;
```

- ``trim`` se utiliza para eliminar espacios en blanco o caracteres específicos al inicio y/o al final de una cadena de texto.

![[Pasted image 20240314231615.png]]


```sql
select name, trim(name) as name
from limpieza
where length(name) - length(trim(name)) > 0;
```

![[Pasted image 20240314231925.png]]

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

![[Pasted image 20240314233456.png]]

#### Código de ensayo de eliminación de los espacios

```sql
select area, trim(regexp_replace(area, '\\s+', ' ')) as ensayo from limpieza;
```

![[Pasted image 20240314233945.png]]

#### Aplicar los cambios a la tabla

```sql
update limpieza set area = trim(regexp_replace(area, '\\s+', ' '));
```

## Buscar y reemplazar (textos)
---

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

![[Pasted image 20240315005348.png]]

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

![[Pasted image 20240315010556.png|50]]

![[Pasted image 20240315010627.png]]


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

![[Pasted image 20240315012159.png]]

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

![[Pasted image 20240315012432.png]]

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

![[Pasted image 20240315013239.png]]

#### Actulizar la tabla

```sql
update limpieza set salary = cast(trim(replace(replace(salary, '$', ''), ',', '')) as decimal (15,2));
```

#### Modificar el tipo de dato

```sql
alter table limpieza modify column salary int null;
```

## Trabajando con fechas
---

### Dar formato a la fecha

![[Pasted image 20240316100107.png]]

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

![[Pasted image 20240316100511.png]]

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
---

![[Pasted image 20240316101747.png]]

**Objetivo**:
- convertirlo al formato de fecha
- Y sacar UTC

### Prototipo

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') as fecha from limpieza;
```

![[Pasted image 20240316102026.png]]

### Prototipo 2

- Para quedarme con el año, mes y dia, nada mas.

```sql
select finish_date, date_format(str_to_date(finish_date, '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d') as fecha from limpieza;
```

![[Pasted image 20240316102328.png]]

### Para separar solo la fecha

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d') as fd from limpieza;
```

![[Pasted image 20240316103117.png]]

### Separar solo la hora

```sql
select finish_date, date_format(finish_date, '%H:%i:%s') as hour_stamp from limpieza;
```

- Para obtener solo la hora hay que usar ``date_format``, si utilizamos ``str_to_data``, no va a funcionar

![[Pasted image 20240316103139.png]]

### Dividiendo los elementos de la hora en en distintas columnas

```sql
select finish_date,
	date_format(finish_date, '%H') as hora,
    date_format(finish_date, '%i') as minutos,
    date_format(finish_date, '%s') as segundos,
    date_format(finish_date, '%H:%i:%s') as hour_stamp
from limpieza;
```

![[Pasted image 20240316103821.png]]

## Hacer una copia de seguridad de una columna
---

```sql
alter table limpieza add column date_backup text;
```

Para que los elementos sean los mismos

```sql
update limpieza set date_backup = finish_date
```

![[Pasted image 20240316104224.png]]

---

### Renombramos y cambiamos el formato

#### Prototipo

```sql
select finish_date, str_to_date(finish_date, '%Y-%m-%d %H:%i:%s') as fecha from limpieza;
```

![[Pasted image 20240316104519.png]]

#### Actualizar la tabla

```sql
update limpieza set finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')
where finish_date <>'';
```

- <> : significa diferente
- El segundo argumento que termina en UTC tiene que ser igual a la columna original.

![[Pasted image 20240316110424.png]]

### Ahora separar en una columna la fecha y en otra la hora

Primero creamos las columnas:

```sql
alter table limpieza
	add column fecha date,
    add column hora time;
```

![[Pasted image 20240316110759.png]]

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
---

### Conocer la edad de ingresos de nuestros empleados

Primero añadimos una columna para las edades:

```sql
alter table limpieza add column age int;
```

Se calculo: birth_date $-$ start_date

```sql
select name, birth_date, start_date, timestampdiff(year, birth_date, start_date) as edad_de_ingreso from limpieza;
```

![[Pasted image 20240316113052.png]]

- ``timestampdiff()`` : no toma en cuenta los meses y días.

### Calcular la edad de los empleados actualmente

```sql
update limpieza
set age = timestampdiff(year, birth_date, curdate())
```


## Funciones de texto
---

Si queremos crear una columna email donde tome las iniciales del nombre, del apellido y del tipo (hibrido o remoto): 

```sql
select concat(substring_index(name, ' ', 1), '_', substring(last_name, 1,2), '.', substring(type, 1, 1), '@consulting.com') as email from limpieza;
```

- En `(name, ' ', 1)`, se toma el nombre hasta que se encuentra un espacio. El tercer argumento, que es 1, indica que se detiene la búsqueda en la primera ocurrencia de dicho espacio.
- En `(last_name, 1, 2)`, se captura el apellido hasta el segundo carácter.
- `SUBSTRING(type, 1, 1)`: Solo se extrae el primer carácter del campo "type".

![[Pasted image 20240316114919.png]]

Creamos la columna email:

```sql
alter table limpieza add column email varchar(100);
```

Actualizamos la tabla:

```sql
update limpieza set email = concat(substring_index(name, ' ', 1), '_', substring(last_name, 1,2), '.', substring(type, 1, 1), '@consulting.com');
```


## Seleccionamos las columnas que deseamos conservar.
---

```sql
select Id_emp, name, last_name, age, gender, area, salary, email, finish_date from limpieza
where finish_date <= curdate() or finish_date is null
order by area, name;
```

- ``curdate()`` : fecha actual

![[Pasted image 20240316115944.png]]

### Contar la cantidad de empleados que hay en cada area

```sql
select area, count(*) as cantidad_empleados from limpieza
group by area
order by cantidad_empleados desc;
```

![[Pasted image 20240316120426.png]]

## Exportar datos
---

Para exportar la configuración anterior o la de arriba de los empleados, procedemos a:

![[Pasted image 20240316120745.png]]
