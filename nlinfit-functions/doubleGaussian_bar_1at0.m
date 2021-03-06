function fit = doubleGaussian_bar_1at0(beta, x)
% true gaussian with three parameters, mu, sigma, and scaling factor, but
% location of the peaks is fixed relative to one another
fit1 = x - (beta(1));
fit2 = x - (beta(2));
% fit = ...
%     beta(2) .* exp(-fit1 .* fit1 ./ (2 * (beta(3)^2))) + ...
%     beta(4) .* exp(-fit2 .* fit2 ./ (2 * (beta(5)^2)));
gaus1 = beta(3) .* exp(-fit1 .* fit1 ./ (2 * (beta(4)^2)));
gaus2 = beta(5) .* exp(-fit2 .* fit2 ./ (2 * (beta(6)^2)));
fit = gaus1+gaus2;