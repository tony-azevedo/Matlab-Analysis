function model = scalednorm(beta,x)
% scalednorm
%      beta(1)*normpdf(x,0,beta(2))
%
%  scalednorm(beta,x)
%
% See also BUMPS
%
% TA 1/6/10

sigma = beta(2);
mu = 0;
gauss = 1/(sigma*sqrt(2*pi))*exp(-((x-mu).^2)/2/sigma^2);
model = beta(1)*gauss;