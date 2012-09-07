function [fit] = expPPRecovery(coef, x)
% expPPRecovery     
%   fit =   1 for t< coef(1) 
%           (exp(-(x-coef(1)) * coef(2)));      
%
%   BoseEinstein(COEF,X)
%
% See also NLINFIT
%
% TA 09/15/09

fit = exp(-(x-coef(1)) * coef(2));
fit(fit<coef(1)) = 1;