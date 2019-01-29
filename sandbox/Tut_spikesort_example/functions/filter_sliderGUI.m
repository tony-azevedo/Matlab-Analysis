%% Simple GUI for spike detection. Last updated 05_17_2017 by JCT
function filter_sliderGUI(unfiltered_data, piezo, spikeTemplateWidth)
global hp_filter_Slider;global lp_filter_Slider;global threshold_Slider; global diff_Slider; %Define these to be global so subfunction can see sliders and button
global vars;

vars.unfiltered_data = unfiltered_data;
vars.piezo = piezo;
vars.thresh_pos = 840;
vars.lp_pos = 420;
vars.hp_pos = 20;

if ~isfield(vars,'hp_cutoff');vars.hp_cutoff = 100;end%%cutoff frequencies for filtering bristle recording data
filts1 = vars.hp_cutoff/(vars.fs/2);
[x,y] = butter(2,filts1,'high');%%bandpass filter between 50 and 200 Hz
filtered_data_high = filter(x, y, vars.unfiltered_data);

if ~isfield(vars,'lp_cutoff');vars.lp_cutoff = 1000;end %%cutoff frequencies for filtering bristle recording data
filts2 = vars.lp_cutoff/(vars.fs/2);
[x2,y2] = butter(2,filts2,'low');%%bandpass filter between 50 and 200 Hz
filtered_data = filter(x2, y2, filtered_data_high);

