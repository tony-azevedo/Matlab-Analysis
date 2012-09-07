function [fit] = scaledmichaelis(beta, x)
% see also hill2, michaelis
%beta(2)
fit =  beta(2)./ (1 + (beta(1) ./ x));
