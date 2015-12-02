function fig = HHPlot(T,V,I_na,I_k,I_l,I_inj,m,h,n)

fig = figure;
set(fig,'color',[1 1 1],'position',[680 195 1083 783],'name','HH Plot');

pnl = panel(fig);
pnl.margin = [20 20 20 20];
pnl.pack('v',{1/9 4/9 4/9});
pnl.de.margin = [10 10 10 10];

line(T,V,'parent',pnl(1).select(),...
    'color',[0 0 0],'displayname','V');
pnl(1).ylabel('mV');
legend(pnl(1).select(),'toggle');
legend(pnl(1).select(),'boxoff');
set(pnl(1).select(),'xtick',[],'xcolor',[1 1 1])

if ~isempty(I_na)
line(T,I_na,'parent',pnl(2).select(),...
    'color',[1 0 0],'displayname','I_na');
end
if ~isempty(I_k)
line(T,I_k,'parent',pnl(2).select(),...
    'color',[0 0 1],'displayname','I_k');
end
if ~isempty(I_l)
line(T,I_l,'parent',pnl(2).select(),...
    'color',[0 1 0],'displayname','I_l');
end
pnl(2).ylabel('pA');
legend(pnl(2).select(),'toggle');
legend(pnl(2).select(),'boxoff');

if ~isempty(I_inj)
line(T,I_inj,'parent',pnl(2).select(),...
    'color',[0 0 0],'displayname','I_inj');
else
line(T,I_na+I_k+I_l,'parent',pnl(2).select(),...
    'color',[1 1 1]*.8,'displayname','I_t');
end

line(T,m,'parent',pnl(3).select(),...
    'color',[.7 0 0],'displayname','m');
line(T,h,'parent',pnl(3).select(),...
    'color',[1 .7 .7],'displayname','h');
line(T,m.^3.*h,'parent',pnl(3).select(),...
    'color',[1 0 0],'linewidth',2,'displayname','gNa');
line(T,n,'parent',pnl(3).select(),...
    'color',[.7 .7 1],'displayname','n');
line(T,n.^4,'parent',pnl(3).select(),...
    'color',[0 0 1],'linewidth',2,'displayname','gK');

pnl(3).ylabel('p_0');
pnl(3).xlabel('ms');
legend(pnl(3).select(),'toggle');
legend(pnl(3).select(),'boxoff');

linkaxes([pnl(1).select() pnl(2).select() pnl(3).select()],'x')
