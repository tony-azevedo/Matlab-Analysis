fig = figure(1);
%%
wtax = subplot(3,2,1,'parent',fig);
wt_counts_0min = [
    0.0993	0.1696	0.0855	0.1354
    0.2677	0.1696	0.1116	0.2087
    0.1995	0.1496	0.103	0.1654
    0.1587	0.1232	0.097	0.115
    0.1038	0.1324	0.1306	0.0824
    0.0534	0.1238	0.1294	0.0492
    0.1175	0.1318	0.3427	0.2438];

wt_group_0min = {
    '6P' '6P' '6P' '6P' 
    '5P' '5P' '5P' '5P' 
    '4P' '4P' '4P' '4P' 
    '3P' '3P' '3P' '3P' 
    '2P' '2P' '2P' '2P' 
    '1P' '1P' '1P' '1P' 
    '0P' '0P' '0P' '0P' 
    };

boxplot(flipud(wt_counts_0min(:)),flipud(wt_group_0min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')
ylim([0 .8])
%%
wtax = subplot(3,2,2,'parent',fig);
wt_counts_5min = [...
    0.2212	0.1984	0.1562
    0.2555	0.1984	0.1494
    0.1659	0.1669	0.1046
    0.1735	0.1334	0.0905
    0.1257	0.1198	0.0871
    0.0386	0.1175	0.1244
    0.0195	0.0654	0.2877];

wt_group_5min = {
    '6P' '6P' '6P' 
    '5P' '5P' '5P'
    '4P' '4P' '4P' 
    '3P' '3P' '3P'
    '2P' '2P' '2P'
    '1P' '1P' '1P' 
    '0P' '0P' '0P' 
    };
boxplot(flipud(wt_counts_5min(:)),flipud(wt_group_5min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')
ylim([0 .8])

%%
stmax = subplot(3,2,3,'parent',fig);
stm_counts_0min = [...
    0.028	0.0066	0.1217	0.1137	0.0215,...
    0.0696	0.1369	0.3476	0.2041	0.1088,...
    0.2783	0.3296	0.3582	0.2246	0.2231,...
    0.6241	0.5268	0.1724	0.4576	0.6466];

stm_group_0min = {
    '3P' '3P' '3P' '3P'  '3P' 
    '2P' '2P' '2P' '2P'  '2P' 
    '1P' '1P' '1P' '1P' '1P' 
    '0P' '0P' '0P' '0P' '0P' 
    };
boxplot(flipud(stm_counts_0min(:)),flipud(stm_group_0min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')
ylim([0 .8])

%%
stmax = subplot(3,2,4,'parent',fig);
stm_counts_5min = [...
    0.01674	0.0128
    0.06458	0.1482
    0.2478	0.3588
    0.671	0.4801];

stm_group_5min = {
    '3P' '3P'
    '2P' '2P'
    '1P' '1P'
    '0P' '0P'
    };

boxplot(flipud(stm_counts_5min(:)),flipud(stm_group_5min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')
ylim([0 .8])

%%
ttmax = subplot(3,2,5,'parent',fig);
ttm_counts_0min = [...
    0.3164	0.4102
    0.4182	0.4553
    0.215	0.0722
    0.0504	0.0622];

ttm_group_0min = {
    '3P' '3P' 
    '2P' '2P' 
    '1P' '1P' 
    '0P' '0P' 
    };

boxplot(flipud(ttm_counts_0min(:)),flipud(ttm_group_0min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')
ylim([0 .8])

%%
ttmax = subplot(3,2,6,'parent',fig);
ttm_counts_5min = [
    0.291	0.2967
    0.3492	0.3821
    0.2527	0.185
    0.1071	0.1361];

ttm_group_5min = {
    '3P' '3P' 
    '2P' '2P' 
    '1P' '1P' 
    '0P' '0P' 
    };

boxplot(flipud(ttm_counts_5min(:)),flipud(ttm_group_5min(:)),...
    'plotstyle','compact',...
    'medianstyle','line')

ylim([0 .8])
