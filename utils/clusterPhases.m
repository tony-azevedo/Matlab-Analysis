function phase_out = clusterPhases(phase_in,varargin)
% phase measurements from multiple fourier transforms can sometimes be
% close, but noise may separate the measurements by two pi.  This function
% relaxes the phase range to be able to cluster measurements on the
% -pi+eps, pi+eps range.

phase_out = phase_in;
numind = find(~isnan(phase_in));
ph = phase_in(numind);
dist = ph;
for i = 1:length(ph)
    dist(i) = sum(sum(distmat(ph)));
end

% move each phase by 2pi, repeat for half the phases
for rep = 1:length(ph)/2;
    dist_1 = ph;
    for i = 1:length(ph)
        tph = ph;
        if tph(i)>0
            tph(i) = tph(i)-2*pi;
        else
            tph(i) = tph(i)+2*pi;
        end
        dist_1(i) = sum(sum(distmat(tph)));
    end
    if sum(dist_1<dist)
        if ph(dist_1<dist)>0
            ph(dist_1<dist) = ph(dist_1<dist)-2*pi;
        else
            ph(dist_1<dist) = ph(dist_1<dist)+2*pi;
        end
    end
end

phase_out(numind) = ph;