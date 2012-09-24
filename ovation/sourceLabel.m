function l = sourceLabel(src)
if isempty(src)
l = '';
return
end
l_end = sourceLabel(src(1).getChildren);
l = sprintf('%s => %s',char(src(1).getLabel),l_end);
if isempty(l_end), l = l(1:end-4); end
