% Start with a folder and get a list of all subfolders.  Use with R2016b and later.
% It's done differently with R2016a and earlier, with genpath().
% Finds and prints names of all files in that folder and all of its subfolders.
% Similar to imageSet() function in the Computer Vision System Toolbox: http://www.mathworks.com/help/vision/ref/imageset-class.html

% Initialization steps:
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;

% Define a starting folder.
start_path = fullfile(matlabroot, '\toolbox');
if ~exist(start_path, 'dir')
	start_path = matlabroot;
end
% Ask user to confirm the folder, or change it.
uiwait(msgbox('Pick a starting folder on the next window that will come up.'));
topLevelFolder = uigetdir(start_path);
if topLevelFolder == 0
	return;
end
fprintf('The top level folder is "%s".\n', topLevelFolder);

% Specify the file pattern.
% Get ALL files using the pattern *.*
% Note the special file pattern.  It has /**/ in it if you want to get files in subfolders of the top level folder.
% filePattern = sprintf('%s/**/*.m; %s/**/*.xml', topLevelFolder, topLevelFolder);
filePattern = sprintf('%s/**/*.m', topLevelFolder);
allFileInfo = dir(filePattern);

% % Uncomment this if you want to get two patterns.m and .fig files.
% 	% Get m files.
% 	filePattern = sprintf('%s/*.m', topLevelFolder);
% 	allFileInfo = dir(filePattern);
% 	% Add on FIG files.
% 	filePattern = sprintf('%s/*.fig', topLevelFolder);
% 	allFileInfo = [allFileInfo; dir(filePattern)];

% Uncomment this if you want to get image files.
% 	% Get PNG files.
% 	filePattern = sprintf('%s/*.png', thisFolder);
% 	baseFileNames = dir(filePattern);
% 	% Add on TIF files.
% 	filePattern = sprintf('%s/*.tif', thisFolder);
% 	baseFileNames = [baseFileNames; dir(filePattern)];
% 	% Add on JPG files.
% 	filePattern = sprintf('%s/*.jpg', thisFolder);
% 	baseFileNames = [baseFileNames; dir(filePattern)];

% Throw out any folders.  We want files only, not folders.
isFolder = [allFileInfo.isdir]; % Logical list of what item is a folder or not.
% Now set those folder entries to null, essentially deleting/removing them from the list.
allFileInfo(isFolder) = [];
% Get a cell array of strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
listOfFolderNames = unique({allFileInfo.folder});
numberOfFolders = length(listOfFolderNames);
fprintf('The total number of folders to look in is %d.\n', numberOfFolders);

% Get a cell array of base filename strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
listOfFileNames = {allFileInfo.name};
totalNumberOfFiles = length(listOfFileNames);
fprintf('The total number of files in those %d folders is %d.\n', numberOfFolders, totalNumberOfFiles);

% Process all files in those folders.
totalNumberOfFiles = length(allFileInfo);
% Now we have a list of all files, matching the pattern, in the top level folder and its subfolders.
if totalNumberOfFiles >= 1
	for k = 1 : totalNumberOfFiles
		% Go through all those files.
		thisFolder = allFileInfo(k).folder;
		thisBaseFileName = allFileInfo(k).name;
		fullFileName = fullfile(thisFolder, thisBaseFileName);
% 		fprintf('     Processing file %d of %d : "%s".\n', k, totalNumberOfFiles, fullFileName);

		[~, baseNameNoExt, ~] = fileparts(thisBaseFileName);
		fprintf('%s\n', baseNameNoExt);
	end
else
	fprintf('     Folder %s has no files in it.\n', thisFolder);
end
fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

