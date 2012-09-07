function varargout = comb(b, x)
% comb
%   Generates the comb gaussians along with a hash map of individual
%   gaussians with keys as the discrete step numbers (0,1,...)
%
% See also combSqrt2
%
% TA 10/18/10
mu1 = b(1);
lastpoiss = 3;
poissx = (0:lastpoiss);
poiss1 = poisspdf(poissx,mu1);
while sum(poiss1)<.97
    lastpoiss = lastpoiss+1;
    poissx = (0:lastpoiss);
    poiss1 = poisspdf(poissx,mu1);
end

model = zeros(size(x));
comb = java.util.HashMap();
for i = 1:length(poiss1)        
        sigma = sqrt(b(2)^2 + poissx(i)*b(3)^2);
        mu = poissx(i)*b(4);
        gauss = 1/(sigma*sqrt(2*pi))*exp(-((x-mu).^2)/2/sigma^2);
        model = model + poiss1(i)*gauss;
        comb.put(i,poiss1(i)*gauss);
end

model = model/(sum(poiss1));
model = model/trapz(x,model);
% plot(x,model,'o','Color',generateColorWheel(1));
varargout = {model,comb};
