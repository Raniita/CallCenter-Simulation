%% CALL CENTER 2018

close all;
clc;                    % Limpiamos la consola

listaEV = [];           % Lista de eventos, vacia al principio
t_sim = 0.0;            % Reloj de la sim
steps = 200000;

% Tipo de eventos
SALE = 0;
LLEGA = 1;
COUNT_N = 2;

% PARAMS DE SIMULACION
waitTime = 5;

x = 333;
type_sim_llegadas = 2;                  % Tiempo entre llegadas de incidencias al Call Center
param1_llegadas = 100;
param2_llegadas = 0;

S = 444;
type_sim_salidas = [2 2 2 2];           % Tiempo de servicio en cada nivel
param1_salidas = [15 20 25 30];
param2_salidas = [0 0 0 0];

P = 555;                                % Semilla para contar N.

% ESTADO
N = 0;                                  % <-- Vector de 1xC;
fifoTiempos = cell(C,1);

C = length ( type_sim_salidas ) ;       % Niveles del Call Center
k = [1 2 3 4];                          % k ( i ) : numero de operarios en el nivel i
p = [0.9 0.9 0.8 0.7];                  % p ( i ) : probabilidad de resolucion en el nivel i


% VARIABLES PARA EL CALCULO DE LOS PROMEDIOS DE INTERES
summuestrasT = 0;
nummuestrasT = 0;
sumcuadrado = 0;

summuestrasN = 0;
nummuestrasN = 1;

% Bloques
XperBlock = 100;
Block = 1;
summuestrasT_block = 0;
nummuestrasT_block = 0;
sumcuadrado_block = 0;

% Eliminación de las muestras transitorias
H = 10000;


