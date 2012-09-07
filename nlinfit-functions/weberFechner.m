function [fit] = weberFechner(wf, x)

fit = (1 ./ (1 + x ./ wf(1)));
