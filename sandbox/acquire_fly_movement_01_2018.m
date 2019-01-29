clear all;close all;
ii = 1;
global acquire_sandbox_dispax

% pull location for video storage
root = 'C:\Users\tony\Acquisition\180130\180130_F1_C1';
folders = dir(root);
this_file = folders(length(folders)).name;
this_folder = [root '\BaslerCamTest'];


%% Set up a session with a trigger on 4 and exposures on 3 code
s = daq.createSession('ni');
s.addAnalogOutputChannel('dev1', 'ao2', 'Voltage');
s.addAnalogInputChannel('dev1', 'ai0', 'Voltage');
s.addDigitalChannel('dev1', 'Port0/Line3', 'InputOnly');
s.addDigitalChannel('dev1', 'Port0/Line2', 'OutputOnly');

%s.addTriggerConnection('External','Dev1/PFI0','StartTrigger')
s.Rate = 10000;

%%
N = 40000;
triggercolumn = zeros(size((1:N)'));
ttlcolumn = triggercolumn;
triggercolumn(1) = 1;

Dtrig(10001) = 1;
Dtrig(20001) = 1;

ttlcolumn(1:2500) = 1;
ttlcolumn(5000:7500) = 1;
ttlcolumn(10000:12500) = 1;
%ttlcolumn(15000:end) = 1;
ttlcolumn(15000:17500) = 1;
ttlcolumn(20000:22500) = 1;
ttlcolumn(25000:27500) = 1;
ttlcolumn = ttlcolumn;


%% Setup source and vid objects
% imaqtool;
vid = videoinput('gentl', 1, 'Mono8');
src = getselectedsource(vid);
frame = getsnapshot(vid);

% Set up for 
src.LineSelector = 'Line3';             % brings up settings for line3
src.LineMode = 'output';                % should be 'output'
src.LineInverter = 'True';                % should be 'output'

src.LineSelector = 'Line4';             % brings up settings for line3
src.LineMode = 'input';                % should be 'output'

src.TriggerSelector = 'FrameStart';
src.TriggerMode = 'Off';

src.TriggerSelector = 'FrameBurstStart';
src.TriggerSource = 'Line4';
src.AcquisitionBurstFrameCount = 255;
src.TriggerActivation = 'RisingEdge';
src.TriggerMode = 'On';

src.GainAuto = 'Off';

%% Vid stuff
triggerconfig(vid, 'hardware');         % have to set this for the video object too.

NsampsForBurst = double(src.AcquisitionBurstFrameCount)/src.ResultingFrameRate * s.Rate;
triggercolumn(ceil(NsampsForBurst)) = 1;

vid.LoggingMode = 'disk&memory';
vid.FramesPerTrigger = 400;

% Set up a display window
displayf = findobj('type','figure','tag','cam_snapshot');
if isempty(displayf)
    displayf = figure;
    displayf.Position = [40 2 640 530];
    displayf.Tag = 'cam_snapshot';
end
acquire_sandbox_dispax = findobj(displayf,'type','axes','tag','dispax');
if isempty(acquire_sandbox_dispax) 
    acquire_sandbox_dispax = axes('parent',displayf,'units','pixels','position',[0 0 640 512],'tag','dispax');
    acquire_sandbox_dispax.Box = 'off'; acquire_sandbox_dispax.XTick = []; acquire_sandbox_dispax.YTick = []; acquire_sandbox_dispax.Tag = 'dispax';
    colormap(acquire_sandbox_dispax,'gray')
end
imshow(frame,'initialmagnification',50,'parent',acquire_sandbox_dispax);

frame =  peekdata(vid,1);

imshow(frame,'initialmagnification',50,'parent',acquire_sandbox_dispax);


vid.FramesAcquiredFcnCount = 10;
vid.FramesAcquiredFcn = @acquire_fly_movement_showframe;

%% 
ii = ii+1;
diskLogger = VideoWriter([this_folder '\test_' num2str(ii) '.avi'], 'Motion JPEG AVI');
diskLogger.FrameRate = src.ResultingFrameRate; 
diskLogger.Quality = 85; 
vid.DiskLogger = diskLogger;

start(vid);
% display('ready to acquire video (waiting for trigger)');pause;
%%
s.queueOutputData([ttlcolumn triggercolumn]);
in = s.startForeground; % both amp and signal monitor input

%% 
stop(vid)

%%
t = (1:N)/s.Rate;
f = figure(1); f.Position = [86 558 1154 420]; clf
subplot(2,2,1)
plot(t,in(:,1),'color',[0 0.4470 0.7410])
subplot(2,2,3)
plot(t,in(:,2),'color',[0.8500 0.3250 0.0980]);
hold(subplot(2,2,3),'on'),
plot(t,ttlcolumn,'color',[0.4940    0.1840    0.5560]);

linkaxes([subplot(2,2,1),subplot(2,2,3)],'x')
xlabel('sec')
ylim(subplot(2,2,3),[-.1 1.1])

subplot(2,2,2)
plot(t,in(:,1),'color',[0 0.4470 0.7410])
subplot(2,2,4)
plot(t,in(:,2),'color',[0.8500 0.3250 0.0980])
hold(subplot(2,2,3),'on'),
plot(t,ttlcolumn,'color',[0.4940    0.1840    0.5560]);

linkaxes([subplot(2,2,2),subplot(2,2,4)],'x')
xlabel('sec')

fr_ = in(:,2);
fr = (fr_(1:end-1)<1 & fr_(2:end)>0);% | (fr_(1:end-1)>0 & fr_(2:end)<1);

frames = cumsum(fr);
% where the frames stop
NFrames = frames(end);
xlims = [t(find(frames>NFrames-5,1,'first')) t(find(frames>NFrames-5,1,'first'))+1.75*diff([t(find(frames>NFrames-5,1,'first')) t(find(frames>=NFrames,1,'first'))])];
text(t(diff(find(fr,2,'first'))),0,sprintf('%g frames, %g logged, %.2f Hz',NFrames,vid.DiskLoggerFrameCount,1/t(diff(find(fr,2,'first')))),'parent',subplot(2,2,3))
xlim(subplot(2,2,4),xlims);
ylim(subplot(2,2,4),[-.1 1.1])

%%
stop(vid);

%% 
preview(vid)
src.TriggerMode = 'Off';

%% Gain
% Gain can be changed if the GainAuto function is off.
src.GainAuto = 'Continuous';
src.Gain = 5; % gives an error
src.GainAuto = 'Off';
src.Gain = 5;
src.GainAuto = 'Once';

preview(vid)

src.Gain

%% 
stoppreview(vid)


