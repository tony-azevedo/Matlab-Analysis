function ax = plotMatrixRaster(s,varargin)
% s is a matrix of spikes in time, columns are trials

if nargin>1
    t = varargin{1};
else
    t = 1:size(s,1);
    t = t(:);
end

ax = gca;
axes(ax);
for c = 1:size(s,2)
    r = size(s,2)-c+1;
    sp_times = find(s(:,c));
    r = repmat(size(s,2)-c+1,size(sp_times));
    
    linesH = line([t(sp_times)'; t(sp_times)'],[r' - 0.4; r' + 0.4]);
    set(linesH,'color','k');
end
ylabel(ax, 'Trial Number');
xlabel(ax, 'Time (s)');
set(ax,'ytick',1:c);
xlim(ax,[0 t(end)]);
ylim(ax,[0 c+1]);

set(ax,'tag','plotAxis'); %reset tag (it was getting lost - I don't know how)

