%% Importing new cell directory (cell -> experiment, fly -> source)
% need source
clear
import ovation.*;

context = NewDataContext('anthony_azevedo@hms.harvard.edu');

% project = context.insertProject('AMMC-B1 neurons - 1', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
% project = context.getObjectWithURI('ovation://a3c4c68c-6993-4223-8c3e-076add7badd6/');

% project = context.insertProject('AMMC-B1 neurons - 2', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
% project = context.getObjectWithURI('ovation://c1685bd0-c658-4139-9e20-64c5a30ec068/'); 

% project = context.insertProject('AMMC-B1 neurons - 3', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
% project = context.getObjectWithURI('ovation://8aecae30-b4e8-4817-b54d-c5e36ad453bd/'); 

% project = context.insertProject('AMMC-B1 neurons - 4', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
% project = context.getObjectWithURI('ovation://c47f860c-04a4-4021-a8b7-4f3caf1c6e67/'); 

% project = context.insertProject('AMMC-B1 neurons - 5', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
% project = context.getObjectWithURI('ovation://d4610f7d-67a8-40d4-88c0-a06f25a724aa/'); 

project = context.insertProject('AMMC-B1 neurons - 7', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
%project = context.getObjectWithURI('ovation://2f421b30-31c3-4b51-b112-5b9dc4116619/'); 

% project.getName, project.getPurpose

a = context.getUsers.iterator;
while a.hasNext;
    me = a.next;
    if strcmp(me.getUsername,'Anthony Azevedo')
        break
    end
end

%%
D = 'C:\Users\Anthony Azevedo\Raw_Data';
celldir = '131126';
celldirs = dir([fullfile(D,celldir) '\' celldir '*']);

% loop over cell directories
for celld = 1:length(celldirs) 
    % celld = 1
    
    acquisitionfile = dir(fullfile(D,celldir,celldirs(celld).name,'Acquisition_*'));
    dv = datevec(acquisitionfile(1).date);
    dc = num2cell(dv);
    dstr = datestr(dv,'yymmdd');
    DT = datetime(dc{:});
    acqStruct = load(fullfile(D,celldir,celldirs(celld).name,acquisitionfile(1).name),'acqStruct');
    acqStruct = acqStruct.acqStruct;
    
    % Start Time
    rawfiles = dir(fullfile(D,celldir,celldirs(celld).name,'*_Raw_*'));
    DT_start = Inf;
    for rf = 1:length(rawfiles);
        DT_start = min(DT_start,rawfiles(rf).datenum);
    end
    DT_start = num2cell(datevec(DT_start));
    DT_start = datetime(DT_start{:});
    
    % Finish Time
    DT_end = -Inf;
    for rf = 1:length(rawfiles);
        DT_end = max(DT_end,rawfiles(rf).datenum);
    end
    DT_end = DT_end+datenum([0 0 0 0 5 0]);
    DT_end = num2cell(datevec(DT_end));
    DT_end = datetime(DT_end{:});
    
    experimentPurpose = celldirs(celld).name;
    
    % experiments are cells.  These cells might be tagged to allow them to
    % contribute to results, i.e. experiments can contribute to multiple
    % results/analyses.
    experiments = asarray(project.getExperiments);
    experiment = [];
    for ex_ind = 1:length(experiments)
        if strcmp(experiments(ex_ind).getPurpose,experimentPurpose);
            experiment = experiments(ex_ind);
            fprintf('Found: ')
            disp(experiment.getPurpose)
        end
    end
    if isempty(experiment)
        experiment = project.insertExperiment(experimentPurpose,DT_start);
        fprintf('Inserting: ')
        disp(experiment.getPurpose)
    end
    
    
    % Top Level source
    genotype = IdentifyGenotype(acqStruct.flygenotype);
    
    genotypeSource = context.getSourcesWithIdentifier(genotype);
    if genotypeSource.size > 1
        error('Found more than 1 source with genotype %s',genotype);
    elseif genotypeSource.size == 1
        fprintf('Found: ')
        genotypeSource = genotypeSource.iterator.next;
    elseif genotypeSource.size == 0
        genotypeSource = context.insertSource('genotype', genotype);
    end
    disp(genotypeSource.getIdentifier)
    
    % Fly Source
    
    flySources = asarray(context.getSourcesWithIdentifier([dstr,'_F', acqStruct.flynumber]));
    if length(flySources)==1
        flySource = flySources(1);
        generationEpochsArray = asarray(flySource.getEpochs);
        disp(flySource.getProducingProcedure.getProtocol.getProtocolDocument)

        parentSourceStruct = struct('genotype', genotypeSource);
        flyGenerationEpochGroup = experiment.insertEpochGroup('Fly generation', DT_start, [], [], []);
        flyGenerationEpoch = flyGenerationEpochGroup.insertEpoch(...
            struct2map(parentSourceStruct),...
            [],...
            DT_start,...
            DT_end,...
            flySource.getProducingProcedure.getProtocol,...
            [],...
            []);
    
    elseif length(flySources)== 0
        
        if isfield(acqStruct,'flygeneration');
            flyGenerationProtocol = context.getProtocol(acqStruct.flygeneration);
        else
            flyGenerationProtocol = context.getProtocol('Female, 3do');
        end
        disp(flyGenerationProtocol.getProtocolDocument)
            
        parentSourceStruct = struct('genotype', genotypeSource);
        flyGenerationEpochGroup = experiment.insertEpochGroup('Fly generation', DT_start, [], [], []);
        % flyGenerationEpochGroup = context.getObjectWithURI('ovation://2d9c610c-4343-4c30-ae0c-dfc88a9643fc/')
        flyGenerationEpoch = flyGenerationEpochGroup.insertEpoch(...
            struct2map(parentSourceStruct),...
            [],...
            DT_start,...
            DT_end,...
            flyGenerationProtocol,...
            [],...
            []);
        
        flySource = genotypeSource.insertSource(struct2map(parentSourceStruct),...
            flyGenerationEpoch,...
            'fly',...% name of the resulting source within the scope of the epoch
            'fly',...% label of the resulting source
            [dstr,'_F', acqStruct.flynumber]);% id
        disp(flySource.getIdentifier)
    else
        error('Found more than 1 fly source %s',[dstr,'_F', acqStruct.flynumber]);
    end
        
    
    % Cell source, to be inserted into experiment

    cellSources = asarray(context.getSourcesWithIdentifier([dstr,'_F', acqStruct.flynumber,'_C', acqStruct.cellnumber]));
    if length(cellSources)==1
        cellSource = cellSources(1);
        disp(cellSource.getProducingProcedure.getProtocol.getName)
        disp(cellSource.getProducingProcedure.getProtocol.getProtocolDocument)
        
        parentSourceStruct = struct('fly', flySource);
        cellGenerationEpochGroup = experiment.insertEpochGroup('Cell generation', DT_start, [], [], []);
        cellGenerationEpoch = cellGenerationEpochGroup.insertEpoch(...
            struct2map(parentSourceStruct),...
            [],...
            DT_start,...
            DT_end,...
            cellSource.getProducingProcedure.getProtocol,...
            [],...
            []);
        
    elseif length(cellSources)==0
        if isfield(acqStruct,'cellgeneration');
            cellGenerationProtocol = context.getProtocol(acqStruct.cellgeneration);
        else
            cellGenerationProtocol = context.getProtocol('Cock-eyed Prep');
        end
        disp(cellGenerationProtocol.getName)
        disp(cellGenerationProtocol.getProtocolDocument)
            
        parentSourceStruct = struct('fly', flySource);
        cellGenerationEpochGroup = experiment.insertEpochGroup('Cell generation', DT_start, [], [], []);
        cellGenerationEpoch = cellGenerationEpochGroup.insertEpoch(...
            struct2map(parentSourceStruct),...
            [],...
            DT_start,...
            DT_end,...
            cellGenerationProtocol,...
            [],...
            []);
        
        cellSource = flySource.insertSource(struct2map(parentSourceStruct),...
            cellGenerationEpoch,...
            'cell',...% name of the resulting source within the scope of the epoch
            'cell',...% label of the resulting source
            [dstr,'_F', acqStruct.flynumber,'_C', acqStruct.cellnumber]);% id
        
        % cellSource.getLabel % cell
        % cellSource.getIdentifier % 131126_F0_C0
        % a = cellSource.getParentSources.iterator,
        % a.hasNext; % 1
        % b = a.first; % source
        % b.getLabel; % fly
        % c = b.getParentSources.iterator % empty
        % c.hasNext %
        disp(cellSource.getIdentifier)
    else
        error('Found more than 1 cell source %s',[dstr,'_F', acqStruct.flynumber,'_C', acqStruct.cellnumber]);
    end
    
    
    % importCellBlocks(fullfile(D,celldir),celldirs(celld),experiment,cellSource)
    % function importCellBlocks(cellD,cellID,experiment,cellSource)
    % import ovation.*
    % context = cellSource.getDataContext;
    cellD = fullfile(D,celldir);
    cellID = celldirs(celld);
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
        
    rigs = dir('*Rig*');
    for r = 1:length(rigs)
        if ~isempty(strfind(rigs(r).name,'Camera'))
            rigs = dir('*Camera*Rig*');
        end
    end
    
    
    % Loop over the protocols (blocks all have the same protocol)
    for p_ind = 1:length(protocols)
        % p_ind = 1

        % get the protocol, data structure array, trialStem, blocks
        protocol = protocols{p_ind};
        disp(['Protocol: ' protocol])

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
            % b_ind = 1
            disp(['Block: ' num2str(blocks(b_ind))])
 
            blocktrials = trialnums(blocknums==blocks(b_ind));
            
            blockProtocolParams = data(find(blocks(b_ind)==blocknums,1,'first'));
            label = blockProtocolParams.protocol;
            for t = 1:length(blockProtocolParams.tags)
                tag = blockProtocolParams.tags{t};
                label = [label '_' tag];
            end
            
            label = [label '_' num2str(blocktrials(1)) '_' num2str(blocktrials(end))];
            
            % Check if the block exists
            blockEpochGroupsArray = asarray(experiment.getEpochGroups);
            blockEpochGroup = [];
            for b = 1:length(blockEpochGroupsArray)
                if strcmp(label,char(blockEpochGroupsArray(b).getLabel))
                    blockEpochGroup = blockEpochGroupsArray(b);
                    fprintf('Found: ')
                    disp(blockEpochGroup.getLabel)
                    break
                end
            end
            
            % Most of the time, create a new one
            if isempty(blockEpochGroup)
                
                disp(['Creating Epoch Group: ' label])
                
                % Create a skeleton param structure for this block
                field = fieldnames(blockProtocolParams);
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
                
                % Find the start times of the block
                rawfs_i = dir(sprintf(trialStem,blocktrials(1)));
                dv_i = num2cell(datevec(rawfs_i.datenum));
                
                % Create the block Epoch Group
                blockEpochGroup = experiment.insertEpochGroup(label,...
                    datetime(dv_i{:}),...
                    ovProtocol,...
                    struct2map(blockProtocolParams),...
                    []);
                
                % Add the Epochs
                for t_ind = 1:length(blocktrials)
                    % t_ind = 1
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
                    
                    epoch.addProperty('epochNumber',...
                        trial.params.trial);
                    
                    disp(['Added Epoch: ' num2str(epoch.getProperty('epochNumber').get(me))])

                    
                    % Adding Numeric data
                    % Device names are optional, and should correlate with keys in the
                    % EquipmentSetup map
                    
                    deviceNames = array2set({rig.devices.amplifier.deviceName});
                    sourceNames = array2set({'cell'});
                    
                    field = fieldnames(trial);
                    for name = 1:length(field)
                        if isnumeric(trial.(field{name}))
                            numericData = NumericData();
                            
                            numericData.addData(field{name}, trial.(field{name}),IdentifyUnits(field{name}), trial.params.sampratein, 'Hz');
                            epoch.insertNumericMeasurement(field{name},...
                                sourceNames,...
                                deviceNames,...
                                numericData);
                            disp(['Added Numeric Data: ' field{name}])

                        end
                        
                    end
                end
                
            else % if blockEpochGroup is not new
                epochs = asarray(blockEpochGroup.getEpochs);
                
                % check whether there are multiple copies of the same epoch (by
                % number).  Trash extraneous copies
                if ~isempty(epochs)
                    
                    breakflag = 0;
                    
                    % trash epochs if they don't have an epochNumber
                    for e_ind = 1:length(epochs)
                        epochNumber = epochs(e_ind).getProperty('epochNumber').get(me);
                        if isempty(epochNumber)
                            context.trash(epochs(e_ind)).get()
                            breakflag = 1;
                        end
                    end
                    if breakflag
                        error('Restart context, epochs have been deleted because the epochNumber was empty')
                    end
                    
                    % trash epochs if they have repeat epochNumbers
                    epochNumbers = nan(size(epochs));
                    for e_ind = 1:length(epochs)
                        epochNumbers(e_ind) = epochs(e_ind).getProperty('epochNumber').get(me);
                    end
                    
                    epochNumbers = unique(epochNumbers);
                    blocktrials = setdiff(blocktrials,epochNumbers);
                    for e_ind = 1:length(epochs)
                        epochNumber = epochs(e_ind).getProperty('epochNumber').get(me);
                        if isempty(intersect(epochNumber,epochNumbers))
                            context.trash(epochs(e_ind)).get()
                            breakflag = 1;
                        else
                            epochNumbers = epochNumbers(epochNumbers~=epochNumber);
                        end
                    end
                    if breakflag
                        error('Restart context, epochs have been deleted because there were multiple copies')
                    end
                end
                
                % Add Epochs for any blocktrials that weren't found
                for t_ind = 1:length(blocktrials)
                    % t_ind = 1
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
                    
                    epoch.addProperty('epochNumber',...
                        trial.params.trial);
                    
                    % Adding Numeric data
                    % Device names are optional, and should correlate with keys in the
                    % EquipmentSetup map
                    
                    deviceNames = array2set({rig.devices.amplifier.deviceName});
                    sourceNames = array2set({'cell'});
                    
                    field = fieldnames(trial);
                    for name = 1:length(field)
                        if isnumeric(trial.(field{name}))
                            numericData = NumericData();
                            
                            numericData.addData(field{name}, trial.(field{name}),IdentifyUnits(field{name}), trial.params.sampratein, 'Hz');
                            epoch.insertNumericMeasurement(field{name},...
                                sourceNames,...
                                deviceNames,...
                                numericData);
                            
                        end
                        
                    end
                    
                    
                end
                
            end
            
            
        end
    end
end


fprintf(' **************************    WAHOOO **************\n')


%% Clean up options

if 1
    toDelete = context.getObjectWithURI('ovation://8aecae30-b4e8-4817-b54d-c5e36ad453bd/');
    % context.trash(toDelete);
    context.trash(toDelete).get();
end


%% Sync test

dsc = context.getCoordinator

tic
future = dsc.sync();

if (future.isDone())
    toc
    future.get()
end

%% Mess with objects
object = context.getObjectWithURI('ovation://88544530-06a6-490c-8224-a3093db93bbd/')

