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

-- CÓMO EVOLUCIONA EL NÚMERO DE VUELOS SEGÚN EL MES? Y EL DÍA?
SELECT MONTH, count(*) AS total_flights
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

-- ANALISIS CANCELACIONES

-- CUÁNTOS VUELOS FUERON CANCELADOS EN 2015? QUÉ PORCENTAJE FUE DEBIDO AL MAL TIEMPO? QUÉ PORCENTAJE FUE DEBIDO A LA AEROLINEA?
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

-- CUAL ES EL PORCENTAJE DE CANCELACIONES DEBIDOS A LA AÉROLINEA SOBRE SU TOTAL DE VUELOS OPERADOS?
SELECT 
    a.AIRLINE
    ,total_flights
    ,SUM(f.CANCELLED) AS flights_cancelled
    ,ROUND((SUM(f.CANCELLED) / total_flights.total_flights) * 100,2) AS porcentaje_cancelaciones
FROM flights f
LEFT JOIN airlines a 
ON f.AIRLINE = a.IATA_CODE
LEFT JOIN cancellation_codes c 
ON f.CANCELLATION_REASON = c.CANCELLATION_REASON
LEFT JOIN (SELECT f.AIRLINE
            ,COUNT(*) AS total_flights
			FROM flights f
			GROUP BY f.AIRLINE
			) AS total_flights 
ON a.IATA_CODE = total_flights.AIRLINE
WHERE c.CANCELLATION_DESCRIPTION = "Airline/Carrier"
GROUP BY a.AIRLINE, total_flights.total_flights
ORDER BY porcentaje_cancelaciones DESC;
-- la aerolinea con mayor porcentaje de vuelos cancelados con motivo "Airline/Carrier" es American Eagle, seguida por Spirit Airlines

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

-- CUAL ES EL PORCENTAJE DE CANCELACIONES POR AEROPUERTO DEBIDOS AL MAL TIEMPO Y NATIONAL AIR SYSTEM SOBRE EL TOTAL DE VUELOS OPERADOS POR ESE AEROPUERTO?
SELECT 
    ap.AIRPORT
    ,total_flights
    ,SUM(f.CANCELLED) AS flights_cancelled
	-- Vuelos cancelados por el motivo "National Air System"
    ,SUM(CASE WHEN c.CANCELLATION_DESCRIPTION = "National Air System" THEN 1 ELSE 0 END) AS national_air_system_cancelled
    -- Vuelos cancelados por el motivo "Weather"
    ,SUM(CASE WHEN c.CANCELLATION_DESCRIPTION = "Weather" THEN 1 ELSE 0 END) AS weather_cancelled
    ,ROUND((SUM(f.CANCELLED) / total_flights.total_flights) * 100,2) AS porcentaje_cancelaciones
FROM flights f
LEFT JOIN airports ap
ON f.ORIGIN_AIRPORT = ap.IATA_CODE
LEFT JOIN cancellation_codes c 
ON f.CANCELLATION_REASON = c.CANCELLATION_REASON
LEFT JOIN (SELECT f.ORIGIN_AIRPORT
            ,COUNT(*) AS total_flights
			FROM flights f
			GROUP BY f.ORIGIN_AIRPORT
			) AS total_flights 
ON ap.IATA_CODE = total_flights.ORIGIN_AIRPORT
WHERE c.CANCELLATION_DESCRIPTION IN ("National Air System", "Weather")
GROUP BY ap.AIRPORT, total_flights.total_flights
ORDER BY porcentaje_cancelaciones DESC;

-- DESGLOSAMOS POR WEATHER
SELECT 
    ap.AIRPORT
    ,ap.STATE
    ,total_flights
    ,SUM(f.CANCELLED) AS flights_cancelled
    ,ROUND((SUM(f.CANCELLED) / total_flights.total_flights) * 100,2) AS porcentaje_cancelaciones
FROM flights f
LEFT JOIN airports ap
ON f.ORIGIN_AIRPORT = ap.IATA_CODE
LEFT JOIN cancellation_codes c 
ON f.CANCELLATION_REASON = c.CANCELLATION_REASON
LEFT JOIN (SELECT f.ORIGIN_AIRPORT
            ,COUNT(*) AS total_flights
			FROM flights f
			GROUP BY f.ORIGIN_AIRPORT
			) AS total_flights 
