function [Z,muestra] = aleatorio(Z,tipo,param1,param2)
m=((2^31)-1);
Z=GCLM(Z);

    switch(tipo)
        %Tipo 0 -> VA uniforme [0,1]
        case 0
            muestra = Z/m;
        
        %Tipo 1 -> VA uniforme [param1,param2]
        case 1
            %Tambien puede ser con el metodo de la generacion inversa.
            muestra = Z/m*(param2-param1) + param1;
      
        %Tipo 2 -> VA exponencial lambda = param1;
        case 2
            muestra = -(log(Z/m))/param1;
        
        %Tipo 3 -> Devuelve siempre param1
        case 3
            muestra = param1;
        
        %Se pueden poner muchos mas tipos.
        otherwise
            display('Wrong value on function aleatoria');
    end
end
