function [x_out,y_out] = rectangularizeXYCellsOfMats(x,y)

xmin = Inf;
xmax = -Inf;
for c = 1:length(x)
    xmin = max(xmin,min(x{c}));
    xmax = min(xmax,max(x{c}));
end
x_out = x{c}(x{c}>=xmin & x{c}<=xmax);
y_out = [];
for c = 1:length(x)
    y_out = [y_out;y{c}(:,x{c}>=xmin & x{c}<=xmax)];
end

