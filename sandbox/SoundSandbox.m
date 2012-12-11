%% Fun sound scripts

load gong

% sound(y,Fs)
% pause(1)
% sound(y,Fs*2)
figure
spectrogram(y,128,120,128,Fs); 
title('gong');

%% Bird song - Williams http://web.williams.edu/Biology/Faculty_Staff/hwilliams/ZFsongs/index.html

[y, Fs] = wavread('Bk70');

% sound(y,Fs);

[S,F,T,P] = spectrogram(y,256,250,256,Fs);
% spectrogram(y,128,120,128,Fs); 

figure
subplot(5,1,[1 2 3 4])
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
colorbar
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');

subplot(5,1,5)
plot(y)

% - Now plot the modulation power spectrum

mps = fft2(P);
mps = fftshift(mps.*conj(mps));

figure;
surf(10*log10(mps),'edgecolor','none'); axis tight; 
view(0,90);


%% White Noise

r = 10;
N = 10000;
alpha = 0;

% s = rand(r,l);
% s = s-repmat(mean(s,2),1,l);
% figure(1)
% plot(s')
% figure(2)
% hist(s(:))
% 
% S_w = fft(s);
% figure(3);
% plot(mean(real(S_w.*conj(S_w)),1),'color',generateColorWheel(1))

x = powernoise(alpha, N, 'randpower', 'normalize');

figure(1)
plot(x')
figure(2)
hist(x,N/sqrt(N))

figure
spectrogram(x,128,120,128,N); 
title('White Noise');

[S,F,T,P] = spectrogram(x,256,250,256,N);
% spectrogram(y,128,120,128,Fs); 

figure
subplot(5,1,[1 2 3 4])
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
colorbar
view(0,90);
xlabel('Time (Seconds)'); ylabel('Hz');

subplot(5,1,5)
plot(y)

% - Now plot the modulation power spectrum

mps = fft2(P);
mps = fftshift(mps.*conj(mps));

figure;
surf(10*log10(mps),'edgecolor','none'); axis tight; 
view(0,90);


%% Pink Noise

r = 10;
N = 10000;
alpha = 1;

% s = rand(r,l);
% s = s-repmat(mean(s,2),1,l);
% figure(1)
% plot(s')
% figure(2)
% hist(s(:))
% 
% S_w = fft(s);
% figure(3);
% plot(mean(real(S_w.*conj(S_w)),1),'color',generateColorWheel(1))

x = powernoise(alpha, N, 'randpower', 'normalize');

figure(1)
plot(x')
figure(2)
hist(x,N/sqrt(N))

sound(x,N)

