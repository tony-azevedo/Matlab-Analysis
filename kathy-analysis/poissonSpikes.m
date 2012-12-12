function s = poissonSpikes(r,sr,n)
% s = poissonSpike(r,sr,n)
% generate poisson distributed spike train s
% given rate function r (Hz) and sample rate sr
% n is number of spike trains to generate

if nargin <3,
    n = 1;
end

r = r(:);
T = length(r);
test = repmat(r,1,n)/sr;

s = zeros(T,n);
x = rand(T,n);
s(find(x<test)) = 1;