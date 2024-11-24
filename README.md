<h2 align="center"> AIRLINES FLIGHTS PROJECT </h2> 

<div align="center">
  <img src="Images/foto.jpeg" alt="Texto alternativo" width="500" height="400" />
</div>


# Table of contents
- [Introducción](#introducción)
- <a href="#primeras-hipótesis">Primeras Hipótesis</a>
- [Proceso](#proceso)
- [Resultados](#resultados)
- [Conclusiones](#conclusiones)

#### LINK TO DASHBOARD: [Airlines Flights Project](https://public.tableau.com/app/profile/caterina.aresu/viz/AirlinesFlightsProject/Analisisgeneral)

# Introducción
Cuantas veces nos ha pasado tenernos que ir de viaje y al llegar al aeropuerto nos hemos enterado de que nuestro vuelo ha sido cancelado o retrasado? 
Personalmente no muchas, sin embargo existe la posibilidad de que un vuelo se cancele o se retrase.
La idea de este proyecto se centra en el análisis de datos de vuelos aéreos cuyo objetivo es identificar tendencias y patrones importantes que nos permitan conocer qué aerolíneas tienen más probabilidades de sufrir cancelaciones o demoras, y cuáles son las más fiables.  

He recolectado y analizado datos de 150 MIL vuelos de aerolíneas comerciales durante el año 2015 que incluyen información sobre aeropuertos, rutas, horarios de vuelos, aerolíneas, distancias, retrasos, cancelaciones y mucho más. El propósito es proporcionar una solución que permita tomar decisiones más informadas basadas en el análisis de datos masivos.

Herramientas utilizadas: 
- MySQL: Para almacenar, gestionar y consultar los resultados del análisis de datos.
- Pandas: Para la manipulación de datos.
- SQLAlchemy: Para interactuar con la base de datos desde Python.
- Tableau: Para visualizar los resultados.

# Primeras hipótesis

- ¿Hay algunas aerolíneas que tengan más cancelaciones que otras? 

- ¿Hay algún aeropuerto que tenga más cancelaciones que otros? Depende su posición geografica?

- ¿Hay algúna época del año en la que se producen más cancelaciones y retrasos?

- ¿Depende el horario de salida de un vuelo en las cancelaciones/retrasos de dichas cancelaciones/retrasos? Y el período del año?

- ¿Qué aerolíneas y aeropuertos tienen el retraso medio más alto?

- ¿Qué aerolíneas parecen ser las más fiables en terminos de salidas a tiempo? Y las que menos?


# Proceso
A continuación se describen las fases del proyecto:

## **1. Recolección y manipulación de datos:**
Los datos de vuelos se han recopilado desde la web Maven Analitics. El dataset venía bastante limpio, el único inconveniente es que contenía más de 5 millones de registros por lo que he tenido que coger una muestra aleatoria de 150 mil. 
He creado la base de datos desde Python, haciendo la conexión con MYSQL. 

El procesamiento de datos se ha realizado en Python utilizando bibliotecas como Pandas para leer archivos CSV y convertirlos en DataFrames. Estos datos luego los he transformado y analizado para extraer información útil. 
No he hecho mucho énfasis en Python, ya que mi objetivo principal estaba más centrado en las visualizaciones de Tableau y los resultados en MySQL, en lugar de enfocarme tanto en la limpieza y transformación de los datos del conjunto de datos.

## **2. Arquitectura y almacenamiento en MySQL:**
Una vez procesados los datos en Python, he exportado el dataframe resultante a MYSQL. 
Durante esta fase he creado las tablas que almacenan los detalles de los vuelos con sus rutas, distancias y salidas/llegadas, detalles de los aeropuertos, de las aerolíneas y el motivo de cancelaciones.
He utilizado 4 tablas: Airlines, Airports, Cancellation Codes y Flights (tabla de facto)

<div style="text-align: side ;">
    <img src="Images/EER Diagram.png" alt="alt text" width="500"/>
</div>
Una vez creadas las 4 tablas, he insertado manualmente los valores de la tabla Airports (si lo hacía directamente en MySQL me daba error:

“unhandled exeption: ascii code can’t decode”)

<img src="Images/error ASCII.png" alt="alt text" width="200"/>

mientras que para las tablas “Airlines” y “Cancellation Codes” he importado los datos directamente del CSV de la web original y para la tabla “flights” importé los datos desde Python (ya que el csv original, al tener más de 5 millones de registros, era muy pesado para cargar en mysql).

## **3. Consultas SQL para Análisis:**
Una vez he podido almacenar los datos en MySQL, he procedido a realizar consultas para extraer información de interés. Algunas consultas comunes incluyen:

### Visión global 
Nos hacemos una idea general de los vuelos por aerolínea, la frecuencia por días y por meses

•	¿Cuáles son los aeropuertos con más tráfico aéreo? 

 <img src="Images/tráfico aéreo por aeropuerto.png" alt="alt text" width="400"/>

•	¿Y las aerolíneas?

 <img src="Images/vuelos aerolineas.png" alt="alt text" width="400"/>

•	Días con más vuelos 

 <img src="Images/Vuelos por día de la semana.png" alt="alt text" width="200"/>

 •	Meses con más vuelos

   <img src="Images/vuelos meses.png" alt="alt text" width="200"/>


### Análisis cancelaciones
Este análisis se centra en el motivo de las cancelaciones y en qué período se verifican más 

•	Qué días se cancelan más vuelos

 <img src="Images/cancelaciones por dia.png" alt="alt text" width="300"/>


•	Qué meses se cancelan más vuelos

 <img src="Images/cancelaciones por meses.png" alt="alt text" width="300"/>


####	 •Cancelaciones por aeropuerto

 <img src="Images/cancelaciones por aeropuerto.png" alt="alt text" width="500"/>

 •	Cancelaciones por aeropuerto debidas al mal tiempo

 <img src="Images/cancelaciones ap por weather.png" alt="alt text" width="400"/>

 •	Cancelaciones por aeropuerto  debidas al National Air System

 <img src="Images/cancelaciones ap por air system.png" alt="alt text" width="400"/>


####	 •Cancelaciones por aerolínea

 <img src="Images/cancelaciones por aerolinea.png" alt="alt text" width="400"/>

  •	Cancelaciones por aerolínea debidas a la misma aerolínea

 <img src="Images/Flights cancelled por motivo Airline:Carrier.png" alt="alt text" width="400"/>

### Análisis retrasos

•	Promedio de retraso por aerolínea (en minutos)

 <img src="Images/media retraso por aerolinea.png" alt="alt text" width="400"/>

•	Promedio de retraso por aeropuerto (en minutos)

 <img src="Images/retraso por aeropuerto.png" alt="alt text" width="600"/>

•	rango retrasos por aerolínea: retraso leve es hasta 1 hora, retraso moderado es entre 1 y 2 horas, retraso fuerte/severo es entre 2 y 3 horas y el heavy/grave es a partir de 3 horas

 <img src="Images/rango retrasos por aerolinea.png" alt="alt text" width="900"/>

 •	rango retrasos por aeropuerto

 <img src="Images/rango retrasos por aeropuerto.png" alt="alt text" width="900"/>


 **Qué aerolineas parecen ser más fiables y cuales menos en terminos de salidas a tiempo?**


 <img src="Images/vuelos a tiempo.png" alt="alt text" width="600"/>

 **RANKING**

 <img src="Images/rank aerolinea.png" alt="alt text" width="900"/>



## **4. Visualización de Resultados:**
Para que os hagáis una idea más clara de los resultados podéis visualizar los datos a través de Tableau [Airlines Flights Project](https://public.tableau.com/app/profile/caterina.aresu/viz/AirlinesFlightsProject/Analisisgeneral)

Realmente con tableau es más fácil y rápido ver patrones de vuelos, comparar retrasos y cancelaciones por aerolínea y mucho más.

# Resultados
Los resultados obtenidos de este análisis se podrían utilizar por los pasajeros para tomar decisiones sobre la mejor época en la que viajar o qué aerolínea evitar a la hora de mirar vuelos. 
Algunos resultados clave incluyen:
- Vuelos cancelados: se ha analizado la tasa de cancelaciones para proporcionar recomendaciones sobre cuales aerolíneas evitar o qué época del año descartar; American Eagle es la aerolínea con más tasa de cancelaciones y Febrero el mes en el que descartar viajar. 
- Vuelos con mayor retraso: se han identificado ciertos aeropuertos con mayores tiempos de retraso, lo que puede ayudar a las aerolíneas a mejorar sus tiempos de conexión.
- Media de retraso por aerolínea: la media más alta de retraso pertenece a Frontier Airlines con 18 minutos, sin embargo la media más alta de retrasos mayores de 3 horas es de American Airlines.
- Rutas más frecuentes: descubrimos que ciertas rutas, como la de Aspen (CO) a Dallas (TX), tienen un alto porcentaje de retrasos y de cancelaciones, lo que sugiere que se podrían optimizar con vuelos más frecuentes o mejores horarios.
- Retrasos y tiempo de espera: los datos han mostrado que algunos aeropuertos, como Chicago Midway o Dallas Love Field, tienen más probabilidades de experimentar retrasos. Esto puede ser útil para las aerolíneas al programar vuelos de conexión o mejorar la puntualidad.
- Peores aeropuertos: sin tener en cuenta las cancelaciones por mal tiempo y por la aerolínea, los peores aeropuertos de USA son Sawyer International Airport, Devils Lake International Airport y Toledo Express Airport
- Peores aerolíneas: teniendo en cuenta tanto las cancelaciones como los retrasos, las peores aerolíneas son American Eagle, Atlantic Souteast y Spirit
- Mejores aerolíneas: si quieres ir sobre seguro en tu próximo viaje reserva con Alaska Airlines, Hawaiian Airlines o Delta Airlines.


# Conclusiones
La cantidad de información que se podría analizar del dataset es infinita, solamente me he podido centrar en una parte, la que he creído más básica, es decir, cancelaciones y retrasos. Sin embargo se habría podido estudiar más en profundidad, como el motivo de los retrasos o si la distancia afecta a las cancelaciones y/o retrasos entre otros.
Al gestionar los datos a través de MySQL y al visualizarlos en Tableau, el proyecto ha sido un buen ejercicio para poder practicar estas herramientas.
