function [unomenosalpha, intizqda, intderecha] = calidad(tolrelativa, num, sum, sumcuadrado)
%Calcula el intervalo de confianza asociado a las muestras y
%Devuelve la probabilidad asociada al intervalo de confianza

mediaMuestral = (1/num)*sum;
cuasiVarianzaMuestral = (1/(num-1))*(sumcuadrado-((mediaMuestral^2)*num));

Tabsoluta = tolrelativa*mediaMuestral;
Zalpha = Tabsoluta/(sqrt(cuasiVarianzaMuestral/num));
unomenosalpha = 1-(1-normcdf(Zalpha))*2;
intizqda = mediaMuestral - Tabsoluta;
intderecha = mediaMuestral + Tabsoluta;
end