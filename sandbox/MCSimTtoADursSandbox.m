% MC simulation of what parameters might work to explain the distribution
% of durations of T-->A responses
import prob.*

delay = 200;

mu1 = 400;
sig1 = mu1*.5;
k = mu1^2/sig1^2;
theta = sig1^2/mu1;
p1 = prob.GammaDistribution(k,theta);

mu2 = 2700-mu1-400;
sig2 = mu2;
k = mu2^2/sig2^2;
theta = sig2^2/mu2;
p2 = prob.GammaDistribution(k,theta);

N =10000;
durations = nan(size(1:N));
% for m1_ind = 1:length(mu1);
%     for sd1_ind = 1:length(sd1);
%         for m2_ind = 1:length(mu2)
for sim = 1:N
    durations(sim) = p1.random + p2.random + delay;
end

d = sort(durations);

plot(d,(1:N)/N)
std(d)/mean(d)
