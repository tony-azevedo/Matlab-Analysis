%% Kathy's filters sandbox

%% Shape a filter
N = 10000;
samprate = 10000;
nfft = 1024;

% make freq vector
w = (0:nfft/2)';

% make a PS, reflect about 0
sig = 20;
fw = exp(-w.^2/sig^2);
fw = [fw;flipud(fw(2:end-1))];

% plot the power spectrum
plot([-flipud(w(2:end-1));w],fftshift(fw));

f = samprate/nfft*[0:nfft/2]; f = [f, fliplr(f(2:end-1))];

% fft back (try changing phases, check it out)
c = real(ifft(sqrt(fw)));
figure;
plot(c);

%% Shape a filter in the time domain
samprate = 10000;
T = 1/samprate;
N = 10000;
t = (0:N-1)/samprate;

% filter: Hermite Sharpee, Doupe
t_0 = .1;
tau = .006;
H0 = pi^(-1/4)*exp(-((t-t_0)/tau).^2/2);
H1 = sqrt(2)*pi^(-1/4)*((t-t_0)/tau).* exp(-((t-t_0)/tau).^2/2);
H2 = pi^(-1/4)*sqrt(2)*(2*((t-t_0)/tau).^2-1).*exp(-((t-t_0)/tau).^2/2);

nfft = 2^nextpow2(length(t));
f = samprate/nfft*[0:nfft/2]; f = [f, fliplr(f(2:end-1))];

% plot(t,H0,t,H1,t,H2)
fH0 = fft(H0,nfft);
fH1 = fft(H1,nfft);
fH2 = fft(H2,nfft);

impulse = zeros(length(t),1)/samprate;
impulse(1) = samprate;

% make a butterworth

[B,A] = butter(2,100/samprate);
b = filter(B,A,impulse);

% freqs(B,A)
% figure(2)
% freqz(B,A)
% figure(2)
% plot(t,b);

% %% make a bessel
 
% [B,A] = besself(5,.001/2/pi);
% bes = filtfilt(B,A,impulse);
% figure(1)
% freqs(B,A)
% figure(2)
% plot(t,bes);

% make a chebyschev

c = H0; 
c = H1; 
c = H2; 
c = b; 
% c = bes;

fc = fft(c,nfft);

% look at magnitude

figure(1)
subplot(4,1,1)
loglog(f,abs(fc))
title('mag')

% look at phase delay
subplot(4,1,2)
semilogx(f,unwrap(angle(fc)))
title('phase')

% look at power
subplot(4,1,3)
loglog(f,real(fc.*conj(fc)))
title('power')

% look at filter
subplot(4,1,4)
plot(t,c)
title('power')

c = flipud(c);

%% Make a stimulus envelope
alpha = 0;
N = 10000;
samprate = 10000;
nfft = 2^nextpow2(N);
tau = 25;

% choose a white noise stimulus
stim = powernoise(alpha, N, 'randpower', 'normalize');
stim = stim-mean(stim);

% filter, change in frequency domain
fstim_pre = fft(stim,nfft);
[pstim_pre, f_pre] = pwelch(stim,nfft/2,nfft/4,nfft,samprate);

f = samprate/nfft*[0:nfft/2]; f = [f, fliplr(f(2:end-1))]';
fexp = exp(-f/(tau/2));

fstim_post = fstim_pre.*fexp;
env = ifft(fstim_post);
env = env(1:N);
[pstim_post, f_post] = pwelch(env,nfft/2,nfft/4,nfft,samprate);

% low pass

% gaussian band pass

% high pass

% pink

figure(1)
redlines = findobj(1,'Color',[1, 0, 0]);
set(redlines,'color',[1 .8 .8]);
bluelines = findobj(1,'Color',[0, 0, 1]);
set(bluelines,'color',[.8 .8 1]);


subplot(4,1,1);
plot(stim)

subplot(4,1,2);
loglog(f,fstim_pre.*conj(fstim_pre),'b'); hold on;
loglog(f,fstim_post.*conj(fstim_post),'r');

subplot(4,1,3);
loglog(f_pre,pstim_pre,'b-'); hold on
loglog(f_post,pstim_post,'r-'); hold on

subplot(4,1,4);
plot(env);

env_pre = env/std(env);


% Make a stimulus

mu = 1;
sig = 1;
alpha = 0;

env = 10.^(mu + sig*env_pre); 

