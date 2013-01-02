function results = plotRaster(s,varargin)
if nargin>1
    t = varargin{1};
end

ax = gca;
axes(ax);
for c=
linesH = line([sp_times'; sp_times'],[trial_numbers' - 0.4; trial_numbers' + 0.4]);
set(linesH,'color','k');
ylabel(ax, 'Trial Number');
xlabel(ax, 'Time (s)');
set(ax,'ytick',1:Ntrials);
xlim(ax,[0 duration]);
ylim(ax,[0 Ntrials+1]);

set(ax,'tag','plotAxis'); %reset tag (it was getting lost - I don't know how)

