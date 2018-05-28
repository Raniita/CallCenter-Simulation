function newZ = GCLM(Z)
%Funcion para crear muestra
a = 48271;
m = ((2^31)-1);
newZ = mod(Z*a,m);
end