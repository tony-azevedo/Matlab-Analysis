clear all;close all;

%% Gabriel's code
pClk = daq.createSession('ni');
pClk.IsContinuous = true;
pulse_chan = addCounterOutputChannel(pClk, 'Dev1', 0, 'PulseGeneration');
pulse_chan.Frequency = 30;
startBackground(pClk);

s.stop();
pClk.stop();
sClk.stop();
fclose(fid);

%% configure digital out, if necessary
% daq.getDevices;
% s=daq.createSession('ni');
% addDigitalChannel(s,'dev1', 'Port0/Line0', 'OutputOnly')
% fps = 30;
% p = 1/fps;

%% pull location for video storage
root = 'C:\Users\tony\fly_movement_videos';
folders = dir(root);
this_file = folders(length(folders)).name;
this_folder = [root '\' this_file];

%% configure and start imaq
% imaqtool;
vid = videoinput('pointgrey', 2, 'Mono8_640x480');
src = getselectedsource(vid);
src.Strobe1 = 'On';
src.Strobe1Polarity = 'High';
% src.Strobe1 = 'Off';
triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');% vid.FramesPerTrigger = Inf;
% configs = triggerinfo(vid);
% triggerconfig(vid,configs(7));
vid.TriggerRepeat = Inf;
vid.FramesPerTrigger = 1;
vid.LoggingMode = 'disk&memory';diskLogger = VideoWriter([this_folder '\' this_file '.avi'], 'Grayscale AVI');
vid.DiskLogger = diskLogger;
src.Strobe1 = 'On'; %% turn this on at the last minute
start(vid);
display('ready to acquire video (waiting for trigger)');pause;
stop(vid);

%% send dio if needed
% reps = 100;
% for i = 1:reps
% outputSingleScan(s,[1])
% pause(p/2);
% outputSingleScan(s,[0]);
% pause(p/2);
% end


%% need to reset strobe to off at the end
clear all;close all;
vid = videoinput('pointgrey', 1, 'F7_Mono8_752x480_Mode0');
src = getselectedsource(vid);
src.Strobe1 = 'Off';
start(vid);
stop(vid);
clear all; close all;

