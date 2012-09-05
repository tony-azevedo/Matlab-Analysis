function handles = makeFigureHandles(figH)

handles = containers.Map;
tag = get(figH,'tag');
handles(tag) = figH;

ch = get(figH,'children');
if isempty(ch)
    return;
else
    for i=1:length(ch) %for each child
        handles = [handles; makeFigureHandles(ch(i))]; %recursive call on each child
    end   
end
