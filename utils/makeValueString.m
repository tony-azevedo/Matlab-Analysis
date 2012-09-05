function s = makeValueString(var)
%return a value string for a variable, like in Matalb workspace
if ischar(var)
    s = var;
elseif isscalar(var) && isnumeric(var)
    s = num2str(var);
elseif isempty(var)
    s = '';
else
    varSize = size(var);
    Ndims = length(varSize);
    sizeStr = num2str(varSize(1));
    for i=2:Ndims
        sizeStr = [sizeStr 'x' num2str(varSize(i))];
    end
    s = ['<' sizeStr ' ' class(var) '>'];
end
