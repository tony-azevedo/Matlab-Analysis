function [fit] = michaelis(beta, x)
% see also hill2,scaledmichaelis
%beta(2)
fit =  1./ (1 + (beta(1) ./ x));
