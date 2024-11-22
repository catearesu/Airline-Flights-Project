use Flights;
SELECT * FROM flights;
-- ME DICE EL DÍA DE LA SEMANA
SELECT *,
    CASE
		WHEN DAY_OF_WEEK = 1
			THEN "Sunday"
		WHEN DAY_OF_WEEK = 2
			THEN "Monday"
		WHEN DAY_OF_WEEK = 3
			THEN "Tuesday" 
		WHEN DAY_OF_WEEK = 4
			THEN "Wednesday"
		WHEN DAY_OF_WEEK = 5
			THEN "Thursday"
		WHEN DAY_OF_WEEK = 6
			THEN "Friday"
		ELSE "Saturday"
	END as day_of_the_week
FROM flights;
-- CTE
/* WITH day_of_the_week AS (
	SELECT DAY_OF_WEEK,
		CASE
			WHEN DAY_OF_WEEK = 1
				THEN "Sunday"
			WHEN DAY_OF_WEEK = 2
				THEN "Monday"
			WHEN DAY_OF_WEEK = 3
				THEN "Tuesday" 
			WHEN DAY_OF_WEEK = 4
				THEN "Wednesday"
			WHEN DAY_OF_WEEK = 5
				THEN "Thursday"
			WHEN DAY_OF_WEEK = 6
				THEN "Friday"
			ELSE "Saturday"
		END as day_name
	FROM flights
) */


-- CÓMO EVOLUCIONA EL NÚMERO DE VUELOS SEGÚN EL MES? Y EL DÍA?
SELECT MONTH, count(*)
FROM flights
GROUP BY MONTH
ORDER BY count(*) DESC; 
-- los meses en los que operan más vuelos son Julio, Agosto, Junio y Marzo
-- Febrero, Septiembre y Noviembre son los meses con menos vuelos

SELECT day_name, COUNT(*) AS total_flights
FROM (SELECT 
		CASE
			WHEN DAY_OF_WEEK = 1 THEN "Sunday"
			WHEN DAY_OF_WEEK = 2 THEN "Monday"
			WHEN DAY_OF_WEEK = 3 THEN "Tuesday" 
			WHEN DAY_OF_WEEK = 4 THEN "Wednesday"
			WHEN DAY_OF_WEEK = 5 THEN "Thursday"
			WHEN DAY_OF_WEEK = 6 THEN "Friday"
			ELSE "Saturday"
		END AS day_name
	FROM flights) AS day_names
GROUP BY day_name
ORDER BY count(*) desc;
-- los días con más vuelos son Miércoles, Domingo y Jueves
-- el dia con menos vuelos es el viernes, con bastante diferencia respecto al resto

-- CUAL ES LA AEROLINEA CON MÁS VUELOS?
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY COUNT(*) DESC;
-- SOUTWEST AIRLINES CON 32486

-- QUIERO HACER UN RANKING POR AERLINEA DE CANCELACIONES Y RETRASOS

-- CUAL ES EL AEROPUERTO CON MÁS TRÁFICO AÉREO?
SELECT a.AIRPORT, a.CITY, a.STATE
	, COUNT(*) AS total_flights
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE
GROUP BY a.AIRPORT, a.CITY, a.STATE
HAVING AIRPORT regexp '^[A-Za-z]'
ORDER BY COUNT(*) DESC;
-- El de Atlanta, seguido por el de Chicago y Dallas

-- CUANTOS VUELOS FUERON CANCELADOS EN 2015? 
-- QUE PORCENTAJE FUE DEBIDO AL MAL TIEMPO? 
-- QUE PORCENTAJE FUE DEBIDO A LA AEROLINEA?
SELECT CANCELLED, COUNT(CANCELLED)
FROM flights
GROUP BY CANCELLED; -- me muestra cuantos vuelos se han cancelado (2313) y cuantos no (147687)

SELECT COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights; -- me muestra el total de vuelos, cuantos hay cancelados y el porcentaje de cancelados (1.54%)

SELECT 
    c.CANCELLATION_DESCRIPTION
    ,COUNT(*) AS total_cancelaciones
	,ROUND((COUNT(*) / (SELECT COUNT(*) FROM flights WHERE cancelled = 1) * 100), 2) AS porcentaje_cancelaciones
FROM flights f
LEFT JOIN cancellation_codes c
ON f.CANCELLATION_REASON = c.CANCELLATION_REASON
WHERE CANCELLED = 1
GROUP BY c.CANCELLATION_DESCRIPTION
ORDER BY total_cancelaciones DESC; -- me muestra el motivo, el total de cancelaciones y el porcentaje de cancelaciones por motivo
-- el 54.35% de las cancelaciones fue debido por el mal tiempo
-- el 28.71% fue por causa de la aerolinea
-- el 16.95% se debió al National Air System

-- CANCELACIONES POR AEROLINEA
-- vuelos cancelados por aerolinea en porcentaje a los vuelos totales operados por esa aerolinea
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY porcentaje_cancelaciones DESC;
-- la aerolinea con más vuelos cancelados con respecto a su totalidad de vuelos es AMERICAN EAGLE AIRLINES (4,81% de sus vuelos cancelados)

