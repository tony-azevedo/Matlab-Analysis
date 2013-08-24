% Beat frequencies
delT = 0.00002;
fs = 1/delT;
x = delT:delT:2;

f1 = 261.625565;
f2 = 130;
m = 1;
yc = sin(2*pi*f1*x);

y = (1+m*sin(2*pi*f2*x)).*yc;

sound(y,fs)

subplot(2,1,1);
plot(x,y)
%xlim([1,1.1])

subplot(2,1,2);
f = fs/length(x)*[0:length(x)/2]; f = [f, fliplr(f(2:end-1))];
semilogy(f,fft(y).*conj(fft(y)));
xlim([f1-2*f2,f1+2*f2])
    

