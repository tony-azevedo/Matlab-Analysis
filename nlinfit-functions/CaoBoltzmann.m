function y = CaoBoltzmann(coef, x)

y = coef(1) + ((coef(1)-coef(2)) ./ (1+exp((coef(4)-x)/coef(3))));