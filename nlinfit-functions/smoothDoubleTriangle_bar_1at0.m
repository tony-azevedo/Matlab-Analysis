function fit = smoothDoubleTriangle_bar_1at0(beta, x)
% Fit smoothed triangles
fit1 = x - (beta(1)); % center of first triangle
fit2 = x - (beta(2)); % center of second triangle
% fit = ...
%     beta(2) .* exp(-fit1 .* fit1 ./ (2 * (beta(3)^2))) + ...
%     beta(4) .* exp(-fit2 .* fit2 ./ (2 * (beta(5)^2)));
gaus1 = beta(3) .* exp(-fit1 .* fit1 ./ (2 * (beta(4)^2)));
gaus2 = beta(5) .* exp(-fit2 .* fit2 ./ (2 * (beta(6)^2)));
fit = gaus1+gaus2;