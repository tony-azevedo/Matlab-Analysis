function c = generateColorWheel(varargin)
if nargin < 2
    t = 10;
else
    t = varargin{2};
end
c = zeros(t^3,3);
ind = 0;
for i = 1:t
    for j = 1:t
        for k = 1:t
            ind = ind+1;
            c(ind,:) = [i,j,k]/t;
        end
    end
end
c = c(randperm(t^3),:);
if nargin>0
    c = c(varargin{1},:);
end