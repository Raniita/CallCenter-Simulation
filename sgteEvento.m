function [ lista_de_eventos, tiempo, tipo, t_llegada, nivel ] = sgteEvento( lista_de_eventos )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    s = size(lista_de_eventos);
    if isempty(lista_de_eventos) 
        % La lista esta vacia
        tiempo = 0;
        tipo = -1;
        t_llegada = 0;
        nivel = 0;
        return
    end

    tiempo = lista_de_eventos(1,1);
    tipo = lista_de_eventos(1,2);
    t_llegada = lista_de_eventos(1,3);
    nivel = lista_de_eventos(1,4);
    
    if s(1)==1
    % La lista se va a quedar vacia

        lista_de_eventos = [];
        return
    end
    
    % Creamos una nueva lista
    newlista = zeros(s(1)-1,4);
    newlista(1:s(1)-1,:) = lista_de_eventos(2:s(1),:);
    
    lista_de_eventos = newlista;
end