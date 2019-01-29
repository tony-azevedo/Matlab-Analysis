fid = fopen('tester.bin','w');
% fwrite(fid,'header')
% fwrite(fid,'header2')

%id = fopen('test.txt','w');
m = [(1:100000);
    .01*(1:100000)];

fwrite(fid,m','double')
fclose(fid);

%%

fid = fopen('tester.txt','w');
m = [(1:100000);
    .01*(1:100000)];
fprintf(fid,'%g\t%g\n',m);
fclose(fid);

%fprintf(obj.fid,'%g\t%g\t%g\n',in(:,1),in(:,2),in(:,3));

%% create header with data

filename = 'C:\Users\tony\Acquisition\170104\170104_F2_C1\Acquire_ContRaw_170104_F2_C1_1.bin';
info = 'protocol Acquire mode VClamp gain 20 samprate 10000';
fid = fopen('headertester.bin','w');

fnl = fwrite(fid,length(filename),'uint');
fn = fwrite(fid,filename,'char');
inl = fwrite(fid,length(info),'uint');
in = fwrite(fid,info,'char');

m = [(1:100000);
    .01*(1:100000)];

fwrite(fid,m,'double');

fclose(fid);

%%
fid = fopen('headertester.bin','a');

m = [(1:100000);
    .03*(1:100000)];

fwrite(fid,m,'double');

m = [(1:100000);
    .06*(1:100000)];

fwrite(fid,m,'double');

m = [(1:100000);
    .09*(1:100000)];

fwrite(fid,m,'double');

%%

infid = fopen('headertester.bin','r');
fnl = fread(infid, 1, 'uint')';
fn = char(fread(infid, fnl, 'char')');
inl = fread(infid, 1, 'uint')';
in = char(fread(infid, inl, 'char')');

A = fread(infid,[2 inf], 'double')';
plot(A)
%ylabel(fn)
xlabel(in)
fclose(infid)


%% 
infid = fopen('Acquire_ContRaw_170118_F0_C1_13.bin','r');
fnl = fread(infid, 1, 'uint')';
fn = char(fread(infid, fnl, 'char')');
inl = fread(infid, 1, 'uint')';
in = char(fread(infid, inl, 'char')');
innl = fread(infid, 1, 'uint')';
innames = char(fread(infid, innl, 'char')');

A = fread(infid,[3 inf], 'double')';
subplot(3,1,1)
plot(A(:,1))
subplot(3,1,2)
plot(A(:,2))
subplot(3,1,3)
plot(A(:,3))
ylabel(innames)
xlabel(in)
fclose(infid);


