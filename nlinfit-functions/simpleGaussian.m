function fit = simpleGaussian(beta, x)
fit = x;
fit = beta(1) .* exp(-fit .* fit ./ (2 * (beta(2)^2))) / ((2 * 3.14159 * beta(2)^2)^(0.5));
