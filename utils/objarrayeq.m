function indices = objarrayeq(a,b)
% objarrayeq
%   Returns a logical array comparing elements in array A to object b (or
%   vice versa
%
% indices = objarrayeq(a,b)

if ~(length(a) == 1 || length(b) == 1)
    error('One input must be a single object')
end
if length(a) > 1
    arr = a;
    obj = b;
else
    arr = b;
    obj = a;
end

indices = zeros(length(arr),1);
for i = 1:length(indices)
    indices(i) = arr(i)==obj;
end
indices = logical(indices);