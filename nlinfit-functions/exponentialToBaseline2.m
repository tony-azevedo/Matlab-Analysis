function [fit] = exponentialToBaseline2(coef, x)
% EXPONENTIAL     
%       simple exponential fit but with no y offset allowed: coef 1 is not
%       used:
%       coef(2)*e^-(x/coef(3)) 
%
%   EXPONENTIAL(COEF,X)
%
% See also exponentialToBaseline
%
% Help added by TA 02/22/09

fit = coef(1) .* exp(-x ./ coef(2));