ON ap.IATA_CODE = total_flights.ORIGIN_AIRPORT
WHERE c.CANCELLATION_DESCRIPTION = "Weather"
GROUP BY ap.AIRPORT,ap.STATE, total_flights.total_flights
ORDER BY porcentaje_cancelaciones DESC;
-- Del Norte airport es el que más cancelaciones debidas al mal tiempo tiene (25%), pero solo ha tenido 4 vuelos
-- seguido por Sawyer Airport con el 20% pero también, solo ha tenido 5 vuelos
-- sigue Ralph Wien Airport con 16%

-- DESGLOSAMOS POR NATIONAL AIR SYSTEM
SELECT 
    ap.AIRPORT
    ,ap.STATE
    ,total_flights
    ,SUM(f.CANCELLED) AS flights_cancelled
    ,ROUND((SUM(f.CANCELLED) / total_flights.total_flights) * 100,2) AS porcentaje_cancelaciones
FROM flights f
LEFT JOIN airports ap
ON f.ORIGIN_AIRPORT = ap.IATA_CODE
LEFT JOIN cancellation_codes c 
ON f.CANCELLATION_REASON = c.CANCELLATION_REASON
LEFT JOIN (SELECT f.ORIGIN_AIRPORT
            ,COUNT(*) AS total_flights
			FROM flights f
			GROUP BY f.ORIGIN_AIRPORT
			) AS total_flights 
ON ap.IATA_CODE = total_flights.ORIGIN_AIRPORT
WHERE c.CANCELLATION_DESCRIPTION = "National Air System"
GROUP BY ap.AIRPORT, ap.STATE, total_flights.total_flights
ORDER BY porcentaje_cancelaciones DESC;
-- 1. Sawyer airport con 20%
-- 2. Devils Airport con 13%
-- 3. Toledo Airport con 8%
-- no es un motivo relevante...

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
-- MESES agrupando solo por mes veo que Febrero, Enero y Marzo son los meses en los que se cancelan más vuelos
SELECT 
    MONTH
    , count(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelaciones
FROM flights
GROUP BY MONTH
ORDER BY porcentaje_cancelaciones DESC;
SELECT 
        CASE     
            WHEN DAY_OF_WEEK = 1 THEN "Sunday"
            WHEN DAY_OF_WEEK = 2 THEN "Monday"
            WHEN DAY_OF_WEEK = 3 THEN "Tuesday" 
            WHEN DAY_OF_WEEK = 4 THEN "Wednesday"
            WHEN DAY_OF_WEEK = 5 THEN "Thursday"
            WHEN DAY_OF_WEEK = 6 THEN "Friday"
            ELSE "Saturday"
        END AS day_name, total_cancelaciones
FROM(SELECT DAY_OF_WEEK, COUNT(*) AS total_cancelaciones
	FROM flights f
	WHERE f.CANCELLED = 1
	GROUP BY DAY_OF_WEEK) AS cancelaciones_por_dia
ORDER BY total_cancelaciones DESC;

-- DÍAS agrupando solo por día de la semana veo que Domingo (1), Lunes(2), Miércoles(4) y Sábado(7) son los días en los que se cancelan más vuelos
SELECT
    DAY_OF_WEEK
    , COUNT(*) as total_fligths
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

-- ANÁLISIS DELAYS

-- vuelos atrasados (delay salida) por aerolinea en porcentaje a los vuelos totales operados por esa aerolinea
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
    , SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END) as departure_flights_delayed
    , ROUND(SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100,2) as porcentaje_delayed
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY porcentaje_delayed desc;
-- United, Soutwest y Spirit son las que más retrasos tienen

