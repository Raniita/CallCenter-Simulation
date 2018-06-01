# CallCenter-Simulation
Practica de la universidad sobre la simulación de los sistemas de colas de un Call Center para la asignatura de Modelado y Simulación de tercero de telemática.

El esquema del simulador a realizar es el siguiente.
<img src="https://user-images.githubusercontent.com/30501761/40623199-e273f1fc-62a5-11e8-838e-c5206da10c1b.png" width="90%"></img> 

Para la implementación utilizamos algunas funciones facilitadas por el profesor, de las cuales algunas han sufrido modificaciones
* encolarEvento.m (Modificado)
* sgteEvento.m (Modificado)
* popFIFO.m
* pushFIFO.m

### Datos utilizados para la validación. (Facilitados por el profesor)
Configuración del simulador:
* type_sim_llegadas = 2                 
* param1_llegadas = 1.5                  
* param2_llegadas = 0
* type_sim_salidas = [2 2 2 2]            
* param1_salidas = [1 1/2 1/3 1/4 1/5]   
* param2_salidas = [0 0 0 0]
* k = [2 1 1 1 1]      
* p = [0.7 0.6 0.5 0.4 0.3]
* tolrelativa = 0.05
* criterio_calidad = 0.95

Con estos valores tenemos que obtener como resultado :
T = 9.65

