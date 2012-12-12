function [r,tr] = predict(c,stim,tpost,samprate)
% [r,tr] = predict(c,stim,tpost,samprate)
% predict the response to stim using linear kernal c
% tpost is time in kernal after zero (msec)

c = c(:);
stim = stim(:);
r = conv(flipud(c),stim);  
r = r(tpost*samprate/1000+1:end);
r = r(1:length(stim));
tr = (1:length(r))/samprate;
ts = (1:length(stim))/samprate;

%scale = max(r)/5;

% figure; 
% hold on;
% plot(tr,r);
% plot(ts,scale*stim/max(stim),'r');
% axis([0 max(ts) 0 max(r)]);