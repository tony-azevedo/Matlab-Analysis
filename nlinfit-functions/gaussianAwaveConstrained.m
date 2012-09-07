function fit = gaussianAwaveConstrained(beta, x)
%beta(1) = A
%beta(2) = teff
% see also gaussianAwaveUnconstrained, gaussianAwave

fit = exp(-1/2*beta(1) .* x .* x);
