% fun with coherence
Fs = 10000;
t = 0:(Fs-1);
t = t/t(end);

a = 5;

s_0 = a * sin(2*pi*60 *t);
n = normrnd(0,1,size(t));

s = s_0 + n;

plot(t,s)


%%
rad_per_sample = 2*pi/Fs;
Fp1_Hz = 10;
Fp1_rad_per_samp = Fp1_Hz * rad_per_sample;
Fst1_Hz = 8;
Fst1_rad_per_samp = Fst1_Hz * rad_per_sample;
Fp2_Hz = 60;
Fp2_rad_per_samp = Fp2_Hz * rad_per_sample;
Fst2_Hz = 70;
Fst2_rad_per_samp = Fst2_Hz * rad_per_sample;
Allowable_ripple = .5; %DB
Attenuation1 = 60; %DB
Attenuation2 = 60; %DB

% Ap    - Passband Ripple (dB)
%        Ast   - Stopbands Attenuation (dB)
%        Ast1  - First Stopband Attenuation (dB)
%        Ast2  - Second Stopband Attenuation (dB)

d=fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',...
    Fst1_rad_per_samp,...
    Fp1_rad_per_samp,...
    Fp2_rad_per_samp,...
    Fst2_rad_per_samp,...
    Attenuation1,...
    Allowable_ripple,...
    Attenuation2);

designmethods(d)

Hd = design(d,'butter');
fvtool(Hd);

[gd,w] = grpdelay(Hd);
plot(w,gd)


%%
delta = zeros(size(t));
delta(100) = 1;
f = filter(Hd,delta);

plot(t,f)

%%
r = filter(Hd,s);

plot(t,s,'r'),hold on
plot(t,r)

%% Equation 2