-- CANCELACIONES POR AEROPUERTO
SELECT a.AIRPORT, a.CITY, a.STATE
	, COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE
GROUP BY a.AIRPORT, a.CITY, a.STATE
ORDER BY porcentaje_cancelaciones DESC;
-- el top 3 de aeropuertos con más cancelaciones por vuelos operados son: 
-- SAWYER INTERNATIONAL AIRPORT, DEL NORTE COUNTRY AIRPORT, DEVILS LAKE REGIONAL AIRPORT


-- CANCELACIONES POR ESTADO
SELECT a.STATE
	, COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE
GROUP BY a.STATE
HAVING STATE regexp '^[A-Za-z]'
ORDER BY porcentaje_cancelaciones DESC;

-- miramos en qué mes o qué día de la semana se han producido más cancelaciones
WITH day_names AS (
    SELECT DAY_OF_WEEK,
        CASE     
            WHEN DAY_OF_WEEK = 1 THEN "Sunday"
            WHEN DAY_OF_WEEK = 2 THEN "Monday"
            WHEN DAY_OF_WEEK = 3 THEN "Tuesday" 
            WHEN DAY_OF_WEEK = 4 THEN "Wednesday"
            WHEN DAY_OF_WEEK = 5 THEN "Thursday"
            WHEN DAY_OF_WEEK = 6 THEN "Friday"
            ELSE "Saturday"
        END AS day_name
    FROM flights
)
SELECT 
    MONTH,
    day_name,
    COUNT(*) AS total_cancelaciones
WHERE f.CANCELLED = 1
GROUP BY MONTH, day_name
ORDER BY total_cancelaciones DESC;


