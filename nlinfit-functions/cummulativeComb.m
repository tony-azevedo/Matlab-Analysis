function model = cummulativeComb(b, x)
% cummulativeComb
%   Calculates the cummulative probability of a combination of two poisson
%   combs with means separated by sqrt(2)
%      Assumptions of the model:
%       mu (b(1)) is the parameter setting the first poisson distribution
%       sig0 (b(2)) is the gaussian parameter for failure distributions
%       sig1 (b(3)) is the guassian parameter for singeltons
%       ahat (b(4)) is the mean for singletons
%       gamma (b(5) is the scaling factor
%       any higher numbers of responses are multiples of ahat and sig1
%
%  cummulativeCombSqrt2(x,coef)
%
% See also BumpAnalysis,bumps,plotBumps, plotQuantizedGaussian
%
% TA 10/18/10
mu1 = b(1);
lastpoiss = 4;
poissx = (0:lastpoiss);
poiss2 = poisspdf(poissx,mu1);
while sum(poiss2)<.97
    lastpoiss = lastpoiss+1;
    poissx = (0:lastpoiss);
    poiss2 = poisspdf(poissx,mu1);
end

% fprintf('Final poisson integer is %d\n',lastpoiss);
poiss1 = poisspdf(poissx,mu1);

model = zeros(size(x));
for i = 1:length(poiss2)
        sigma = sqrt(b(2)^2 + poissx(i)*b(3)^2);
        mu = poissx(i)*b(4);
        gauss = 1/(sigma*sqrt(2*pi))*exp(-((x-mu).^2)/2/sigma^2);
        model = model + poiss1(i)*gauss;
end
model = model/(sum(poiss1));
model = cumtrapz(x,model);
% plot(x,model,'Color',generateColorWheel(1));
% disp(b);