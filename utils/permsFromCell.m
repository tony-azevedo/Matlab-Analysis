function pmat = permsFromCell(cellofvecs)

targetind = ones(length(cellofvecs),1);
for c = 1:length(cellofvecs)
    targetind(c) = length(cellofvecs{c});
end
target = prod(targetind);
pmat = nan(length(cellofvecs),target);

repeats = 1;
for c = 1:length(cellofvecs)
    vec = cellofvecs{c};
    unit = repmat(vec,repeats,1);
    repeatmat = repmat(unit,1,target/size(unit,2)/repeats);
    pmat(c,:) = repeatmat(:)';
    repeats = repeats*length(vec);
end

