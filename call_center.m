%% CALL CENTER 2018

clear;
close all;
clc;                        % Limpiamos la consola

DEBUG = false;              % Simulacion por pasos
CONFIANZA = false;          % Intervalos de confianza
MUESTRAS = true;            % Informacion muestras
BLOCK = true;               % Informacion bloques
TRANSITORIO = false;         % Eliminar muestras transitorio
CRITERIO_CALIDAD = true;    % Aplicar criterio de calidad

listaEV = [];               % Lista de eventos, vacia al principio
t_sim = 0.0;                % Reloj de la sim
steps = 1000000;

% Tipo de eventos
SALE = 0;
LLEGA = 1;
COUNT_N = 2;

% PARAMS DE SIMULACION
waitTime = 5;

X = 333;
type_sim_llegadas = 2;                  % Tiempo entre llegadas de incidencias al Call Center
param1_llegadas = 1.5;
param2_llegadas = 0;

S = 444;
type_sim_salidas = [2 2 2 2];           % Tiempo de servicio en cada nivel
param1_salidas = [1 1/2 1/3 1/4 1/5];
param2_salidas = [0 0 0 0];

Z = 1;                               % Prob salida del sistema
type_sim_salidas_sis = 0;
param1_salidas_sis = 0;
param2_salidas_sis = 0;

P = 555;                                % Semilla para contar N.

% ESTADO
C = length ( type_sim_salidas ) ;       % Niveles del Call Center
N = zeros(1,C);                         % <-- Vector de 1xC;
fifoTiempos = cell(C,1);

k = [2 1 1 1 1];                         % k ( i ) : numero de operarios en el nivel i
p = [0.7 0.6 0.5 0.4 0.3];               % p ( i ) : probabilidad de resolucion en el nivel i
tareas = zeros(1,C);                     % tareas completadas en cada nivel
sin_completar = 0;                       % tareas sin completar del sistema

% VARIABLES PARA EL CALCULO DE LOS PROMEDIOS DE INTERES
summuestrasT = 0;
nummuestrasT = 0;
sumcuadrado = 0;

summuestrasN = zeros(1,C);
nummuestrasN = 1;

% Bloques
XperBlock = 100;
Block = 1;
summuestrasT_block = 0;
nummuestrasT_block = 0;
sumcuadrado_block = 0;

% Eliminación de las muestras transitorias
H = 1000;

% Criterio de calidad
tolrelativa = 0.05;
reestriccion_calidad = 0.95;

% Programamos la entrada del primer evento
[X,T_aleatorio] = aleatorio(X, type_sim_llegadas, param1_llegadas, param2_llegadas);
[P,T_fijo] = aleatorio(P, 3, waitTime);

% Programamos la primera entrada de eventos.
listaEV = encolarEvento2(listaEV, T_aleatorio, LLEGA, T_aleatorio, 1);
listaEV = encolarEvento2(listaEV, T_fijo, COUNT_N, 0, 0);

% ########################################################################

