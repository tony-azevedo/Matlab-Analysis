%% VaughanSong sandbox
% This is funny, the characteristic frequency of the group pulses in Alex's
% song maker is right around 140 Hz. That suggests it could be the exact
% same mechanisms. My stimuli are better.

savedir = 'C:\Users\Anthony Azevedo\Code\Matlab-Analysis\sandbox';

song_params.sineSongDuration = 0            % in seconds.
% song_params.sineSongFundamental         % In hz
% song_params.sineSongAmplitude           % Amplitude of sine song, in +/- volts.
% song_params.sineSongRamp = 0.1;         % Ramp on/off time, in s. (triangular ramp)
song_params.sinePulsePause = 0              % Pause after sine song.


% PULSE GROUPS
song_params.pulsePerGroup = 200;              % Pulses per group
song_params.interGroupInterval = 0;         % Inter-group interval, in s.
song_params.numGroups = 1;                   % Total groups of pulse song.
song_params.ipi = 0.0350;

% TRAILING SILENCE
song_params.leadingSilence = 0;             % Leading silence, in s.
song_params.trailingSilence = 0;            % Trailing silence, in s.

%%
song = songMaker(song_params,0);

flip_bit = rem(length(song.song),2);

s = song.song(1:end-flip_bit*1);
t = ((1:length(s))-1)/song.fs;

f = song.fs/length(t)*[0:length(t)/2]; f = [f, fliplr(f(2:end-1))];
S = fft(s);


%%

fig = figure;
set(fig,'color',[1 1 1],'position',[262         147        1627         835],'name','VaughanSong');

pnl = panel(fig);
pnl.margin = [20 20 20 20];
pnl.pack('v',{1/2 1/2});
pnl.de.margin = [16 16 16 16];

%%

plot(pnl(1).select(),t,s)

%%

loglog(pnl(2).select(),f,S.*conj(S))
figure
loglog(f,S.*conj(S))
spectrogram