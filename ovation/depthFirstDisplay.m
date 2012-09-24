function touched = depthFirstDisplay(source,varargin)
% explore sources depth first, use for any hierarchy?


sources = context.getSources();

ind = zeros(length(sources),1);
touched = ind;
for s = 1:length(ind)
    ind(s) = isempty(sources(s).getParent);
end
sourceparents = sources(logical(ind));


for sp = 1:sum(ind)    
    source = sourceparents(sp);
    touched(objarrayeq(sources, source)) = 1;
    
    fprintf('%s',source.getLabel)
    if ~isempty(source.getChildren)
        fprintf('with child: \n')
        tbstr = '\t';
    else
        fpritnf('\n\n')
    end
    while ~isempty(source.getChildren)
        source.
        if ~isempty(source.getChildren)
            fprintf('with child: \n')
            tbstr = '\t';
        else
            fpritnf('\n\n')
        end
    end
end