-- QUE PORCENTAJE DE VUELOS HAN TENIDO UN RETRASO EN LA SALIDA? CUAL HA SIDO EL RETRASO MEDIO?
-- CALCULAR LA MEDIA DE RETRASO EN LA SALIDA
SELECT a.AIRLINE, COUNT(*) AS total_flights
			,SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END) AS flights_departure_delayed
			,ROUND((SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_delayed
			,ROUND((AVG(CASE WHEN DEPARTURE_DELAY > 0 THEN DEPARTURE_DELAY ELSE 0 END)),2) AS media_retraso_salida 
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY media_retraso_salida DESC;
-- Frontier y spirit son las que tienen una media más alta de delays en la salida (en minutos), seguidas por United y Jet Blue
-- sin embargo las que tienen un porcentaje más alto de delays en la salida son: United, Spirit, Southwest, Jet Blue y Frontier

-- QUE PORCENTAJE DE VUELOS HAN TENIDO UN RETRASO EN LA LLEGADA? CUAL HA SIDO EL RETRASO MEDIO?
-- CALCULAR LA MEDIA DE RETRASO EN LA LLEGADA
SELECT a.AIRLINE, COUNT(*) AS total_flights
			,SUM(CASE WHEN (ARRIVAL_DELAY) > 0 THEN 1 ELSE 0 END) AS flights_arrival_delayed
			,ROUND((SUM(CASE WHEN (ARRIVAL_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_delayed
			,ROUND((AVG(CASE WHEN ARRIVAL_DELAY > 0 THEN ARRIVAL_DELAY ELSE 0 END)),2) AS media_retraso_llegada
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE
ORDER BY media_retraso_llegada DESC;

-- How does the % of delayed flights vary throughout the year? 
-- What about for flights leaving from Boston (BOS) specifically?
SELECT MONTH, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_atrasos
FROM flights f 
GROUP BY MONTH
ORDER BY porcentaje_atrasos DESC; -- el delay se mantiene más o menos en 35% a lo largo de los meses, CON UN PICO DE 43% EN JUNIO

-- y según el día
SELECT DAY_OF_WEEK, COUNT(*) AS total_flights
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_delayed
FROM flights f 
GROUP BY DAY_OF_WEEK
ORDER BY porcentaje_delayed DESC; -- el Miércoles, Jueves, Domingo y Sábado son los días con más retrasos

-- RETRASOS EN LA SALIDA SEGÚN EL AEROPUERTO DE SALIDA 
SELECT AIRPORT,CITY, STATE
			,COUNT(*) AS total_flights
			,SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed
			,ROUND((SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END)/count(*)*100),2) as porcentaje_delayed
            ,ROUND((AVG(CASE WHEN DEPARTURE_DELAY > 0 THEN DEPARTURE_DELAY ELSE 0 END)),2) AS media_retraso_salida 
FROM flights f
LEFT JOIN airports a
ON f.ORIGIN_AIRPORT = a.IATA_CODE 
GROUP BY a.AIRPORT, a.CITY, a.STATE
ORDER BY porcentaje_delayed DESC;

-- RETRASOS EN LA LLEGADA SEGÚN EL AEROPUERTO DE SALIDA 
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

-- VUELOS CON RANGOS DE RETRASOS (según aerolinea)
SELECT a.AIRLINE 
    ,COUNT(*) AS total_flights
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 0 AND DEPARTURE_DELAY <= 60 THEN 1 END) AS RETRASO_LEVE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 0 AND DEPARTURE_DELAY <= 60 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_BREVES
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 60  AND DEPARTURE_DELAY <= 120 THEN 1 END) AS RETRASO_MODERADO
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 60 AND DEPARTURE_DELAY <= 120 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_MODERADOS
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 120  AND DEPARTURE_DELAY <= 180 THEN 1 END) AS RETRASO_FUERTE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 120 AND DEPARTURE_DELAY <= 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_FUERTES
    ,COUNT(CASE WHEN DEPARTURE_DELAY  > 180 THEN 1 END) AS RETRASO_HEAVY
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_HEAVY
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE 
GROUP BY a.AIRLINE;

-- VUELOS CON RANGOS DE RETRASOS (según aeropuerto)
SELECT ap.AIRPORT 
    ,COUNT(*) AS total_flights
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 0 AND DEPARTURE_DELAY <= 60 THEN 1 END) AS RETRASO_LEVE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 0 AND DEPARTURE_DELAY <= 60 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_BREVES
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 60  AND DEPARTURE_DELAY <= 120 THEN 1 END) AS RETRASO_MODERADO
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 60 AND DEPARTURE_DELAY <= 120 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_MODERADOS
    ,COUNT(CASE WHEN DEPARTURE_DELAY > 120  AND DEPARTURE_DELAY <= 180 THEN 1 END) AS RETRASO_FUERTE
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 120 AND DEPARTURE_DELAY <= 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_FUERTES
    ,COUNT(CASE WHEN DEPARTURE_DELAY  > 180 THEN 1 END) AS RETRASO_HEAVY
    ,ROUND((COUNT(CASE WHEN DEPARTURE_DELAY > 180 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_RETRASOS_HEAVY
FROM flights f
LEFT JOIN airports ap
ON f.ORIGIN_AIRPORT = ap.IATA_CODE
GROUP BY ap.AIRPORT
ORDER BY porcentaje_RETRASOS_HEAVY DESC;


-- JUNTO LAS 2 TABLAS, CANCELACIONES Y ATRASOS
SELECT a.AIRLINE
	, COUNT(*) AS total_flights
    , SUM(CANCELLED) as flights_cancelled
    , round((SUM(CANCELLED)/count(*)*100),2) as porcentaje_cancelled
    , SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END) as flights_delayed
    , ROUND(SUM(CASE WHEN (DEPARTURE_DELAY) > 0 THEN 1 ELSE 0 END)/count(*)*100,2) as porcentaje_delayed
FROM flights f
LEFT JOIN airlines a
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY porcentaje_delayed desc, porcentaje_cancelled desc;


-- RUTAS MÁS COMUNES CON CANCELACIONES Y RETRASOS
SELECT origen.AIRPORT AS origin_airport_name,
	origen.STATE,
    destination.AIRPORT AS destination_airport_name,
    destination.STATE,
    f.DISTANCE,
	COUNT(*) AS total_flights,
    SUM(f.CANCELLED) AS flights_cancelled,
    ROUND(SUM(f.CANCELLED) / COUNT(*) * 100, 2) AS porcentaje_cancelled,
    SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed,
    ROUND(SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS porcentaje_delayed
FROM flights f
JOIN airports origen
ON f.ORIGIN_AIRPORT = origen.IATA_CODE
JOIN airports destination 
ON f.DESTINATION_AIRPORT = destination.IATA_CODE
GROUP BY f.ORIGIN_AIRPORT, f.DESTINATION_AIRPORT, f.DISTANCE
HAVING flights_cancelled > 0 OR flights_delayed > 0  -- Solo mostrar rutas con cancelaciones o retrasos
ORDER BY porcentaje_cancelled DESC, porcentaje_delayed DESC;

-- HORARIO DE SALIDA PROGRAMADA DE LOS VUELOS QUE TIENEN RETRASO/CANCELACIÓN
SELECT 
    SCHEDULED_DEPARTURE,
    COUNT(*) AS total_flights,
    COUNT(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 END) AS vuelos_delayed,
    ROUND(
        (COUNT(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_delayed
    ,COUNT(CASE WHEN CANCELLED = 1 THEN 1 END) AS vuelos_cancelled,
    ROUND(
        (COUNT(CASE WHEN CANCELLED = 1 THEN 1 END) / COUNT(*) * 100), 2
    ) AS porcentaje_cancelled
FROM flights
GROUP BY SCHEDULED_DEPARTURE
ORDER BY porcentaje_cancelled DESC, porcentaje_delayed DESC;

-- POR DISTANCIA ??
SELECT DISTANCE, DEPARTURE_DELAY 
FROM flights
WHERE DEPARTURE_DELAY > 120
GROUP BY DISTANCE, DEPARTURE_DELAY
ORDER BY DEPARTURE_DELAY DESC;



-- CONCLUSIONES
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


-- QUIERO HACER UN RANKING POR AERLINEA DE CANCELACIONES Y RETRASOS
SELECT 
    a.AIRLINE,
    COUNT(*) AS total_flights,
    SUM(f.CANCELLED) AS flights_cancelled,
    ROUND((SUM(f.CANCELLED) / COUNT(*) * 100), 2) AS porcentaje_cancelled,
    SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed,
    ROUND((SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) AS porcentaje_delayed,
    RANK() OVER (ORDER BY ROUND((SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) DESC) AS rank_delayed,
    RANK() OVER (ORDER BY ROUND((SUM(f.CANCELLED) / COUNT(*) * 100), 2) DESC) AS rank_cancelled
FROM flights f
LEFT JOIN airlines a 
ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY rank_delayed, rank_cancelled;

-- QUIERO HACER UN RANKING POR AEROPUERTO DE CANCELACIONES Y RETRASOS
SELECT 
    ap.AIRPORT,
    COUNT(*) AS total_flights,
    SUM(f.CANCELLED) AS flights_cancelled,
    ROUND((SUM(f.CANCELLED) / COUNT(*) * 100), 2) AS porcentaje_cancelled,
    SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS flights_delayed,
    ROUND((SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) AS porcentaje_delayed,
    RANK() OVER (ORDER BY ROUND((SUM(CASE WHEN f.DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) DESC) AS rank_delayed,
    RANK() OVER (ORDER BY ROUND((SUM(f.CANCELLED) / COUNT(*) * 100), 2) DESC) AS rank_cancelled
FROM flights f
LEFT JOIN airports ap
ON f.ORIGIN_AIRPORT = ap.IATA_CODE
GROUP BY ap.AIRPORT
ORDER BY rank_delayed, rank_cancelled
LIMIT 20;



