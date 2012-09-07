function [fit] = fallingExponential(coef, x)
% fallingExponential     
%       simple exponential fit: fit = 1 - exp((x-coef(1)) * coef(2));
%       starts at 1 and drops
%
%   fallingExponential(COEF,X)
%
% eg  fit = nlinfit(x,y,@fallingExponential,coef);
%
% See also NLINFIT
%
% Help added by TA 02/22/09

fit = 1 - coef(1)*exp((x-coef(2)) * coef(3));
