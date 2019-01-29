function fit = gaussian_1at0(beta, x)
% true gaussian with three parameters, mu, sigma, and scaling factor
fit = x - beta(2);
fit = beta(1) .* exp(-fit .* fit ./ (2 * (beta(3)^2)));
