function [fit] = hill(beta, x)
% see also hill2

fit = log10(1.0 ./ (1 + (beta(1) ./ x).^beta(2)));
