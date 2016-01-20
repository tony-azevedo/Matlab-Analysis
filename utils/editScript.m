filename = 'Record_FS.m';

f = fopen(filename);
pcpath = getpref('USERDIRECTORY','PC');
pcpath = regexprep(pcpath,'\\','\\\')
macpath = getpref('USERDIRECTORY','MAC');

[fullpath] = fopen(f);
fclose(f);

dirpath = fullpath(1:regexp(fullpath,filename)-1);

mkdir(fullfile(dirpath,'Records_PC'))

% back up the file in the PC directory
copyfile(fullpath,fullfile(dirpath,'Records_PC'))

t = fileread(filename);

snip = t(1:400);
snip = regexprep(snip,pcpath,macpath)
snip = regexprep(snip,'\\',filesep)

f = fopen(fullpath,'w');
fprintf(f,snip)
fclose(f);
