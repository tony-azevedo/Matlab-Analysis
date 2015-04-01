function varargout = loadScimStack(imdir)
% return I0, (x,y,t,channel)

%%  Load the frames from the Image directory

%[filename, pathname] = uigetfile('*.tif', 'Select TIF-file');
prot = fliplr(strtok(fliplr(imdir),'\'));
ind = regexp(prot,'_','end');
prot = prot(1:ind(1)-1);
imagefiles = dir(fullfile(imdir,[prot '_Image_*']));
if length(imagefiles)==0
    error('No Camera Input: Exiting %s routine',mfilename);
end
i_info = imfinfo(fullfile(imdir,imagefiles(1).name));
chans = regexp(i_info(1).ImageDescription,'state.acq.acquiringChannel\d=1');
num_chan = length(chans);

num_frame = round(length(i_info)/num_chan);
im = imread(fullfile(imdir,imagefiles(1).name),'tiff','Index',1,'Info',i_info);
num_px = size(im);

I0 = zeros([num_px(:); num_frame; num_chan]', 'double');  %preallocate 3-D array
%read in .tif files
tic; fprintf('Loading: '); 
for frame=1:num_frame
    for chan = 1:num_chan
        [I0(:,:,frame,chan)] = imread(fullfile(imdir,imagefiles(1).name),'tiff',...
            'Index',(2*(frame-1)+chan),'Info',i_info);
    end
end
toc

varargout = {I0,i_info};
