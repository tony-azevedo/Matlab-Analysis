function s = myFunc2str(f)
if iscell(f)
    for i=1:length(f)
        if strcmp(class(f{i}),'function_handle')
            s{i} = func2str(f{i});
        else
            s{i} = f{i};
        end
    end
elseif strcmp(class(f),'function_handle')
    s = func2str(f);
else
    s = f;
end

