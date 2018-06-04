%% CALL CENTER 2018

clear;
close all;
clc;                        % Limpiamos la consola

DEBUG = false;              % Simulacion por pasos
CONFIANZA = false;          % Intervalos de confianza
MUESTRAS = true;            % Informacion muestras
BLOCK = true;               % Informacion bloques
TRANSITORIO = true;         % Eliminar muestras transitorio
CRITERIO_CALIDAD = true;    % Aplicar criterio de calidad
OPTATIVA = false;            % Ejecucion del simulador para la optativa

listaEV = [];               % Lista de eventos, vacia al principio
t_sim = 0.0;                % Reloj de la sim
steps = 0;

% Tipo de eventos
SALE = 0;
LLEGA = 1;
COUNT_N = 2;

% PARAMS DE SIMULACION
waitTime = 5;                           % Veces que contamos el estado

X = 250;
type_sim_llegadas = 2;                  % Tiempo entre llegadas de incidencias
param1_llegadas = 200;
param2_llegadas = 0;

S = 400;
type_sim_salidas = [2 2 2 1];         % Tiempo de servicio en cada nivel
param1_salidas = [30 6 2 10];
param2_salidas = [0 0 0 0];

Z = 1;                                  % Prob salida del sistema
type_sim_salidas_sis = 0;
param1_salidas_sis = 0;
param2_salidas_sis = 0;

P = 555;                                % Semilla para contar N.

% ESTADO
C = length ( type_sim_salidas ) ;       % Niveles del Call Center
N = zeros(1,C);                         % <-- Vector de 1xC
fifoTiempos = cell(C,1);                % fifoTiempos para cada nivel

k = [10 4 1 1];                           % k ( i ) : numero de operarios en el nivel i
p = [0.9 0.9 0.9 1];                 % p ( i ) : probabilidad de resolucion en el nivel i
tareas = zeros(1,C);                     % tareas completadas en cada nivel
sin_completar = 0;                       % tareas sin completar del sistema

% VARIABLES PARA EL CALCULO DE LOS PROMEDIOS DE INTERES
summuestrasT = 0;
nummuestrasT = 0;
sumcuadrado = 0;

summuestrasN = zeros(1,C);
nummuestrasN = 1;

ratio = 0;
summuestrasRatio = 0;
nummuestrasRatio = 0;
sumcuadradoRatio = 0;

% Bloques
XperBlock = 100;
Block = 1;
summuestrasT_block = 0;
nummuestrasT_block = 0;
sumcuadrado_block = 0;

% Eliminación de las muestras transitorias
H = 10000;

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

 while true                % Parada con criterio de calidad
    steps = steps + 1;
    
    [listaEV, tiempo, tipo, t_llegada, nivel] = sgteEvento(listaEV);
    t_sim = tiempo;
    
    switch tipo
        case LLEGA
            N(nivel) = N(nivel) + 1;
            
            % Si nivel=1. Nueva entrada tsim+t_aux, t_llegada=t_sim
            if nivel == 1
                t_llegada = t_sim;
                [X,t_aux] = aleatorio(X, type_sim_llegadas, param1_llegadas, param2_llegadas);
                listaEV = encolarEvento2(listaEV, t_sim + t_aux, LLEGA, t_llegada, 1);
            end
            
            if N(nivel) <= k(nivel)
                [S,t_aux] = aleatorio(S, type_sim_salidas(nivel), param1_salidas(nivel), param2_salidas(nivel));
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
            % la prob del nivel
            [Z, prob] = aleatorio(Z, type_sim_salidas_sis, param1_salidas_sis, param2_salidas_sis);
            
            if(prob < p(nivel))     
                % La tarea acaba y sale del sistema
                % Obtenemos las muestras
                
                tareas(nivel) = tareas(nivel) + 1;
                summuestrasRatio = summuestrasRatio + 1;
                nummuestrasRatio = nummuestrasRatio + 1;
                
                if TRANSITORIO                 % Eliminamos las muestras transitorias
                    if steps>H
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
                    
            else
                % La tarea sigue en el sistema y entra al siguiente nivel
                % Programamos llegada al siguiente nivel en el instante
                % actual
                
                if DEBUG
                    display('Permanece en el sistema');
                    [t_llegada]
                end
                
                if nivel >= C
                    % La tarea no se ha completado y no quedan mas niveles
                    
                    sin_completar = sin_completar + 1;
                    
                    summuestrasRatio = summuestrasRatio + 0;
                    nummuestrasRatio = nummuestrasRatio + 1;
                    
                    if DEBUG
                        display('no quedan mas niveles');
                    end
                    
                    tareas(nivel) = tareas(nivel) + 1;
                    
                    % Tomamos la muestra
                    if TRANSITORIO                 % Eliminamos las muestras transitorias
                        if steps>H
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
                    % Encolamos en el siguiente nivel con el tiempo actual
                    
                    listaEV = encolarEvento2(listaEV, t_sim, LLEGA, t_llegada, nivel + 1);
                end
            end
            
            if N(nivel) >= k(nivel)
                [fifoTiempos{nivel},t_llegada_pop] = popFIFO(fifoTiempos{nivel});
                [S, t_aux] = aleatorio(S, type_sim_salidas(nivel), param1_salidas(nivel), param2_salidas(nivel));
                listaEV = encolarEvento2(listaEV, t_sim + t_aux, SALE, t_llegada_pop, nivel);
            end
             
        case COUNT_N
            nummuestrasN = nummuestrasN + 1;
            for n1=1:length(summuestrasN)
                summuestrasN(n1) = summuestrasN(n1) + N(n1);
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
else
    T = summuestrasT/nummuestrasT;
