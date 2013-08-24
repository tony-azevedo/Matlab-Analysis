function h = makeFigureStruct(h,varargin)
if nargin>1
    prefix = varargin{1};
    if ~strcmp(prefix(end),'_')
        prefix = [prefix,'_'];
    end
end

ch = get(h,'children');
moving_ch = [];

for i=1:length(ch)
    if ~isprop(ch(i),'style') || ~strfind(get(ch(i),'style'), 'button')
        moving_ch = [moving_ch ch(i)];
    end
end

for c = 1:length(moving_ch)
    prompt{c} = sprintf('Axis %d',c);
    def{c} = get(moving_ch(c),'tag');
end
dlg_title = 'Axis name';

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer = inputdlg(prompt,dlg_title,1,def,options);

for c = 1:length(moving_ch)
    makeAxisStruct(moving_ch(c),[prefix,answer{c}]);
end

end