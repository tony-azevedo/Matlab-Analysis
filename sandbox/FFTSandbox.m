dt = .0001;
t = -1+dt:dt:1;
y = t;
y(t<=0) = 0;
y(t>0) = 1;

figure
plot(t,y)
pause

f = (1/dt)/length(t)*[0:length(t)/2]; f = [f, fliplr(f(2:end-1))];
Y = fft(y-mean(y));
loglog(f,Y.*conj(Y));


%%
[Pxx,f] = pwelch(current,params.sampratein,[],[],params.sampratein);
