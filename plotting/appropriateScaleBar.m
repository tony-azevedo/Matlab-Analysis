function bary = appropriateScaleBar(y)

baryexp = floor(log10(diff(y)));
bary = floor(diff(y)/10^baryexp);
bary = bary/2*10^baryexp;