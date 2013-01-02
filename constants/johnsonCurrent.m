function rms = johnsonCurrent(R,T,deltaF)
% johnson noise in current as a function of temp T, bandwidth deltaF, R
rms = sqrt(4*kb*T*deltaF/R);