function [x_out,y_out] = rectangularizeXYCells2(x,y)

xmin = Inf;
xmax = -Inf;
for c = 1:length(x)
    xmin = min(xmin,min(x{c}));
    xmax = max(xmax,max(x{c}));
end
x_out = x{c}(x{c}>=xmin & x{c}<=xmax);
y_out = zeros(c,length(x_out));
for c = 1:length(x)
    y_out(c,:) = y{c}(x{c}>=xmin & x{c}<=xmax);
end

