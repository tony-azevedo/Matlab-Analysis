function model = qgConstrainSig0(b,x)
% quantizedgaussian
%      Assumptions of the model:
%       mu (b(1)) is the parameter setting the poisson distribution
%       sig0 (b(2)) is the gaussian parameter for failure distributions
%       sig1 (b(3)) is the guassian parameter for singeltons
%       s (b(4)) is the mean for singletons
%       any higher numbers of responses are multiples of s and sig1
%
%  quantizedgaussian(x,coef)
%
% See also BumpAnalysis,bumps,plotBumps, plotQuantizedGaussian
%
% TA 1/6/10
lastpoiss = 2;
poissx = (0:lastpoiss);
poiss = poisspdf(poissx,b(1));
while sum(poiss)<.9
    lastpoiss = lastpoiss+1;
    poissx = (0:lastpoiss);
    poiss = poisspdf(poissx,b(1));
end

model = zeros(size(x));
for i = 1:length(poiss)
    model = model + poiss(i)*normpdf(x,poissx(i)*b(4),b(2)+poissx(i)*b(3));
end