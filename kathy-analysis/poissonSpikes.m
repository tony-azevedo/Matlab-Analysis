function s = poissonSpikes(r,sr,n,varargin)
% s = poissonSpike(r,sr,n)
% generate poisson distributed spike train s
% given rate function r (Hz) and sample rate sr
% n is number of spike trains to generate

if nargin <3,
    n = 1;
end
if nargin>4
    sd = varagin{1};
else
    sd = [];
end

r = r(:);
T = length(r);
test = repmat(r,1,n)/sr;

s = zeros(T,n);
if isempty(sd), x = rand(T,n);
else rng(sd), x = rand(T,n); 
end
s(x<test) = 1;