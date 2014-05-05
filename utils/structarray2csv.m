function structarray2csv(s,fn)
% STRUCT2CSV(s,fn)
%
% Output a structure to a comma delimited file with column headers
%
%       s : any structure composed of one or more matrices and cell arrays
%      fn : file name
%
%      Given s:
%
%          s.Alpha = { 'First', 'Second';
%                      'Third', 'Fourth'};
%
%          s.Beta  = [[      1,       2;
%                            3,       4]];
%          
%          s.Gamma = {       1,       2;
%                            3,       4};
%
%          s.Epsln = [     abc;
%                          def;
%                          ghi];
% 
%      STRUCT2CSV(s,'any.csv') will produce a file 'any.csv' containing:
%
%         "Alpha",        , "Beta",   ,"Gamma",   , "Epsln",
%         "First","Second",      1,  2,      1,  2,   "abc",
%         "Third","Fourth",      3,  4,      3,  4,   "def",
%                ,        ,       ,   ,       ,   ,   "ghi",
%    
%      v.0.9 - Rewrote most of the code, now accommodates a wider variety
%              of structure children
%
% Written by James Slegers, james.slegers_at_gmail.com
% Covered by the BSD License
%

FID = fopen(fn,'w');
headers = fieldnames(s);
m = length(headers);
sz = zeros(length(headers),2);

t = length(s);

l = '';
for ii = 1:length(headers)
    l = [l,'"',headers{ii},'",'];
end
l = l(1:end-1); % trailing comma
l = [l,'\n'];

fprintf(FID,l);

for rr = 1:t
    l = '';
    for c_ind = 1:length(headers)

        c = s(rr).(headers{c_ind});
        str = '';
        
        if isnumeric(c)
            if isempty(c), break, end
            str = num2str(c(1));
            for i_ind = 2:numel(c)
                str = [str,'/',num2str(c(i_ind),10)];
            end
        elseif islogical(c)
            str = num2str(c(1));
            for i_ind = 2:numel(c)
                str = [str,'/',num2str(c(i_ind),10)];
            end
        elseif ischar(c)
            str = c;
        elseif iscell(c)
            c = c(:)';
            if isempty(c)
                str = num2str(NaN);
            else
                str = '';
                for i_ind = 1:numel(c)
                    if isnumeric(c{i_ind})
                        str = [str,'/',num2str(c{i_ind},10)];
                    elseif islogical(c{i_ind})
                        str = [str,'/',num2str(c{i_ind},10)];
                    elseif ischar(c{i_ind})
                        str = [str,'/',c{i_ind}];
                    end
                end    
                str = str(2:end);  % leading slash
            end
        end
        l = [l,str,','];
    end
    l = l(1:end-1); % trailing comma
    fprintf(FID,l);
    fprintf(FID,'\n');
end

fclose(FID);
