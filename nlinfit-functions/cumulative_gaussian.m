function [y] = cumulative_gaussian(beta, x)

y = normcdf(x, 0, abs(beta(1)));
