function X = sem(X,dim)
ndim = 1;
if dim==1
    ndim = 2;
end
num = std(X,[],dim);
den = sqrt(size(X,ndim));
X = num./den;