function [fit] = exponential(coef, x)
% EXPONENTIAL     
%       simple exponential fit: coef(1)+coef(2)*e^-(x/coef(3))
%
%   EXPONENTIAL(COEF,X)
%
% See also NLINFIT
%
% Help added by TA 02/22/09

fit = coef(1) + coef(2) .* exp(-x ./ coef(3));
