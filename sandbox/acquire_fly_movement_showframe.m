function acquire_fly_movement_showframe(vid,~)
% This callback function triggers the acquisition and saves frames to an AVI file.

% Copyright 2011 The MathWorks, Inc.

global acquire_sandbox_dispax

frame =  peekdata(vid,1);

imshow(frame,'initialmagnification',50,'parent',acquire_sandbox_dispax);

