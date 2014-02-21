function importCellBlocks(cellD,cellID,experiment,cellSource)                              

import ovation.*
context = cellSource.getDataContext;

cd(fullfile(cellD,cellID.name))
rawfs = dir([fullfile(cellD,cellID.name),'\*_Raw_*']);

protocols = {};
for i = 1:length(rawfs)
    ind = regexpi(rawfs(i).name,'_');
    if ~isempty(strfind(char(65:90),rawfs(i).name(1))) && ...
            ~isempty(ind) && ...
            ~sum(strcmp(protocols,rawfs(i).name(1:ind(1)-1)))
        protocols{end+1} = rawfs(i).name(1:ind(1)-1);
    end
end

blockEpochGroupsArray = asarray(experiment.getEpochGroups);

rigs = dir('*Rig*');
for r = 1:length(rigs)
    if ~isempty(strfind(rigs(r).name,'Camera'))
        rigs = dir('*Camera*Rig*');
    end
end


for p = 1:length(protocols)
    % get the protocol, data structure array, trialStem, blocks
    protocol = protocols{p};
    eval(['flySoundProtocol = ' protocol ';']);
    requiredRig = flySoundProtocol.requiredRig;
    requiredRig = regexprep(requiredRig,'Rig','');
    requiredRig = regexprep(requiredRig,'Basic','');
    for r = 1:length(rigs)
        if ~isempty(strfind(rigs(r).name,requiredRig))
            rig = load(rigs(r).name);
            break
        end
    end
    rig = rig.rigStruct;
    
    
    ovProtocol = context.getProtocol([protocol '.m']);
    if(isempty(protocol))
        error('No protocol with label %s',protocol);
    end
    rawfs = dir([fullfile(cellD,cellID.name),'\', protocol, '_Raw_*']);

    ind_ = regexp(rawfs(1).name,'_');
    indDot = regexp(rawfs(1).name,'\.');
    trialStem = [rawfs(1).name((1:length(rawfs(1).name)) <= ind_(end)) '%d' rawfs(1).name(1:length(rawfs(1).name) >= indDot(1))];
    dfile = rawfs(1).name(~(1:length(rawfs(1).name) >= ind_(end) & 1:length(rawfs(1).name) < indDot(1)));
    dfile = regexprep(dfile,'_Raw','');
    
    prtclDataFileName = fullfile(cellD,cellID.name,dfile);

    dataFileExist = dir(prtclDataFileName);
    if length(dataFileExist)
        data = load(prtclDataFileName);
    end
    if ~length(dataFileExist) || length(data.data) ~= length(rawfs)
        createDataFileFromRaw(prtclDataFileName);
        data = load(prtclDataFileName);
    end
    data = data.data;
    field = fieldnames(data);
    
    blocknums = zeros(size(data));
    trialnums = blocknums;
    for d_ind = 1:length(data);
        blocknums(d_ind) = data(d_ind).trialBlock;
        trialnums(d_ind) = data(d_ind).trial;
    end
    blocks = unique(blocknums);
    
    % loop over the blocks, find an appropriate epochGroup
    for b_ind = 1:length(blocks)
        blocktrials = trialnums(blocknums==blocks(b_ind));
        
        blockProtocolParams = data(find(blocks(b_ind)==blocknums,1,'first'));
        label = blockProtocolParams.protocol;
        for t = 1:length(blockProtocolParams.tags)
            tag = blockProtocolParams.tags{t};
            label = [label '_' tag];
        end
        
        label = [label '_' num2str(blocktrials(1)) '_' num2str(blocktrials(end))];
        
        % Check if the block exists
        blockEpochGroup = [];
        for b = 1:length(blockEpochGroupsArray)
            if strcmp(label,char(blockEpochGroupsArray(b).getLabel))
                blockEpochGroup = blockEpochGroupsArray(b);
                break
            end
        end
        
        % Most of the time, create a new one
        if isempty(blockEpochGroup)
            
            % Create a skeleton param structure for this block
            for d_ind = 1:length(data);
                if data(d_ind).trialBlock == blocks(b_ind)
                    for name = 1:length(field)
                        if isnumeric(blockProtocolParams.(field{name})) || iscell(blockProtocolParams.(field{name}))
                            blockProtocolParams.(field{name}) = intersect(...
                                data(d_ind).(field{name}),blockProtocolParams.(field{name}));
                        end
                    end
                end
            end
            for name = 1:length(field)
                if isempty(blockProtocolParams.(field{name}))
                    blockProtocolParams = rmfield(blockProtocolParams,field{name});
                end
            end
            
            % Find the start and end times of the block
            rawfs_i = dir(sprintf(trialStem,blocktrials(1)));
            dv_i = num2cell(datevec(rawfs_i.datenum));
            
            % Create the block Epoch Group
            blockEpochGroup = experiment.insertEpochGroup(label,...
                datetime(dv_i{:}),...
                ovProtocol,...
                struct2map(blockProtocolParams),...
                []);
            
        end
        
        % Add an Epoch 
        for t_ind = 1:length(blocktrials)
            trial = dir(sprintf(trialStem,blocktrials(t_ind)));
            DT_f = trial.datenum;
            trial = load(trial.name);
            DT_i = DT_f - datenum([0 0 0 0 0 trial.params.durSweep]);
            DT_i = num2cell(datevec(DT_i));
            DT_f = num2cell(datevec(DT_f));
            

            epoch = blockEpochGroup.insertEpoch(...
                datetime(DT_i{:}),...
                datetime(DT_f{:}),...
                ovProtocol,...
                struct2map(trial.params),...
                struct2map(rig));
            
            epoch.addInputSource('cell',...
                cellSource);

    
            % Adding Numeric data
            % Device names are optional, and should correlate with keys in the
            % EquipmentSetup map
            
            field = fieldnames(trial);
            for name = 1:length(field)
                if isnumeric(trial.(field{name}))
                    import ovation.*

                    numericData = NumericData();
                    
                    deviceNames = array2set({rig.devices.amplifier.deviceName});
                    sourceNames = array2set({cellSource.getIdentifier});
                    numericData.addData(field{name}, trial.(field{name}),IdentifyUnits(field{name}), trial.params.sampratein, 'Hz');
                    epoch.insertNumericMeasurement(field{name},...
                        sourceNames,...
                        deviceNames,...
                        numericData);
                    
                end
                break
            end
            break
            
        end
        break
    end
    break
end