-- MESES agrupando solo por mes veo que Febrero, Enero y Marzo son los meses en los que se cancelan más vuelos
SELECT 
    MONTH
    , count(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights
GROUP BY MONTH
ORDER BY porcentaje_cancelaciones DESC;

-- DÍAS agrupando solo por día de la semana veo que Domingo, Lunes, Miércoles y Sábado son los días en los que se cancelan más vuelos
SELECT
    DAY_OF_WEEK
    , COUNT(*)
	, SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights
GROUP BY DAY_OF_WEEK
ORDER BY porcentaje_cancelaciones DESC;
-- agrupo por día de la semana y comparo las cancelaciones de cada día de la semana con los vuelos operados en ese mismo día
SELECT
    CASE
		WHEN DAY_OF_WEEK = 1
			THEN "Sunday"
		WHEN DAY_OF_WEEK = 2
			THEN "Monday"
		WHEN DAY_OF_WEEK = 3
			THEN "Tuesday" 
		WHEN DAY_OF_WEEK = 4
			THEN "Wednesday"
		WHEN DAY_OF_WEEK = 5
			THEN "Thursday"
		WHEN DAY_OF_WEEK = 6
			THEN "Friday"
		ELSE "Saturday"
	END as day_of_the_week
    , COUNT( CASE WHEN CANCELLED = 1 THEN 1 END) AS total_cancelaciones
    , COUNT(*) as total_flights
    , ROUND((COUNT(CASE WHEN CANCELLED =1 THEN 1 END)*100)/COUNT(*),2) AS porcentaje_cancelaciones
FROM flights
GROUP BY DAY_OF_WEEK
ORDER BY total_cancelaciones DESC;

-- DELAYS
-- vuelos atrasados (delay llegada-salida) por aerolinea en porcentaje a los vuelos totales operados por esa aerolinea
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
    , SUM(CASE WHEN (ARRIVAL_DELAY + DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END) as flights_delayed
    , ROUND(SUM(CASE WHEN (ARRIVAL_DELAY + DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100,2) as porcentaje_atrasos
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY porcentaje_atrasos desc;

-- JUNTO LAS 2 TABLAS, CANCELACIONES Y ATRASOS
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
    , SUM(CASE WHEN (ARRIVAL_DELAY + DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END) as flights_delayed
    , ROUND(SUM(CASE WHEN (ARRIVAL_DELAY + DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100,2) as porcentaje_atrasos
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE;

-- CALCULAR LA MEDIA DE RETRASO Y CATEGORIZAR EL RETRASO EN LA SALIDA O EN LA LLEGADA
SELECT a.AIRLINE, COUNT(*) AS total_flights
			,SUM(CASE WHEN (DEPARTURE_DELAY + ARRIVAL_DELAY) > 0 THEN 1 ELSE 0 END) AS flights_delayed
			,ROUND((SUM(CASE WHEN (DEPARTURE_DELAY + ARRIVAL_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
			,ROUND((AVG(CASE WHEN (DEPARTURE_DELAY + ARRIVAL_DELAY) > 0 THEN DEPARTURE_DELAY + ARRIVAL_DELAY ELSE 0 END)),2) AS media_retraso_total  -- Media de retraso total (en minutos)
			,ROUND((AVG(CASE WHEN DEPARTURE_DELAY > 0 THEN DEPARTURE_DELAY ELSE 0 END)),2) AS media_retraso_salida  -- Media de retraso en la salida
			,ROUND((AVG(CASE WHEN ARRIVAL_DELAY > 0 THEN ARRIVAL_DELAY ELSE 0 END)),2) AS media_retraso_llegada -- Media de retraso en la llegada
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY media_retraso_total DESC;

-- QUE PORCENTAJE DE VUELOS HAN TENIDO UN RETRASO EN LA SALIDA? CUAL HA SIDO EL RETRASO MEDIO?
SELECT a.AIRLINE, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos_salida
			,ROUND((AVG(CASE WHEN DEPARTURE_DELAY > 0 THEN DEPARTURE_DELAY ELSE 0 END)),2) AS media_retraso_salida  -- Media de retraso en la salida
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY media_retraso_salida DESC;

SELECT a.AIRLINE, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos_llegada
			,ROUND((AVG(CASE WHEN ARRIVAL_DELAY > 0 THEN ARRIVAL_DELAY ELSE 0 END)),2) AS media_retraso_llegada  -- Media de retraso en la salida
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY media_retraso_llegada DESC;

-- How does the % of delayed flights vary throughout the year? 
-- What about for flights leaving from Boston (BOS) specifically?
SELECT MONTH, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN ARRIVAL_DELAY + DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
FROM flights f 
GROUP BY MONTH
ORDER BY porcentaje_atrasos DESC; -- el delay se mantiene más o menos en 35% a lo largo de los meses, CON UN PICO DE 43% EN JUNIO

-- y según el día
SELECT DAY_OF_WEEK, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
FROM flights f 
GROUP BY DAY_OF_WEEK
ORDER BY porcentaje_atrasos DESC; -- el Miércoles y jueves son los días con más retrasos

-- retrasos en la salida según aeropuerto de salida
SELECT AIRPORT,CITY, STATE
			,COUNT(*) AS total_flights
			,SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE 
WHERE CITY = "Boston"
GROUP BY a.AIRPORT, a.CITY, a.STATE
ORDER BY porcentaje_atrasos DESC;

-- retrasos en la llegada según aeropuerto de salida
SELECT AIRPORT,CITY, STATE
			,COUNT(*) AS total_flights
			,SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed
			,ROUND((SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE 
WHERE CITY = "Boston"
GROUP BY a.AIRPORT, a.CITY, a.STATE

ORDER BY porcentaje_atrasos DESC;


-- QUE AEROLINEAS PARECEN SER MÁS FIABLES Y CUALES MENOS EN TERMINOS DE SALIDAS A TIEMPO?
-- MÁS FIABLES vuelos que no tienen retraso en la salida y vuelos que no tengan cancelaciones
SELECT 
    a.AIRLINE,
    COUNT(*) AS total_flights,
    COUNT(CASE WHEN DEPARTURE_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) AS vuelos_a_tiempo,
    ROUND(
        (COUNT(CASE WHEN DEPARTURE_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_a_tiempo
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY porcentaje_a_tiempo DESC;

-- QUE AEROLINEAS PARECEN SER MÁS FIABLES Y CUALES MENOS EN TERMINOS DE LLEGADAS A TIEMPO?
SELECT 
    a.AIRLINE,
    COUNT(*) AS total_flights,
    COUNT(CASE WHEN ARRIVAL_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) AS vuelos_a_tiempo,
    ROUND(
        (COUNT(CASE WHEN ARRIVAL_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_a_tiempo
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY porcentaje_a_tiempo DESC;

-- JUNTO LLEGADAS CON SALIDAS
SELECT 
    a.AIRLINE
    ,COUNT(*) AS total_flights
    ,COUNT(CASE WHEN DEPARTURE_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) AS salidas_a_tiempo
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_salidas_a_tiempo
    ,COUNT(CASE WHEN ARRIVAL_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) AS llegadas_a_tiempo
    ,ROUND((COUNT(CASE WHEN ARRIVAL_DELAY <= 0 AND CANCELLED = 0 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_llegadas_a_tiempo
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY porcentaje_salidas_a_tiempo DESC, porcentaje_llegadas_a_tiempo DESC;

-- HORARIO DE SALIDA PROGRAMADA DE LOS VUELOS QUE TIENEN RETRASO/CANCELACIÓN

-- RETRASOS HEAVYS
SELECT a.AIRLINE 
    ,COUNT(*) AS total_flights
    ,COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 0 AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 60 THEN 1 END) AS RETRASO_LEVE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 0 AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 60 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_BREVES
    ,COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 60  AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 120 THEN 1 END) AS RETRASO_MODERADO
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 60 AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 120 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_MODERADOS
    ,COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 120  AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 180 THEN 1 END) AS RETRASO_FUERTE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 120 AND DEPARTURE_DELAY + ARRIVAL_DELAY <= 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_FUERTES
    ,COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 180 THEN 1 END) AS RETRASO_HEAVY
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY + ARRIVAL_DELAY > 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_HEAVY
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE;

-- POR DISTANCIA
SELECT DISTANCE, DEPARTURE_DELAY, ARRIVAL_DELAY FROM flights
WHERE DEPARTURE_DELAY > 120 OR ARRIVAL_DELAY > 120
GROUP BY DISTANCE
ORDER BY DISTANCE DESC;


