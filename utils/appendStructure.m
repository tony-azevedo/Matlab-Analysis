function struct1 = appendStructure(struct1,struct2)

if length(struct1) ~= length(struct2);
    error('Structure arrays must have the same number of elements to append')
end
fields = fieldnames(struct2(1));
for e = 1:length(struct1)
    for name = 1:length(fields)
        struct1(e).(fields{name}) = struct2(e).(fields{name});
    end
end