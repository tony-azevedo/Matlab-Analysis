% Ovation test epochs script
% 24-Sep-2012

%% Queries
%itr = context.query('Epoch', ...
%    'epochGroup.label == "drug" && not(any(keywords(), tag == "private"))');

itr = context.query(Epoch.class, ...
    'as(getProtocolParamter[KEY == "stepsInFamily"], class:ovation.IntegerValue).value == 6');

itr = context.query(Epoch.class, ...
    'as(protocolParamter[KEY == "stepsInFamily"], class:ovation.IntegerValue).value == 6');

itr = context.query(Epoch.class, ...
    'as(protocolParamter[KEY == "version"], class:ovation.IntegerValue).value == 1');

itr.hasNext

%%
query = ovation.editQuery;
itr = context.query(query); 

cnt = 0;
while itr.hasNext
    cnt = cnt+1;
    e = itr.next;
    printEpochParams(e);
end
fprintf('\n%g Epochs\n',cnt);

% notes:
%   owner - user name - tony: 24 epochs
%   starttime - > - 12/9/10: 24 epochs
%   protocolID - org.janelia.research.murphy.LEDFamily : 24 Epochs
%   protocols are not working...
%   Stimuli -> Any -> External Device -> Name - LED: 24 Epochs
%   Stimuli - All - Stimulus Parameters - stepsInFamily - 6: 0