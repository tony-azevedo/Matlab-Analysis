function str = printEpochParams(e)

p = e.getProtocolParameters;
keys = p.keySet.toArray;
mkeys = cell(keys);
str = '';
for k = 1:length(keys)
    str = sprintf('%s%s',str,mkeys{k});
    val = p.get(keys(k));
    if isnumeric(p.get(keys(k)))
        str = sprintf('%s = %g\n',str,val);
    else
        str = sprintf('%s = %s\n',str,char(val));        
    end
end
disp(str)