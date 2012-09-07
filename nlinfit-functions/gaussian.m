function fit = gaussian(beta, x)
% true gaussian with three parameters, mu, sigma, and scaling factor
fit = x - beta(2);
fit = beta(1) .* exp(-fit .* fit ./ (2 * (beta(3)^2))) / ((2 * pi * beta(3)^2)^(0.5));
