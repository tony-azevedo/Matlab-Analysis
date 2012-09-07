function fit = gaussianAwaveUnconstrained(beta, x)
%beta(1) = A
%beta(2) = teff
%beta(3) = scalefactor

for i = 1:size(x,1)
    fit = x(i,:) - beta(2);
    fit = beta(3) - beta(3)*exp(-1/2*beta(1) .* fit .* fit);
    fit(x(i,:)<beta(2)) = 0;
end