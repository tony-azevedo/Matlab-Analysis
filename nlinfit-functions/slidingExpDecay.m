function [fit] = slidingExpDecay(coef, x)
% EXPONENTIAL that will slide along the x axis     
%       simple exponential fit but with no y offset allowed: coef 1 is not
%       used:
%       e^-(x-coef(1)/coef(2)) 
%
%   EXPONENTIAL(COEF,X)
%
% See also exponentialToBaseline
%
% Help added by TA 02/22/09

fit = exp(-(x-coef(1)) ./ coef(2));
