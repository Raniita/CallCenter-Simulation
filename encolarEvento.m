function [ lista_de_eventos ] = encolarEvento( lista_de_eventos, tiempo, tipo, tllegada, nivel)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    s = size(lista_de_eventos);
    if isempty(lista_de_eventos)
        % La lista es nueva
        lista_de_eventos = zeros(1,4);
        lista_de_eventos(1,1) = tiempo;
        lista_de_eventos(1,2) = tipo;
        if tipo == 0
            lista_de_eventos(1,3) = tllegada; %tllegada
        else
            lista_de_eventos(1,3) = 0; %tllegada
        end
        
        %lista_de_eventos(1,3) = tllegada * (1-tipo);
        
        lista_de_eventos(1,4) = nivel;
        
        return
    end

    for i=1:s(1)
        if lista_de_eventos(i,1)>tiempo break;
        end
    end

    % Creamos una nueva lista
    newlista = zeros(s(1)+1,4);
    
    % Si el indice es el primer elemento 
    if i-1==0
        if lista_de_eventos(i,1)<tiempo
            % Solo 1 elemento, se inserta a continuacion
            newlista(2,1) = tiempo;
            newlista(2,2) = tipo;
            if tipo == 0
                newlista(2,3) = tllegada;
            else
                newlista(2,3) = 0;
            end
            newlista(2,4) = nivel;
            newlista(1,:) = lista_de_eventos(1,:);
        else
            % Se inserta antes
            newlista(1,1) = tiempo;
            newlista(1,2) = tipo;
            if tipo == 0
                newlista(1,3) = tllegada;
            else
                newlista(1,3) = 0;
            end
            
            newlista(1,4) = nivel;
            
            %newlista(2:length(newlista),:) = lista_de_eventos(:,:);
            newlista(2:size(newlista),:) = lista_de_eventos(:,:);
        end    
    elseif lista_de_eventos(i,1)>tiempo
    % El nuevo evento se inserta por el medio
        newlista(1:i-1,:) = lista_de_eventos(1:i-1,:);
        newlista(i,1) = tiempo;
        newlista(i,2) = tipo;
        if tipo == 0
                newlista(i,3) = tllegada;
            else
                newlista(i,3) = 0;
        end
        
        newlista(i,4) = nivel;
        
        newlista(i+1:length(newlista),:) = lista_de_eventos(i:s(1),:);
    else
    % El nuevo evento se inserta al final
        newlista(1:s(1),:) = lista_de_eventos(1:s(1),:);
        newlista(i+1,1) = tiempo;
        newlista(i+1,2) = tipo;
        if tipo == 0
            newlista(i+1,3) = tllegada;
        else
            newlista(i+1,3) = 0;
        end
        newlista(i+1,4) = nivel;
    end
    
    lista_de_eventos = newlista;
end

