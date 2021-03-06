function ticks = raster(ax,x,y_point,varargin)
% ticks = raster(ax,x,y_point)
% Plots a spike raster at spike times x, with y points [y1,y2] on axis ax.
% Returns an object array, ticks, of handles to the raster points.
% 
% ticks = raster(ax,x,y_point,YLIMS)
% Optional input YLIMS sets the ax.YLim property.
% 
% example usage: 
% rasterfig = figure;
% ax = subplot(1,1,1,'parent',rasterfig)
% ticks = raster(ax,spiketimes,[-.5 .5],[-2 2]);
% set(ticks,'linewidth',.5,'color',[1 0 1]);

if isempty(x)
    ticks = [];
    return
end
if nargin>3
    ylims = varargin{1};
else
    ylims = ax.YLim;
end

if nargin>4
    clr = varargin{2};
else
    clr = [0 0 0];
end


holdstrt = ax.NextPlot;
ax.NextPlot = 'add';

a = size(x);
if a(1)>sqrt(numel(x))
    x = x';
else
    x = x;
end
a = size(x);

if numel(y_point)<2
    bar = diff(ylims)*.08;
    gap = bar/5;
else
    bar = diff(y_point);
    y_point = y_point(1);
    gap = bar/5;
end

tick = line(x(1,1),y_point);
ticks = repmat(tick,size(x));
delete(tick);
for r = size(x,1):-1:1
    cnt = size(x,1)-r;
    ticks(r,:) = plot(ax,repmat(x(r,:),2,1),repmat([cnt*(bar+gap); bar] + y_point,1,a(2)),'color',clr);
end

ax.NextPlot = holdstrt;