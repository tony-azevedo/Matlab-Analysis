% fun with coherence

t = 0:(10000-1);
t = t/t(end);

a = 5;

s_0 = a * sin(2*pi*60 *t);
n = normrnd(0,1,size(t));

s = s_0 + n;

plot(t,s)