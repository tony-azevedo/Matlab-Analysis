function [c,t] = quickfftxcorr(sptrain,stim,samprate,tstart,tend)
% [c,t] = quickfftSTavg(sptrain,stim,samprate,tstart,tend)
% calculate cross-correlation between two signals by multiplying in the Fourier Domain
% returns a segment c around the spike times between tstart and tend (in msec)
% tstart should be a negative number and tend should be a positive number
% samprate should be in Hz. t is a time vector with the spike time at zero.
% useful for any kind of triggered averaging, and much faster than direct 
% calculation (getSegMatrix.m).  **This code does not perform decorrelation**


% Define Parameters
nfft = 2^nextpow2(length(stim));                % number of Fourier elements
sstart = nfft + tstart*samprate/1000;           
send = tend*samprate/1000;

% Check inputs
stim = stim(:);                                 % vectors must be columns for fft
sptrain = sptrain; %(sptrain(:)-mean(sptrain));

% Calculate Spike-triggered average
Fsptrain = fft(sptrain,nfft);  
Fstim = fft(stim,nfft);  
c = flipud(real(ifft(conj(Fstim).*Fsptrain))); 

% Take signal around zero
c = [c(sstart:nfft);c(1:send)];
t = 1000*(sstart-nfft:send)'/samprate; 

c = c/nfft;

% figure;
% plot(t,c);