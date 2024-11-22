<h2 align="center"> AIRLINE FLIGHTS PROJECT </h2> 

<div align="center">
  <img src="Images/foto.jpeg" alt="Texto alternativo" width="500" height="400" />
</div>


## Table of contents
- [Introducción](#introducción)
- <a href="#primeras-hipótesis">Primeras Hipótesis</a>
- [Proceso](#proceso)
- [Resultados](#resultados)
- [Conclusiones](#conclusiones)

#### LINK TO DASHBOARD: 

## Introducción
Cuantas veces nos ha pasado tenernos que ir de viaje y al llegar al aeropuerto nos hemos enterado de que nuestro vuelo ha sido cancelado o retrasado? 
Personalmente no muchas, sin embargo las posibilidades están.
La idea de este proyecto se centra en el análisis de datos de vuelos aéreos cuyo objetivo es identificar tendencias y patrones importantes que nos permitan conocer qué aerolíneas tienen más probabilidades de sufrir cancelaciones o demoras, y cuáles son las más fiables.  

Hemos recolectado y analizado datos de 150 MIL vuelos de aerolíneas comerciales durante el año 2015 que incluyen información sobre aeropuertos, rutas, horarios de vuelos, aerolíneas, distancias, retrasos, cancelaciones y mucho más. El propósito es proporcionar una solución que permita tomar decisiones más informadas basadas en el análisis de datos masivos.

Herramientas utilizadas: 
- Python: Para el procesamiento de datos, análisis y generación de resultados.
- MySQL: Para almacenar, gestionar y consultar los resultados del análisis de datos.
- Pandas: Para la manipulación de datos.
- SQLAlchemy: Para interactuar con la base de datos desde Python.
- Tableau: Para visualizar los resultados.

## Primeras hipótesis

- Depende el horario de salida de un vuelo en las cancelaciones/retrasos de dichas cancelaciones/retrasos? Y el período del año?

- Hay algunas aerolineas que tengan más cancelaciones que otras? 

- Hay algún aeropuerto que tenga más cancelaciones que otros? Depende su posición geografica?

- Hay algúna epoca del año en la que se producen más cancelaciones y retrasos?

- Qué aerolineas y aeropuertos tienen el retraso medio más alto?

- Qué aerolineas parecen ser las más fiables en terminos de salidas a tiempo? Y las menos?


## Proceso
A continuación se describen las fases del proyecto:

**1. Recolección y procesamiento de datos:**
Los datos de vuelos se han recopilado desde la web Maven Analitics. El dataset venía bastante limpio, el único inconveniente es que contenía más de 5 millones de registros por lo que he tenido que coger una muestra aleatoria de 150 mil. 
He creado la base de datos desde Python y haciendo la conexión con MYSQL. 

El procesamiento de datos se ha realizado en Python utilizando bibliotecas como Pandas para leer archivos CSV y convertirlos en DataFrames. Estos datos luego los he transformado y analizado para extraer información útil. 
No he hecho mucho énfasis en Python, ya que mi objetivo principal estaba más centrado en las visualizaciones de Tableau y los resultados en MySQL, en lugar de enfocarme tanto en la limpieza y transformación de los datos del conjunto de datos.

**2. Arquitectura y almacenamiento en MySQL:**
Una vez procesados los datos en Python, he exportado el dataframe resultante a MYSQL. 
Durante esta fase he creado las tablas que almacenan los detalles de los vuelos con sus rutas, distancias y salidas/llegadas, detalles de los aeropuertos, de las aerolíneas y el motivo de cancelaciones.
He utilizado 4 tablas: Airlines, Airports, Cancellation Codes y Flights (tabla de facto)

<div style="text-align: center;">
    <img src="Images/EER Diagram.png" alt="alt text" width="500"/>
</div>
Una vez creadas las 4 tablas, he insertado manualmente los valores de la tabla Airports (si lo hacía directamente en MySQL me daba error:

“unhandled exeption: ascii code can’t decode”), 
<div style="text-align: center;">
    <img src="Images/error ASCII.png" alt="alt text" width="200"/>
</div>
mientras que para las tablas “Airlines” y “Cancellation Codes” he importado los datos directamente del CSV de la web original y para la tabla “flights” importé los datos desde Python (ya que el csv original, al tener más de 5 millones de registros, era muy pesado para cargar en mysql).


**3. Consultas SQL para Análisis (PANTALLAZOS MYSQL):**
Una vez tenemos los datos almacenados en MySQL, he procedido con realizar consultas para extraer información de interés. Algunas consultas comunes incluyen:
•	Cuales son los aeropuertos con más tráfico aéreo? Check
•	Días con más vuelos check
•	Qué días se cancelan más vuelos
•	Qué meses se cancelan más vuelos
•	Cancelaciones por aeropuerto check
•	Cancelaciones por aerolínea check
•	Promedio de retraso por aerolínea.
•	Análisis de vuelos cancelados.
•	VUELOS CON MAYOR RETRASOS
•	RUTAS MÁS FRECUENTES

**4. Visualización de Resultados:**
Para que os hagáis una idea más clara de los resultados podéis visualizar los datos a través de Tableau, link
Realmente con tableau es más fácil y rápido ver patrones de vuelos, comparar retrasos y cancelaciones por aerolínea y mucho más

## Resultados
Los resultados obtenidos de este análisis pueden ser utilizados por las aerolíneas para optimizar sus operaciones y por los pasajeros para tomar decisiones sobre la mejor época/aerolinea para/con la que viajar. Algunos resultados clave incluyen:
- Vuelos con mayor retraso: Se identificaron ciertos aeropuertos con mayores tiempos de retraso, lo que puede ayudar a las aerolíneas a mejorar sus tiempos de conexión.
- Vuelos cancelados: Se analizó la tasa de cancelaciones para proporcionar recomendaciones sobre cuales aerolíneas evitar o qué época del año evitar
- Rutas más frecuentadas: Descubrimos que ciertas rutas, como las de Nueva York a Los Ángeles, tienen una demanda constante, lo que sugiere que podrían optimizarse con vuelos más frecuentes o mejores horarios.
- Retrasos y tiempo de espera: Las estadísticas mostraron que algunos aeropuertos, como Chicago O'Hare, tienen más probabilidades de experimentar retrasos. Esto puede ser útil para las aerolíneas al programar vuelos de conexión o mejorar la puntualidad.
- Análisis de cancelaciones: Al analizar los vuelos cancelados, identificamos patrones relacionados con condiciones climáticas adversas y otros factores, lo que puede ayudar a las aerolíneas a prever y mitigar futuros problemas.
- MEJORES AEROPUERTOS, DONDE HAY MENOS CANCELACIONES Y SI HAY QUE NO SEAN POR AEROLINEA O TIEMPO


## Conclusiones
Las 3 mejores y 3 peores aerolíneas
Los 3 mejores y los 3 peores aeropuertos
Este análisis proporcionó información útil para optimizar las operaciones de las aerolíneas, mejorar la puntualidad de los vuelos y ayudar a los pasajeros a elegir los mejores momentos para viajar. Al gestionar los datos a través de Python y MySQL, el proyecto mostró cómo las herramientas de procesamiento y almacenamiento de datos pueden mejorar la eficiencia en la industria aeronáutica.
Hallazgos clave:
•	Retrasos y cancelaciones: Se identificaron patrones de retrasos que pueden ser útiles para mejorar los tiempos de vuelo.
•	Rutas populares: Algunas rutas presentaron una mayor demanda, lo que sugiere oportunidades de mejora en la programación de vuelos.
•	Optimización de operaciones: Los análisis realizados proporcionan sugerencias para mejorar la eficiencia operativa de las aerolíneas.
•	Optimización de rutas: Las aerolíneas pueden mejorar la programación de vuelos en rutas populares, ajustando los horarios y frecuencias según la demanda real de los pasajeros.
•	Mejora en la gestión de retrasos: Con la identificación de aeropuertos propensos a retrasos, las aerolíneas pueden tomar medidas preventivas para reducir el impacto en los pasajeros.
•	Mejor planificación de vuelos: Los datos también proporcionan una excelente base para predecir los mejores momentos para viajar, ayudando tanto a las aerolíneas como a los pasajeros a planificar sus vuelos de manera más eficiente.
•	Toma de decisiones informadas: Al contar con un sistema de base de datos robusto como MySQL, se pueden realizar consultas complejas y extraer información precisa para tomar decisiones estratégicas que impacten directamente en la eficiencia operativa y la experiencia del cliente.
