function [fit] = boseEinstein(coef, x)
% BoseEinstein     
%   fit = 1 / (exp((x-coef(1)) * coef(2)) - 1);      
%
%   BoseEinstein(COEF,X)
%
% See also NLINFIT
%
% TA 09/15/09

fit = (1 ./ (exp((x-coef(1)) * coef(2)) + 1)).^ coef(3);
