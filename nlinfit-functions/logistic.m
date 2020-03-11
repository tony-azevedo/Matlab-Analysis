function fit = logistic(beta, x)
[k,th] = deal(beta(1),beta(2));
fit = 1./(1+exp(-k.*( x - th)));
% fit = x .* 1./(1+exp(-k.*( x - th)));