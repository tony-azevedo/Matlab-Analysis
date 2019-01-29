%% Video
clear all, close all, imaqreset, a = instrfind, delete(a), clear a

root = 'C:\Users\tony\fly_movement_videos';
folders = dir(root);
this_file = folders(length(folders)).name;
this_folder = [root '\' this_file];

% configure and start imaq
vid = videoinput('pointgrey', 2, 'Mono8_640x480');
src = getselectedsource(vid);

% Setup source and pulses etc
triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');
vid.TriggerRepeat = 0;
vid.FramesPerTrigger = 1;
vid.LoggingMode = 'disk&memory';

% Strobe stuff
src.Strobe1 = 'On'; %% turn this on at the last minute
src.Strobe1Polarity = 'High';
set(src,'FrameRate','60')

preview(vid)

%%
stoppreview(vid)

%% Setting up firefly camera to watch leg movement

sampratein = 50000;
samprateout = 50000;

stimonset = 2;                                  % time before stim on (seconds)
stimdur = 1;
stimpost = 7;                                  % time after stim offset (seconds)
dur = stimonset+stimdur+stimpost;

stim_on_samp = floor(stimonset*samprateout)+1;
stim_off_samp = floor(stimonset*samprateout)+(samprateout*stimdur);

nsampout = stim_off_samp+floor(stimpost*samprateout);
nsampin = ceil(nsampout/samprateout*sampratein);

stim = zeros(nsampout,1);
stim(stim_on_samp:stim_off_samp) = 1; %stimulus

framerate = 32;
frametime = 1/25;
Nframes = floor(dur/frametime);
triggerstim = stim*0;
idxs = ((1:Nframes)-1)*(frametime*samprateout) + 1;
triggerstim(idxs) = 1;
triggerstim(idxs(2)) = 0;
triggerstim(idxs(3)) = 0;

Nframes = sum(triggerstim);

stim = stim+triggerstim;


%% Other
s = daq.createSession('ni');
s.addAnalogInputChannel('Dev1',0, 'Voltage');
s.addDigitalChannel('Dev1','Port0/Line0','InputOnly');
s.addAnalogOutputChannel('Dev1',[0], 'Voltage');
s.addDigitalChannel('Dev1', 'Port0/Line2', 'OutputOnly');
s.Rate = samprateout;
% 
% s.addTriggerConnection('Dev1/PFI0','External','StartTrigger')

%% 
obj = NewsutterMP285('COM4');
updatePanel(obj);
[stepMult, currentVelocity, vScaleFactor] = getStatus(obj);
xyz_um = getPosition(obj);
setOrigin(obj);
a = instrfind;

%%

N = 1;
current = nan(length(stim),N);
exptimes = current;
chi = nan(size(1:N));
yps = nan(size(1:N));

diskLogger = VideoWriter([this_folder '\' this_file '_'  '.avi'], 'Grayscale AVI');
addlistener(s,'DataAvailable',
for n = 1:N
    fprintf('Trial %d\n',n)
        
    vid.DiskLogger = diskLogger;
    src.Strobe1 = 'On';
    vid.TriggerRepeat = Nframes-1; % s.DurationInSeconds*src.FrameRate
    start(vid);
    figure(1)
    fprintf('Vid on: %s. Triggers: %d. Executed: %d. Frames acquired: %d\n',vid.Running,vid.TriggerRepeat+1,vid.TriggersExecuted,vid.FramesAcquired)
    
    s.queueOutputData([stim(:) triggerstim(:)]);
    s.startBackground;
    
    setVelocity(obj, 500, 10)
    pause(1)
    moveTime = moveTo(obj,[0;100;0]);
    pause(1)
    moveTime = moveTo(obj,[0;-100;0]);
    
    wait(s)
%     wait(vid)
    
    fprintf('Vid on: %s. Triggers: %d. Executed: %d. Frames acquired: %d\n',vid.Running,vid.TriggerRepeat+1,vid.TriggersExecuted,vid.FramesAcquired)
    stop(vid)
    
    current(:,n) = x(:,1); % should be current tansients
    exptimes(:,n) = x(:,2); % should be the frames
    
    figure(2)
    subplot(2,2,1);
    plot(triggerstim+n*.002); hold on
    plot(stim+n*.002); hold on
    title('stimulus')
    xlabel('sample');
    ylabel('Output');
    
    subplot(2,2,3);
    plot(current(:,n));
    title('current transients')
    xlabel('samp');
    ylabel('AU');
    
    subplot(2,2,2);
    plot(exptimes(:,n)+n*.002);
    xlabel('samp');
    ylabel('digital');
    
    drawnow
    
    if n<N, pause(), end
end

% CHI{M} = chi; YPS{M} = yps;
% M = M+1;
% data(n).trigdiff = AO.InitialTriggerTime-AI.InitialTriggerTime;

% display('ready to acquire video (waiting for trigger)');
% stop(vid);


% %% Video
% root = 'C:\Users\tony\fly_movement_videos';
% folders = dir(root);
% this_file = folders(length(folders)).name;
% this_folder = [root '\' this_file];
% 
% % configure and start imaq
% % imaqtool;
% vid = videoinput('pointgrey', 2, 'Mono8_640x480');
% src = getselectedsource(vid);
% 
% %% Setup source and pulses etc
% src.Strobe1Polarity = 'Low';
% src.Strobe1 = 'Off';
% % src.Strobe1 = 'On';
% triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');% vid.FramesPerTrigger = Inf;
% %triggerconfig(vid, 'immediate', 'none', 'none');% vid.FramesPerTrigger = Inf; % configs = triggerinfo(vid);
% % triggerconfig(vid,configs(7));
% set(src,'FrameRate','15')
% vid.TriggerRepeat = 0;
% vid.FramesPerTrigger = 40;
% vid.LoggingMode = 'disk&memory';diskLogger = VideoWriter([this_folder '\' this_file '.avi'], 'Grayscale AVI');
% vid.DiskLogger = diskLogger;
% src.Strobe1 = 'On'; %% turn this on at the last minute
% start(vid);
% % stop(vid)
% %src.Strobe1 = 'Off';
% 
% 

%%

% N = 2;
% current = nan(aiSession.NumberOfScans,N);
% exptimes = nan(aiSession.NumberOfScans,N);
% chi = nan(size(1:N));
% yps = nan(size(1:N));
% 
% 
% for n = 1:N
%     fprintf('Trial %d\n',n)
%     % aoSession.queueOutputData([stim(:)]);
%     aoSession.queueOutputData([stim(:), triggerstim(:)]);
%     fprintf('aoSession loaded? %d Scans\n',aoSession.NumberOfScans)
%     aoSession.startBackground; % Start the session that receives start trigger first
%     
%     % doSession.queueOutputData([triggerstim(:)]);
%     % fprintf('doSession loaded? %d Scans\n',doSession.NumberOfScans)
%     % doSession.startBackground;
%     
%     diskLogger = VideoWriter([this_folder '\' this_file '_' num2str(n) '.avi'], 'Grayscale AVI');
%     vid.DiskLogger = diskLogger;
%     src.Strobe1 = 'On';
%     start(vid);
%     fprintf('Vid on: %s. Triggers: %d. Frames acquired: %d\n',vid.Running,vid.TriggersExecuted,vid.FramesAcquired)
%     trigcnt = vid.TriggersExecuted;
%     
%     x = aiSession.startForeground;
%     wait(aiSession)
%     wait(vid)
%     
%     fprintf('aoSession ran? %d Scans\n',aoSession.NumberOfScans)
% 
%     fprintf('Vid on: %s. Triggers: %d. Frames acquired: %d\n',vid.Running,vid.TriggersExecuted,vid.FramesAcquired)
%     if trigcnt==vid.TriggersExecuted
%         msgbox('Vid didn''t go!')
%         %stop(vid)
%         error('no!!')
%     end
%     stop(vid)
%     % pause
%     
%     current(:,n) = x(:,1); % should be current tansients
%     exptimes(:,n) = x(:,2); % should be the frames
%     
%     figure(1)
%     subplot(2,2,1);
%     plot(triggerstim+n*.002); hold on
%     plot(stim+n*.002); hold on
%     title('stimulus')
%     xlabel('sample');
%     ylabel('Output');
%     
%     subplot(2,2,3);
%     plot(current(:,n));
%     title('current transients')
%     xlabel('samp');
%     ylabel('AU');
%     
%     subplot(2,2,2);
%     plot(exptimes(:,n)+n*.002);
%     xlabel('samp');
%     ylabel('digital');
%     
%     drawnow
%     
%     % pause()
% end

%% configure session
% aiSession = daq.createSession('ni');
% 
% aiSession.addAnalogInputChannel('Dev1',0, 'Voltage');
% aiSession.addDigitalChannel('Dev1','Port0/Line1','InputOnly')
% aiSession.Rate = sampratein;
% aiSession.NumberOfScans = nsampin;
% 
% % configure AO
% aoSession = daq.createSession('ni');
% aoSession.addAnalogOutputChannel('Dev1',[0 3], 'Voltage');
% aoSession.Rate = samprateout;
% 
% % doSession = daq.createSession('ni');
% % doSession.addDigitalChannel('Dev1', 'Port0/Line0', 'OutputOnly');
% % doSession.Rate = samprateout;
%  
% % try adding another session
% aiSession.addTriggerConnection('Dev1/PFI14','External','StartTrigger');
% aoSession.addTriggerConnection('External','Dev1/PFI15','StartTrigger');
% % doSession.addTriggerConnection('External','Dev1/PFI2','StartTrigger');

% aiSession.addTriggerConnection('Dev1/PFI3','External','StartTrigger');
% aoSession.addTriggerConnection('External','Dev1/PFI5','StartTrigger');



%% Other
% pulse_chan = addCounterOutputChannel(pClk, 'Dev1', 0, 'PulseGeneration');
% pulse_chan.Frequency = 30;
% startBackground(pClk);
% s = daq.createSession('ni');
% 
% s.addDigitalChannel('Dev1','Port0/Line1','InputOnly');
% s.addAnalogInputChannel('Dev1',0, 'Voltage');
% s.addAnalogOutputChannel('Dev1',[0], 'Voltage');
% s.addDigitalChannel('Dev1', 'Port0/Line7', 'OutputOnly');
% s.Rate = 10000;
% 
% s.addTriggerConnection('Dev1/PFI0','External','StartTrigger')

%% sampratein = 10000;
% samprateout = 40000;
% stimdur = .1;
% fc = 400;
% fm = 1;
% 
% % stimname = ['AM tone, fc ', num2str(data(n).fc),' Hz, fm ', ...
% %     num2str(data(n).fm), ' Hz, m = 100%, duration ',...
% %     num2str(data(n).stimdur),' seconds'];
% AMtrain = amp_mod(1,fm,fc,.5,...
%     samprateout,stimdur,1,'with carrier');
% if isempty(AMtrain)
%     fprintf('AM stimulus not generated');
%     return;
% end
% intensity = .1; % set voltage scaling factor for stimulus output
% stimtrain = intensity.*AMtrain(:);  % make sure stim is a column vector
% 
% % stimName = exp_info.stimName;
% stimonset = 1;                                  % time before stim on (seconds)
% stimpost = .5;                                  % time after stim offset (seconds)
% 
% % timing calculations
% stimonsamp = floor(stimonset*samprateout)+1;
% stimoffsamp = floor(stimonset*samprateout)+(samprateout*stimdur);
% nsampout = stimoffsamp+floor(stimpost*samprateout);
% nsampin = ceil(nsampout/samprateout*sampratein);
% 
% stim = zeros(nsampout,1);
% stim(stimonsamp:stimoffsamp) = stimtrain; %stimulus
% 
% Ihpulse = -1;                                      % hyperpolarizing pulse should give a
% % 4 pA hyperpolarizing signal
% istim = zeros(nsampout,1);
% % istim(floor(stimonset*samprateout/4)+1:floor(stimonset*samprateout/4)+samprateout*0.2) = .1;
% istim(samprateout*.1+1:samprateout*0.4) = .1;
% 
% %% reset aquisition engines
% % configure session
% aiSession = daq.createSession('ni');
% 
% addDigitalChannel(aiSession,'Dev1','Port0/Line1','InputOnly')
% 
% aiSession.addAnalogInputChannel('Dev1',0:1, 'Voltage');
% aiSession.Rate = 10000;
% aiSession.DurationInSeconds = stimdur+stimonset+stimpost;
% 
% % configure AO
% aoSession = daq.createSession('ni');
% aoSession.addAnalogOutputChannel('Dev1',0:1, 'Voltage');
% aoSession.Rate = 10000;
% 
% aoSession.addTriggerConnection('Dev1/PFI15','External','StartTrigger')
% 
% aiSession.addTriggerConnection('Dev1/PFI0','External','StartTrigger')
% aoSession.addTriggerConnection('External','Dev1/PFI2','StartTrigger')
% M = 1; CHI = {}; YPS = {};
% %%
% N = 5;
% cmd = nan(aiSession.NumberOfScans,N);
% divcmd = nan(aiSession.NumberOfScans,N);
% chi = nan(size(1:N));
% yps = nan(size(1:N));
% 
% for n = 1:N
% aoSession.queueOutputData([n*istim stim])
% 
% aoSession.startBackground; % Start the session that receives start trigger first 
% x = aiSession.startForeground;
% cmd(:,n) = x(:,1);
% divcmd(:,n) = x(:,2);
% 
% subplot(2,2,1);
% plot(cmd); 
% xlabel('sample');
% ylabel('I');
% 
% subplot(2,2,3);
% % f = sampratein/length(x)*[0:length(x)/2]; f = [f, fliplr(f(2:end-1))];
% % loglog(f,real(fft(nanmean(x,2))).*conj(fft((nanmean(x,2))))); drawnow
% % plot(nanmean(divcmd,2)); 
% plot(divcmd); 
% xlabel('Hz');
% ylabel('Power');
% 
% drawnow
% 
% % TODO:    aiSession.addTriggerConnection('Dev1/PFI1','External','StartTrigger')
% %     aoSession.addTriggerConnection('External','Dev1/PFI2','StartTrigger')
% %
% % ao.startBackground; % Start the session that receives start trigger first
% %ai.startBackground;
% 
% chi(n) = mean(cmd(sampratein*.1+20:sampratein*0.4-20,n));
% yps(n) = mean(divcmd(sampratein*.1+20:sampratein*0.4-20,n));
% 
% subplot(1,2,2);
% plot(chi,yps,'o');
% 
% pause()
% end
% 
% CHI{M} = chi; YPS{M} = yps;
% M = M+1;
% % data(n).trigdiff = AO.InitialTriggerTime-AI.InitialTriggerTime;
% 
% %% configure analog input
% % AI = analoginput ('nidaq', 'Dev1');
% % addchannel (AI, 0:2);   % acquire from ACH0, ACH1, and ACH2, which contain 
% %                         % the 10Vm out, I out, and scaled output, respectively
% % set(AI, 'SampleRate', samprate);
% % set(AI, 'SamplesPerTrigger', inf);
% % set(AI, 'InputType', 'Differential');
% % set(AI, 'TriggerType', 'Manual');
% % set(AI, 'ManualTriggerHwOn','Trigger');
% 
% 
% %% collect and analyse data(n)
% 
% % read data from engine
% x = getdata(AI,length(t));
% 
% % record current-clamp or voltage-clamp data
% if strcmp(recMode,'VClamp')
%     voltage = x(:,1); voltage = voltage';  % acquire voltage from 10Vm (channel ACH0)
%     current = x(:,3); current = current';  % acquire current from scaled output (channel ACH3)
% elseif strcmp(recMode,'IClamp')
%     current = x(:,2); current = current';
%     voltage = x(:,3); voltage = voltage';
% end

%% Video
clear all, close all, imaqreset, a = instrfind, delete(a), clear a

root = 'C:\Users\tony\fly_movement_videos';
folders = dir(root);
this_file = folders(length(folders)).name;
this_folder = [root '\' this_file];

% configure and start imaq
vid = videoinput('pointgrey', 1, 'F7_Raw8_1280x1024_Mode0');
src = getselectedsource(vid);

% Setup source and pulses etc
triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');
vid.TriggerRepeat = 0;
vid.FramesPerTrigger = 1;
vid.LoggingMode = 'disk&memory';

% Strobe stuff
src.Strobe1 = 'On'; %% turn this on at the last minute
src.Strobe1Polarity = 'High';
set(src,'FrameRate','60')

preview(vid)

%%
stoppreview(vid)