end

ratio = summuestrasRatio/nummuestrasRatio;

for n2=1:length(summuestrasN)
   N(n2) = summuestrasN(n2)/nummuestrasN;
end

if ~CRITERIO_CALIDAD
    [unomenosalpha, izq, der] = calidad(tolrelativa, nummuestrasT_block, summuestrasT_block, sumcuadrado_block);
end

if OPTATIVA
    [unomenosalpha_ratio, izq_ratio, der_ratio] = calidad(tolrelativa, nummuestrasRatio, summuestrasRatio, sumcuadradoRatio);
end
    
% Mostramos los resultados
display('### FIN DE LA SIMULACION ###');
display(strcat('--> Pasos=',num2str(steps)));
if MUESTRAS
    if BLOCK
        display(strcat('--> summuestrasT_block=',num2str(summuestrasT_block)));
        display(strcat('--> nummuestrasT_block=',num2str(nummuestrasT_block)));
        display(strcat('--> T_block=',num2str(T)));
    else
        display(strcat('--> summuestrasT=',num2str(summuestrasT)));
        display(strcat('--> nummuestrasT=',num2str(nummuestrasT)));
        display(strcat('--> T=',num2str(T)));
    end
    display(strcat('--> summuestrasN=',num2str(summuestrasN)));
    display(strcat('--> nummuestrasN=',num2str(nummuestrasN)));
    display(strcat('--> N=',num2str(N)));
    display(strcat('--> Tareas completadas=',num2str(tareas)));
    display(strcat('--> Tareas sin completar=',num2str(sin_completar)));
end
if CONFIANZA
    display('### INTERVALO DE CONFIANZA ###');
    display(strcat('--> Tolerancia relativa=',num2str(tolrelativa)));
    display(strcat('--> Calidad=',num2str(unomenosalpha)));
    display(strcat('--> Intervalo izquierda=',num2str(izq)));
    display(strcat('--> Intervalo derecha=',num2str(der)));
end
if CRITERIO_CALIDAD
    display('### CRITERIO CALIDAD ###');
    display(strcat('--> Tolerancia relativa=',num2str(tolrelativa)));
    display(strcat('--> Confianza deseada=',num2str(reestriccion_calidad)));
    display(strcat('--> Confianza conseguida=',num2str(unomenosalpha)));
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

display('### PARTE OPTATIVA ###');
display(strcat('--> summuestrasRatio=',num2str(summuestrasRatio)));
display(strcat('--> nummuestrasRatio=',num2str(nummuestrasRatio)));
display(strcat('--> ratio=',num2str(ratio)));
if OPTATIVA
    display(strcat('--> Tolerancia relativa=',num2str(tolrelativa)));
    display(strcat('--> Confianza deseada=',num2str(reestriccion_calidad)));
    display(strcat('--> Confianza conseguida=',num2str(unomenosalpha_ratio)));
    display(strcat('--> Intervalo izquierda=',num2str(izq_ratio)));
    display(strcat('--> Intervalo derecha=',num2str(der_ratio)));
end