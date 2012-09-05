function varargout = optimalBinWidth(x)
% optimalBinWidth
%      Implements Freedman-Diaconis rule:
%       deltax = 2 * IQR(x) * n^(-1/3);
%
%   [deltax,bins] = optimalBinWidth(x)
%       also returns the bin vector
%
%   see also hist
%   n = hist(x,optimalBinWidth(x))/length(x);
%       plot(optimalBinWidth(x),n);
%
%
% TA 10/19/10

deltax = 2*iqr(x)*length(x)^(-1/3);
% deltax = sqrt(2)*iqr(x)*length(x)^(-1/3);

bins = ((min(x)-deltax/2):deltax:(max(x)+deltax/2));

varargout = {bins,deltax};