if ~isfield(vars,'diff');vars.diff= 1;end
if vars.diff == 0
diff_filt = filtered_data';
elseif vars.diff == 1
diff_filt = [0 diff(filtered_data)'];
diff_filt(1:100) = 0;
elseif vars.diff == 2
diff_filt = [0 0 diff(diff(filtered_data))'];
diff_filt(1:100) = 0;
end

vars.filtered_data = diff_filt;

if ~isfield(vars,'peak_threshold');vars.peak_threshold = 5;end %%initial threshold for finding peaks
[locks, ~] = peakfinder(vars.filtered_data,mean(vars.filtered_data)+vars.peak_threshold *std(vars.filtered_data),[],[],0);%% slightly different algorithm;  [peakLoc] = peakfinder(x0,sel,thresh) returns the indicies of local maxima that are at least sel above surrounding vars.filtered_data and larger (smaller) than thresh if you are finding maxima (minima).
loccs = locks((locks> spikeTemplateWidth)); %%to prevent strange happenings, make sure that spikes do not occur right at the edges
vars.locs = loccs(loccs < (length(vars.filtered_data)-spikeTemplateWidth));

% Make a figure.
close all;
fig = figure('position',[100 100 1200 800], 'NumberTitle', 'off', 'color', 'w');
set(fig,'toolbar','figure');
% Just some descriptive text.

uicontrol('Style', 'text', 'String', {'hp cutoff','(hz)'}, 'Position', [vars.hp_pos 20 90 30]);
uicontrol('Style', 'text', 'String', {'lp cutoff','(hz)'}, 'Position', [vars.lp_pos 20 90 30]);
uicontrol('Style', 'text', 'String', {'peakthreshold','(au)'}, 'Position', [vars.thresh_pos 20 90 30]);
uicontrol('Style', 'text', 'String', {'derivative (0-2)'}, 'Position', [vars.hp_pos 140 90 20]);

% plot_unfilt = 2+2*(vars.unfiltered_data(1:vars.len)'-mean(vars.unfiltered_data(1:vars.len)))/max(abs(vars.unfiltered_data(1:vars.len)));
plot_filt = (vars.filtered_data(1:vars.len)-mean(vars.filtered_data))/max(vars.filtered_data);
plot_piezo = (piezo(1:vars.len)-mean(piezo))/max(piezo)/2-1; 
plot_spikes = vars.locs(vars.locs<vars.len);

plot(plot_spikes, plot_filt(plot_spikes),'ro');hold on;
plot(plot_filt,'k');hold on;
% plot(plot_piezo,'r');%% uncomment to plot piezo signal or another channel

ylim([-1 1]);

hp_filter_Slider = uicontrol('Style','slider','Min',0.5,'Max',1000,...
                'SliderStep',[0.001 0.1],'Value',vars.hp_cutoff,...
                'Position',[vars.hp_pos+100 20 200 30], 'Callback', @filter_GUI);
                vars.hp_cutoff = get(hp_filter_Slider,'Value');
                
lp_filter_Slider = uicontrol('Style','slider','Min',0.11,'Max',1000,...
                'SliderStep',[0.001 0.1],'Value',vars.lp_cutoff,...
                'Position',[vars.lp_pos+100 20 200 30], 'Callback', @filter_GUI);
                 vars.lp_cutoff = get(lp_filter_Slider,'Value');
   
threshold_Slider = uicontrol('Style','slider','Min',1,'Max',20,...
                'SliderStep',[0.002 0.2],'Value',vars.peak_threshold,...
                'Position',[vars.thresh_pos+100 20 200 30], 'Callback', @filter_GUI);
                 vars.peak_threshold = get(threshold_Slider,'Value');
        
                 %% a slider to select first or second derivative
diff_Slider = uicontrol('Style','slider','Min',0,'Max',2,...
                'SliderStep',[0.5 0.5],'Value',round(vars.diff),...
                'Position',[vars.hp_pos+20 100 50 30], 'Callback', @filter_GUI);
                 vars.diff = round(get(diff_Slider,'Value'));
                    
                 
 % Puts the value of the peak_thresholdeter on the GUI.
uicontrol('Style', 'text', 'String', num2str(vars.hp_cutoff),'Position', [vars.hp_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.lp_cutoff),'Position', [vars.lp_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.peak_threshold),'Position', [vars.thresh_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.diff),'Position', [vars.hp_pos+15 75 60 20]);

% A button to reset the view
global Button;
Button = uicontrol('Style', 'pushbutton', 'String', 'Reset Axes',...
'Position', [vars.hp_pos 250 100 30],'Callback', @filter_GUI);

end
   


%% Called by GUI to do the plotting
% hObject is the button and eventdata is unused.
function filter_GUI(hObject,eventdata)
global hp_filter_Slider;global lp_filter_Slider;global threshold_Slider;global Button;global diff_Slider;%Define this to be global so subfunction can see slider
global vars;
 
% Gets the value of the peak_thresholdeter from the slider.
xx = get(gca,'XLim'); 
yy = get(gca,'YLim');
vars.hp_cutoff = get(hp_filter_Slider,'Value');
vars.lp_cutoff = get(lp_filter_Slider,'Value');
vars.peak_threshold = get(threshold_Slider,'Value');
vars.diff = round(get(diff_Slider,'Value'));


filts = vars.hp_cutoff/(vars.fs/2);
[x,y] = butter(4,filts,'high');%%bandpass filter between 50 and 200 Hz
filtered_data_high = filter(x, y, vars.unfiltered_data);

filts = vars.lp_cutoff/(vars.fs/2);
[x2,y2] = butter(2,filts,'low');%%bandpass filter between 50 and 200 Hz
filtered_data = filter(x2, y2, filtered_data_high);

if vars.diff == 0
diff_filt = filtered_data';
elseif vars.diff == 1
diff_filt = [0 diff(filtered_data)'];
diff_filt(1:100) = 0;
elseif vars.diff == 2
diff_filt = [0 0 diff(diff(filtered_data))'];
diff_filt(1:100) = 0;
end

vars.filtered_data = diff_filt;

[locks, ~] = peakfinder(double(vars.filtered_data),mean(vars.filtered_data)+vars.peak_threshold*std(vars.filtered_data));%% slightly different algorithm;  [peakLoc] = peakfinder(x0,sel,thresh) returns the indicies of local maxima that are at least sel above surrounding vars.filtered_data and larger (smaller) than thresh if you are finding maxima (minima).
loccs = locks((locks> vars.spikeTemplateWidth)); %%to prevent strange happenings, make sure that spikes do not occur right at the edges
vars.locs = loccs(loccs < (length(vars.filtered_data)-vars.spikeTemplateWidth));

% Puts the value of the peak_thresholdeter on the GUI.
uicontrol('Style', 'text', 'String', num2str(vars.hp_cutoff),'Position', [vars.hp_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.lp_cutoff),'Position', [vars.lp_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.peak_threshold),'Position', [vars.thresh_pos+300 20 60 20]);
uicontrol('Style', 'text', 'String', num2str(vars.diff),'Position', [vars.hp_pos+15 75 60 20]);

% plot_unfilt = 2+2*(vars.unfiltered_data(1:vars.len)-mean(vars.unfiltered_data(1:vars.len)))/max(abs(vars.unfiltered_data(1:vars.len)));
plot_filt = (vars.filtered_data(1:vars.len)-mean(vars.filtered_data))/max(vars.filtered_data);
plot_piezo =(vars.piezo(1:vars.len)-mean(vars.piezo))/max(vars.piezo)/2-1;
plot_spikes = vars.locs(vars.locs<vars.len);

hold off;
plot(plot_spikes, plot_filt(plot_spikes),'ro');hold on;
% plot(plot_unfilt, 'b');hold on;
plot(plot_filt,'k');hold on;
% plot(plot_piezo,'r'); %%uncomment to plot piezo signal
xlim(xx);ylim(yy);hold off;

button_state = get(Button,'Value');
if button_state == get(Button,'Max')
xlim([1 length(vars.filtered_data)]);ylim([-1 1]);hold off;
elseif button_state == get(Button,'Min')
xlim(xx);ylim(yy);hold off;
end

end
 

 