-- ====================================================================
-- PROYECTO FINAL: ANÁLISIS DE RETENCIÓN BANCARIA (SQL AVANZADO)

-- 🟢 BLOQUE 1: DIFICULTAD BÁSICA 
-- Pregunta 1: ¿Cuál es el volumen total de registros,
--el total de clientes únicos  y el saldo acumulado en el banco?
select count(Id_cliente) total_de_registros,
		count( distinct (Id_cliente)) total_clientes_unicos,
		sum(Balance) saldo_acumulado
from train;

-- Pregunta 2: ¿Cuál es la distribución de clientes y el conteo de abandono por cada país? 
--Ordenar de mayor a menor fuga.
select 
    País,
    count(distinct Id_cliente) as Total_Clientes,
    sum(case when Estado_Cliente = 'Abandona' then 1 else 0 end) as Total_Fugados
from train
group by País
order by Total_Fugados desc;


-- Pregunta 3: ¿Cuál es el salario mínimo, máximo y el promedio redondeado a cero decimales por cada género?

select 
    Género,
    min(Salario) as salario_minimo,
    max(Salario) as salario_maximo,
    round(avg(Salario), 0) as salario_promedio
from train
group by Género;

-- Pregunta 4: Clientes de Francia/España con Puntaje_Crediticio entre 350 y 500 fugados
--y que correspondan a cuentas que ya abandonaron el banco.

select Id_cliente, Apellido, País, Puntaje_Crediticio, Salario
from train
where País in ('Francia', 'España') 
  and Puntaje_Crediticio between 350 and 500 
  and Estado_Cliente = 'Abandona';

-- Pregunta 5: Obtener una lista de los IDs de clientes únicos mayores de 60 años que sean considerados miembros inactivos ,
--ordenados por edad de forma descendente.

select distinct Id_cliente, Apellido, Edad, Miembros
from train
where Edad > 60 
  and Miembros = 'Inactivo'
order by Edad desc;



-- 🟡 BLOQUE 2: DIFICULTAD INTERMEDIA 

-- Pregunta 6: Utilizar la columna limpia de Clasificacion_Credito para mostrar 
--cuántos clientes totales pertenecen a cada categoría del banco, ordenados de mayor a menor cantidad.

select 
    Clasificacion_Credito,
    count(*) as cantidad_clientes
from train
group by Clasificacion_Credito
order by cantidad_clientes desc;

-- Pregunta 7: Por cada cantidad de productos, calcular el total de clientes y el porcentaje exacto de abandono 
--aplicando un casteo para asegurar los decimales en la operación.

select 
    Numero_Producto,
    count(*) as Total_Clientes,
    sum(case when Estado_Cliente = 'Abandona' then 1 else 0 end) as Clientes_Fugados,
    round((sum(case when Estado_Cliente = 'Abandona' then 1.0 else 0.0 end) / count(*)) * 100, 2) as Porcentaje_Fuga
from train
group by Numero_Producto
order by Numero_Producto;

-- Pregunta 8: Agrupar los clientes por sus años de permanencia (Tenencia) y mostrar únicamente aquellos grupos donde el conteo de clientes
--que abandonaron el banco sea estrictamente mayor a 3,000 registros.

select 
    Tenencia,
    sum(case when Estado_Cliente = 'Abandona' then 1 else 0 end) as Total_Fugados
from train
group by Tenencia
having sum(case when Estado_Cliente = 'Abandona' then 1 else 0 end) > 3000
order by Tenencia;


-- Pregunta 9: Analizar el rango salarial de los clientes que abandonaron según sus años de permanencia
select 
    Tenencia,
    count(*) as Total_Clientes,
    max(Salario) as Salario_Maximo,
    min(Salario) as Salario_Minimo,
    avg(Salario) as Salario_Promedio
from train
where Estado_Cliente = 'Abandona'
group by Tenencia
order by Tenencia;


-- Pregunta 10: Analizar el comportamiento financiero según la clasificación crediticia
-- Ver el promedio de saldo y puntaje de crédito por cada categoría.
select 
    Clasificacion_Credito,
    count(*) as Total_Clientes,
    avg(Balance) as Balance_Promedio,
    avg(Puntaje_Crediticio) as Puntaje_Promedio
from train
group by Clasificacion_Credito
order by avg(Balance) desc;


-- ====================================================================
-- 🔴 BLOQUE 3: DIFICULTAD AVANZADA 
-- ====================================================================

-- Pregunta 11: Ranking de los saldos más altos de los clientes que abandonaron por cada país 
-- 
with ranking_saldos as (
    select 
        Id_cliente,
        Apellido,
        País,
        Balance,
        row_number() over (partition by País order by Balance desc) as posicion
    from train
    where Estado_Cliente = 'Abandona'
)
select Id_cliente, Apellido, País, Balance, posicion
from ranking_saldos
where posicion <= 3;


-- Pregunta 12: Comparación del saldo individual contra el promedio global de su propio país

with saldos_por_pais as (
    select 
        País as pais_tabla,
        avg(Balance) as balance_promedio
    from train
    group by País
)
select top 100
    Id_cliente,
    Apellido,
    País,
    Balance,
    round(balance_promedio, 2) as Balance_Promedio_Pais,
    round(Balance - balance_promedio, 2) as Diferencia_Individual
from train
inner join saldos_por_pais on País = pais_tabla;


-- Pregunta 13: Agrupación avanzada de riesgo de fuga según el número de productos financieros
-- Calcular cuántos clientes se fueron, sus saldos acumulados y puntajes promedio según sus productos activos.
select 
    Numero_Producto,
    count(*) as Total_Clientes,
    avg(Puntaje_Crediticio) as Puntaje_Promedio,
    sum(Balance) as Balance_Total_Perdido
from train
where Estado_Cliente = 'Abandona'
group by Numero_Producto;


-- Pregunta 14: Identificar los IDs de clientes comunes con perfil financiero excelente y alta liquidez 
-- Operador de conjuntos avanzado para cruzar dos segmentos de forma directa y clara.
select Id_cliente from train where Puntaje_Crediticio > 750
intersect
select Id_cliente from train where Balance > 150000;


-- Pregunta 15: El Reporte Gerencial Maestro
-- Unificar métricas globales en una sola consulta avanzada con lógica condicional pura.
select 
    count(distinct Id_cliente) as Total_Clientes_Unicos,
    sum(case when Estado_Cliente = 'Abandona' then Balance else 0 end) as Total_Capital_Perdido,
    avg(Salario) as Salario_Promedio_General
from train;