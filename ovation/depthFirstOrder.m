function varargout = depthFirstOrder(sources,varargin)
% reorder hierarchical array

if nargin>1
    cnt = varargin{1};
else
    cnt = 1;
end

in = false(length(sources),1);
out = false(length(sources),1);

while cnt<=length(sources)
    % start with a parent.  After that, just go along the array
    pnt = cnt;
    while ~isempty(sources(pnt).getParent)
        pnt = pnt+1;
    end
    %swap elements, parent first
    temp = sources(cnt);
    sources(cnt) = sources(pnt);
    sources(pnt) = temp;
    
    orderedarr = deptharr(sources(cnt));
    
    el = length(orderedarr);
    
    in(:) = false;
    out(:) = false;
    
    for pnt = cnt:cnt+el-1
        out(pnt) = ~sum(objarrayeq(sources(pnt),orderedarr));
    end
    for pnt = cnt+el:length(sources)
        in(pnt) = sum(objarrayeq(sources(pnt),orderedarr));
    end
    if sum(in) == sum(out) && sum(in)>0
    sources(in) = sources(out);
    elseif sum(in)>0
        error('elements in and elements out don''t match');
    end
    
    sources(cnt:cnt + el-1) = orderedarr;

    cnt = cnt+el;
end
varargout = {sources};
end


function oa = deptharr(source)

if isempty(source.getChildren)
    %don't change the order
    oa = source;
    return
end

oa = source;
chi = source.getChildren;
for c = 1:length(chi)
    oa = [oa,deptharr(chi(c))];
end
end