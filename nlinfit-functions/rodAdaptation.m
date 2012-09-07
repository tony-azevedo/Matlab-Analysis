function model = rodAdaptation(coef, x)
% BoseEinstein     
%   fit = 1 / (exp((x-coef(1)) * coef(2)) - 1);      
%
%   BoseEinstein(COEF,X)
%
% See also NLINFIT
%
% TA 09/15/09

c = (-1:.1:4);c = 10.^c;
a = 300:25:400
f = 1-(1./(1+a(1)./c)); semilogx(c,f,'.');