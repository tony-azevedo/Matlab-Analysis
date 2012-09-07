function [fit] = exponentialSaturating(coef, x)
% exponentialSaturating     
%       simple exponential fit: 1-e^-(x/tau)
%
%   exponentialSaturating(STARTINGK,X)
%
% See also NLINFIT
%
% Help added by TA 09052012
fit = 1 - exp(-x / coef(1));
