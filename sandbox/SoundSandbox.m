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

[S,F,T,P] = spectrogram(y,128,120,256,Fs);
% S = spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs) 
% By default, X is divided into eight segments
%     with 50% overlap, each segment is windowed with a Hamming window. The
%     number of frequency points used to calculate the discrete Fourier
%     transforms is equal to the maximum of 256 or the next power of two
%     greater than the length of each segment of X.
% when WINDOW is a vector, divides X into
%     segments of length equal to the length of WINDOW, and then windows each
%     segment with the vector specified in WINDOW.  If WINDOW is an integer,
%     X is divided into segments of length equal to that integer value, and a
%     Hamming window of equal length is used.  If WINDOW is not specified, the
%     default is used.
% NOVERLAP is the number of samples
%     each segment of X overlaps. NOVERLAP must be an integer smaller than
%     WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%     than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is not
%     specified, the default value is used to obtain a 50% overlap.
% NFFT specifies the number of
%     frequency points used to calculate the discrete Fourier transforms.
%     If NFFT is not specified, the default NFFT is used.
% Fs is the sampling frequency
%     specified in Hz. If Fs is specified as empty, it defaults to 1 Hz. If 
%     it is not specified, normalized frequency is used.

figure(1)
colormap(pmkmp(256,'CubicL'))
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

figure(2)
colormap(gray)
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
x = powernoise(alpha, N, 'randpower', 'normalize');

% figure(1)
% plot(x')
% figure(2)
% hist(x,N/sqrt(N))

% S = spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs) 
% By default, X is divided into eight segments
%     with 50% overlap, each segment is windowed with a Hamming window. The
%     number of frequency points used to calculate the discrete Fourier
%     transforms is equal to the maximum of 256 or the next power of two
%     greater than the length of each segment of X.
% when WINDOW is a vector, divides X into
%     segments of length equal to the length of WINDOW, and then windows each
%     segment with the vector specified in WINDOW.  If WINDOW is an integer,
%     X is divided into segments of length equal to that integer value, and a
%     Hamming window of equal length is used.  If WINDOW is not specified, the
%     default is used.
% NOVERLAP is the number of samples
%     each segment of X overlaps. NOVERLAP must be an integer smaller than
%     WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%     than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is not
%     specified, the default value is used to obtain a 50% overlap.
% NFFT specifies the number of
%     frequency points used to calculate the discrete Fourier transforms.
%     If NFFT is not specified, the default NFFT is used.
% Fs is the sampling frequency
%     specified in Hz. If Fs is specified as empty, it defaults to 1 Hz. If 
%     it is not specified, normalized frequency is used.

[S,F,T,P] = spectrogram(x,64,60,256,N);

figure(1)
subplot(5,1,[1 2 3 4])
colormap(pmkmp(256,'CubicL'))
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
colorbar
view(0,90);
title('White Noise');
xlabel('Time (Seconds)'); ylabel('Hz');

subplot(5,1,5)
plot(x)

% - Now plot the modulation power spectrum

mps = fft2(P);
mps = fftshift(mps.*conj(mps));

figure(2)
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

[S,F,T,P] = spectrogram(x,64,60,256,N);

figure(1)
subplot(5,1,[1 2 3 4])
colormap(pmkmp(256,'CubicL'))
surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
colorbar
view(0,90);
title('White Noise');
xlabel('Time (Seconds)'); ylabel('Hz');

subplot(5,1,5)
plot(x)

% - Now plot the modulation power spectrum

mps = fft2(P);
mps = fftshift(mps.*conj(mps));

figure(2)
colormap(pmkmp(256,'CubicL'))
surf(10*log10(mps),'edgecolor','none'); axis tight; 
view(0,90);



