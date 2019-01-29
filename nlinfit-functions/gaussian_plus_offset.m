function fit = gaussian_plus_offset(beta, x)
% true gaussian with three parameters, mu, sigma, and scaling factor
fit = x - beta(3);
fit = beta(2) .* exp(-fit .* fit ./ (2 * (beta(4)^2))) / ((2 * pi * beta(4)^2)^(0.5))+beta(1);
