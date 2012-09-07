function [fit] = familymodel(coef, x)
% familymodel     
%       simple exponential fit: 1-e^-(x*k)
%
%   familymodel(STARTINGK,X)
%
% See also NLINFIT
%
% Help added by TA 02/22/09
fit = 1 - exp(-x * coef(1));
