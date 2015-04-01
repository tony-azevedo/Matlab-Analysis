function [fit] = exponentialToBaseline(coef, x)
% EXPONENTIAL     
%       simple exponential fit but with no y offset allowed: coef 1 is not
%       used:
%       coef(2)*e^-(x/coef(3)) 
%
%   EXPONENTIAL(COEF,X)
%
% See also NLINFIT
%
% Help added by TA 02/22/09

fit = coef(2) .* exp(-x .* coef(3));