% choose a white noise carrier
stim = powernoise(alpha, N, 'randpower', 'normalize');
stim = stim-mean(stim);

% choose a pure tone carrier with random phase
t = (1:N)'/samprate;
f = 150;
stim = sin(f*2*pi*t + 2*pi*(rand(1)-.5));
stim = stim-mean(stim);

stim = env.*stim;

figure(1)
plot(env,'r'); hold on
plot(stim); hold off

sound(stim)

%% generate neural response

gain = 1e-3;

[r,tr] = predict(gain*c,stim,0,samprate);

% hold on;
% plot(tr,r);
% plot(ts,scale*stim/max(stim),'r');
% axis([0 max(ts) 0 max(r)]);

% generate spikes
s = poissonSpikes(r,samprate,1,0);

acausal_short = 20;
causal_short = -100;
c_sta = [c(end+causal_short*samprate/1000:end);c(1:acausal_short*samprate/1000)];
norm_c_sta = c_sta/sqrt(c_sta'*c_sta);

figure(1), clf
subplot(3,1,1);
plot(stim); 

% [S,F,T,P] = spectrogram(stim,256,250,256,samprate);
% 
% subplot(3,1,2);
% colormap(pmkmp(256,'CubicL'))
% surf(T,F,10*log10(P),'edgecolor','none'); axis tight; 
% %surf(T,F,(P),'edgecolor','none'); axis tight; 
% % colorbar
% view(0,90);
% title('White Noise');
% xlabel('Time (Seconds)'); ylabel('Hz');

subplot(3,1,3);
plotMatrixRaster(s); 


%% Predict filter
acausal = 20;
causal = -(length(stim)/samprate*1000-20);

filt = zeros(-causal*samprate/1000+acausal*samprate/1000+1,size(s,2));
dfilt = filt;
for col = 1:size(s,2);
    [filt(:,col),t] = quickfftxcorr(s(:,col),stim,samprate,causal,acausal);    
    
end

filt_bar = mean(filt,2);
norm_filt_bar = filt_bar/sqrt(filt_bar'*filt_bar);

%% decorrelate with stimulus

% set up the filters

nfft = 2^nextpow2(length(norm_filt_bar));
f = samprate/nfft*[0:nfft/2]; f = [f, fliplr(f(2:end-1))]';

f_filt = fft(norm_filt_bar,nfft);
f_stim = fft(stim,nfft);

dffilt = f_filt./(f_stim.*conj(f_stim));
dfilt = ifft(dffilt);

% smooth the filter exponentially at really high frequencies

tau = 1000;
f_cut = 1.2e2;

f = samprate/nfft*[0:nfft/2]; f = [f, fliplr(f(2:end-1))]';
fexp = ones(size(f));
fexp(f>f_cut) = exp(-(f(f>f_cut)-f_cut)/(tau/2));

fexp_filt = fft(norm_filt_bar,nfft).*fexp;
fexp_dfilt = dffilt.*fexp;
exp_dfilt = ifft(fexp_dfilt);

norm_filt_bar = norm_filt_bar(end-length(norm_c_sta)+1:end);
dfilt = dfilt(end-length(norm_c_sta)+1:end);
exp_dfilt = exp_dfilt(end-length(norm_c_sta)+1:end);

figure();
loglog(f,f_filt.*conj(f_filt)); hold on
loglog(f,f_stim.*conj(f_stim),'k'); 
loglog(f,dffilt.*conj(dffilt),'r'); 


%% plot the filtered filters and stimuli
figure(2), clf
subplot(2,1,1);
% plot(filt,'k'); hold on 
% plot(mean(filt,2),'r'); 

figure(2)
subplot(2,1,2);
plot(mean(norm_filt_bar,2),'r'); hold on
plot(norm_c_sta,'g')
plot(exp_dfilt,'b');

figure(3)
subplot(1,1,1);
loglog(f,f_filt.*conj(f_filt)); hold on
loglog(f,f_stim.*conj(f_stim),'k'); 
loglog(f,dffilt.*conj(dffilt),'r'); 
loglog(f,fexp.*conj(fexp),'b--');hold on
loglog(f,fexp_dfilt.*conj(fexp_dfilt),'b');

nfft2 = 2^nextpow2(length(norm_c_sta));
f2 = samprate/nfft2*[0:nfft2/2]; f2 = [f2, fliplr(f2(2:end-1))]';

loglog(f2,fft(norm_c_sta,nfft2).*conj(fft(norm_c_sta,nfft2)),'g');

