function scaleFactor = getOptimalScaleFactor(x,y,bounds)
%get scale factor a to minimize sum square error of a*x and y

scaleFactor = fminbnd(@(a) sum(((a.*x) - y).^2) ,bounds(1),bounds(2));
