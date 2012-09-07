function fit = gaussianAwave(beta, x)
%beta(1) = A*phi
%beta(2) = teff

fit = x - beta(2);
fit = exp(-1/2*beta(1) .* fit .* fit);
fit(x<beta(2)) = 1;
fit = fit-1;
