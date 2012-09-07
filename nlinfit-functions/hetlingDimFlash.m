function [model] = hetlingDimFlash(coef, x)
% hetlingDimFlash     
%   model = coef(1)*(1-exp(-coef(2)*(x-coef(3)).^2)).*exp(-x/coef(4));
%
%   hetlingDimFlash(coef, x)
%
%   for unitary response (without dependence on the flashstrength)
%     gammaprime => coef(1)
%     alphaprime => coef(2)
%     td         => coef(3)  
%     tauwprime  => coef(4)
%
% See also NLINFIT
%
% TA 12/18/09

model = coef(1)*(1-exp(-coef(2)*(x-coef(3)).^2)).*exp(-x/coef(4));
model(x<=coef(3))=0;