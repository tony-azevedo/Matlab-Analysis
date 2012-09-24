function l = depth(obj)

l = 0;
pnt = obj;
while ~isempty(pnt.getParent)
    pnt = pnt.getParent;
    l = l+1;
end