%for i=1:steps             % Max de pasos
 while true                % Criterio de calidad
    i = i + 1;
    
    [listaEV, tiempo, tipo, t_llegada, nivel] = sgteEvento(listaEV);
    t_sim = tiempo;
    
    switch tipo
        case LLEGA
            N(nivel) = N(nivel) + 1;
            
            %Si nivel=1. Nueva entrada tsim+t_aux, t_llegada=t_sim
            if nivel == 1
                t_llegada = t_sim;
                [X,t_aux] = aleatorio(X,type_sim_llegadas,param1_llegadas,param2_llegadas);
                listaEV = encolarEvento2(listaEV, t_sim + t_aux, LLEGA, t_llegada, 1);
            end
            
            if N(nivel) <= k(nivel)
                [S,t_aux] = aleatorio(S,type_sim_salidas(nivel),param1_salidas(nivel),param2_salidas(nivel));
                listaEV = encolarEvento2(listaEV, t_sim + t_aux, SALE, t_llegada, nivel);
            elseif N(nivel) > k(nivel)
                fifoTiempos{nivel} = pushFIFO(fifoTiempos{nivel}, t_llegada);
            end
            
            if (DEBUG)                  % Ejecucion paso a paso
                display('LLEGADA');
                [t_sim, t_llegada, nivel]
                pause
            end
            
        case SALE
            N(nivel) = N(nivel) - 1;
            
            % Calculamos la prob de que salga del sistema y comparamos con
            % el nivel
            [Z, prob] = aleatorio(Z, type_sim_salidas_sis, param1_salidas_sis, param2_salidas_sis);
            if(prob < p(nivel))     
                % La tarea acaba y sale del sistema
                % Se obtiene tiempo de permanencia
                
                tareas(nivel) = tareas(nivel) + 1;
                
                if TRANSITORIO                 % Eliminamos las muestras transitorias
                    if i>H
                        summuestrasT = summuestrasT + (t_sim - t_llegada);
                        nummuestrasT = nummuestrasT + 1;
                        sumcuadrado = sumcuadrado + (t_sim - t_llegada)^2;
                    end
                else
                    summuestrasT = summuestrasT + (t_sim - t_llegada);
                    nummuestrasT = nummuestrasT + 1;
                    sumcuadrado = sumcuadrado + (t_sim - t_llegada)^2;
                end
            
                if BLOCK 
                    if nummuestrasT == ((Block*XperBlock))
                        summuestrasT_block = summuestrasT_block + (summuestrasT/XperBlock);
                        nummuestrasT_block = nummuestrasT_block + 1;
                        sumcuadrado_block = sumcuadrado_block + (summuestrasT/XperBlock)^2;
                    
                        summuestrasT = 0;
                        Block = Block + 1;
                    end
                end
                if DEBUG
                    display('Sale del sistema');
                end
                    
            else % La tarea sigue en el sistema y entra al siguiente nivel
                % Programamos llegada al siguiente nivel en el instante
                % actual
                if DEBUG
                    display('permanece en el sistema');
                end
                
                if nivel == C
                    % La tarea no se ha completado y no quedan mas niveles
                    sin_completar = sin_completar + 1;
                    if DEBUG
                        display('no quedan mas niveles');
                    end
                    
                    tareas(nivel) = tareas(nivel) + 1;
                
                if TRANSITORIO                 % Eliminamos las muestras transitorias
                    if i>H
                        summuestrasT = summuestrasT + (t_sim - t_llegada);
                        nummuestrasT = nummuestrasT + 1;
                        sumcuadrado = sumcuadrado + (t_sim - t_llegada)^2;
                    end
                else
                    summuestrasT = summuestrasT + (t_sim - t_llegada);
                    nummuestrasT = nummuestrasT + 1;
                    sumcuadrado = sumcuadrado + (t_sim - t_llegada)^2;
                end
            
                if BLOCK 
                    if nummuestrasT == ((Block*XperBlock))
                        summuestrasT_block = summuestrasT_block + (summuestrasT/XperBlock);
                        nummuestrasT_block = nummuestrasT_block + 1;
                        sumcuadrado_block = sumcuadrado_block + (summuestrasT/XperBlock)^2;
                    
                        summuestrasT = 0;
                        Block = Block + 1;
                    end
                end
                
                else
                    listaEV = encolarEvento2(listaEV, t_sim, LLEGA, t_llegada, nivel + 1);
                end
            end
            
            if N(nivel) >= k(nivel)
                [fifoTiempos{nivel},t_llegada] = popFIFO(fifoTiempos{nivel});
                [S, t_aux] = aleatorio(S, type_sim_salidas(nivel), param1_salidas(nivel), param2_salidas(nivel));
                listaEV = encolarEvento2(listaEV, t_sim + t_aux, SALE, t_llegada, nivel);
            end
             
            if DEBUG
                display('SALE');
                [t_sim, t_llegada, t_sim-t_llegada]
                pause
            end
            
        case COUNT_N
            nummuestrasN = nummuestrasN + 1;
            for i=1:length(summuestrasN)
                summuestrasN(i) = summuestrasN(i) + N(i);
            end
            
            [P,T_fijo] = aleatorio(P,3,T_fijo,0);
            listaEV = encolarEvento2(listaEV, t_sim + T_fijo, COUNT_N, T_fijo, 0);
    end
    if CRITERIO_CALIDAD
        [unomenosalpha, izq, der] = calidad(tolrelativa, nummuestrasT_block, summuestrasT_block, sumcuadrado_block);
        if(unomenosalpha >= reestriccion_calidad) break;
        end
    end
end

if BLOCK
    T = summuestrasT_block/nummuestrasT_block;
    N = summuestrasN/nummuestrasN;
else
    T = summuestrasT/nummuestrasT;
    N = summuestrasN/nummuestrasN;
end

if ~CRITERIO_CALIDAD
    [unomenosalpha, izq, der] = calidad(tolrelativa, nummuestrasT_block, summuestrasT_block, sumcuadrado_block);
end

% Mostramos los resultados
display('### FIN DE LA SIMULACION ###');
display(strcat('--> Pasos=',num2str(i)));
if MUESTRAS
    display(strcat('--> summuestrasT='),num2str(summuestrasT));
    display(strcat('--> nummuestrasT='),num2str(nummuestrasT));
    display(strcat('--> T='),num2str(T));
    %display(strcat('--> summuestrasN='),num2str(summuestrasN));
    %display(strcat('--> nummuestrasN='),num2str(nummuestrasN));
    %display(strcat('--> N='),num2str(N));
end
if CONFIANZA
    display('### INTERVALO DE CONFIANZA ###');
    display(strcat('--> Tolerancia relativa=',num2str(tolrelativa)));
    display(strcat('--> Calidad=',num2str(unomenosalpha)));
    display(strcat('--> Intervalo izquierda=',num2str(izq)));
    display(strcat('--> Intervalo derecha=',num2str(der)));
end
if BLOCK
    display('### BLOQUES ###');
    display(strcat('--> Muestras por bloque=',num2str(XperBlock)));
end
if TRANSITORIO
    display('### TRANSITORIO ###');
    display(strcat('--> Muestras eliminadas=',num2str(H)));
end 