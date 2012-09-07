function y = hill2(beta, x)
% see also hill

y = 1.0 ./ (1 + (beta(1) ./ x).^beta(2));
