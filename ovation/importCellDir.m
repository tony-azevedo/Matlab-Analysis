%% Importing new cell directory (cell -> experiment, fly -> source)
% need source
import ovation.*;

context = NewDataContext('anthony_azevedo@hms.harvard.edu');

% project = context.insertProject('AMMC-B1 neurons', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
project = context.getObjectWithURI('ovation://a3c4c68c-6993-4223-8c3e-076add7badd6/');
% project.getName, project.getPurpose

a = context.getUsers.iterator;
while a.hasNext;
    me = a.next;
    if strcmp(me.getUsername,'Anthony Azevedo')
        break
    end
end

%%
% genotypeSource = context.insertSource('genotype', ';pJFRC7/pJFRC7;VT30609-Gal4/VT30609-Gal4');
genotypeSource = context.getObjectWithURI('ovation://4d204c8b-a272-43f0-9dc2-259625b10518/');
% genotypeSource.getLabel, genotypeSource.getIdentifier

% genotypeSource = context.insertSource('genotype', 'GH86-Gal4/GH86-Gal4;pJFRC7/pJFRC7;;');
genotypeSource = context.getObjectWithURI('ovation://8ae6267b-28e3-4e0e-afe6-6b2b528d4b4d/');
% genotypeSource.getLabel, genotypeSource.getIdentifier

% need to get the genotype from the acq struct, even if I fuck it up, find
% a close enough match

%%
% Create protocols.
% Protocols are optional, and can be attached at any point on the TimelineElement hierarchy (Experiments, EpochGroups, Epochs).
% We will create a protocol for the Source generation epoch, and the piezoSine EpochGroup.
% Need to make these for all Protocols

protocols = what('FlySoundProtocols');
for p = 1:length(protocols.m)
    protocol = protocols.m{p};
    helpstr = help(protocol);
    ovProtocol = context.getProtocol(protocol);
    if(isempty(ovProtocol))
        ovProtocol = context.insertProtocol(protocol, helpstr);
    end
    ovProtocol.getName
    ovProtocol.getProtocolDocument
    
end

%%
female3doFlyGenerationProtocol = context.getProtocol('Female, 3do');
if(isempty(female3doFlyGenerationProtocol))
    female3doFlyGenerationProtocol = context.insertProtocol(...
        'Female, 3do', ...
        'Female, 3do');
end

cellGenerationProtocol = context.getProtocol('Cock-eyed Prep');
if(isempty(cellGenerationProtocol))
    cellGenerationProtocol = context.insertProtocol(...
        'Cock-eyed Prep', ...
        '1) Mount fly in holder, pull off front legs, pull scutellum back; 2) Glue scutellum; 3) Front - rotate head 90 deg, glue in place; 4) Back - glue around head, keep arista free; 5) Front - glue face to prevent leakage; 6) Back - Add External; 7) Back - Score around and remove eye, remove fat/tissue; 8) Desheath directly above (lateral to) antennal nerve');
    cellGenerationProtocol.getName
    cellGenerationProtocol.getProtocolDocument
    
end

cellGenerationProtocol = context.getProtocol('Naked Brain Prep');
if(isempty(cellGenerationProtocol))
    cellGenerationProtocol = context.insertProtocol(...
        'Naked Brain Prep', ...
        '??');
    cellGenerationProtocol.getName
    cellGenerationProtocol.getProtocolDocument
end


%%
D = 'C:\Users\Anthony Azevedo\Raw_Data';
celldir = '131126';
celldirs = dir([fullfile(D,celldir) '\' celldir '*']);

%%
for celld = 1:length(celldirs) % loop over cells
    %% celld = 1
    
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
    experiments = project.getExperiments.iterator;
    experiment = [];
    while experiments.hasNext && isempty(experiment)
        if strcmp(experiments.peek.getPurpose,experimentPurpose);
            experiment = experiments.next;
        else
            experiments.next;
        end
    end
    % experiment.getPurpose
    if isempty(experiment)
        experiment = project.insertExperiment(experimentPurpose,DT_start);
    end
    
    disp(experiment.getPurpose)
    
    %% Top Level source
    genotype = IdentifyGenotype(acqStruct.flygenotype);
    
    genotypeSource = context.getSourcesWithIdentifier(genotype);
    if genotypeSource.size > 1
        error('Found more than 1 source with genotype %s',genotype);
    elseif genotypeSource.size == 1
        genotypeSource = genotypeSource.iterator.next;
    elseif genotypeSource.size == 0
        genotypeSource = context.insertSource('genotype', genotype);
    end
    disp(genotypeSource.getIdentifier)
    
    %% Fly Source
    flySource = context.getSourcesWithIdentifier([dstr,'_F', acqStruct.flynumber]);
    if flySource.size > 1
        error('Found more than 1 fly source with id %s',[dstr,'_F', acqStruct.flynumber]);
    elseif flySource.size == 1
        fprintf('Found: ')
        flySource = flySource.iterator.next;
        disp(flySource.getIdentifier)
    elseif flySource.size == 0
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
    end
    
    %% Cell source, to be inserted into experiment
    
    cellSource = context.getSourcesWithIdentifier([dstr,'_F', acqStruct.flynumber,'_C', acqStruct.cellnumber]);
    if cellSource.size > 1
        error('Found more than 1 cell source with id %s',[dstr,'_F', acqStruct.flynumber,'_C', acqStruct.cellnumber]);
    elseif cellSource.size == 1
        fprintf('Found: ')
        cellSource = cellSource.iterator.next;
        disp(cellSource.getIdentifier)
    elseif cellSource.size == 0
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
        
    end
    
    %% importCellBlocks(fullfile(D,celldir),celldirs(celld),experiment,cellSource)
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
    
    blockEpochGroupsArray = asarray(experiment.getEpochGroups);
    
    rigs = dir('*Rig*');
    for r = 1:length(rigs)
        if ~isempty(strfind(rigs(r).name,'Camera'))
            rigs = dir('*Camera*Rig*');
        end
    end
    
    for p = 1:length(protocols)
        % p = 1

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
            % b_ind = 1
             
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
            epochs = blockEpochGroup.getEpochs;

            % Add an Epoch
            for t_ind = 1:length(blocktrials)
                % t_ind = 1
                trial = dir(sprintf(trialStem,blocktrials(t_ind)));
                DT_f = trial.datenum;
                trial = load(trial.name);
                DT_i = DT_f - datenum([0 0 0 0 0 trial.params.durSweep]);
                DT_i = num2cell(datevec(DT_i));
                DT_f = num2cell(datevec(DT_f));
                
                epoch = [];
                if ~isempty(blockEpochGroup.getEpochs)
                    epochs = blockEpochGroup.getEpochs.iterator;
                    while epochs.hasNext
                        epochNum = epochs.peek.getProperty('epochNumber').get(me);
                        if ~isempty(epochNum)
                            epoch = epochs.next;
                            break
                        else
                            epochs.next;
                        end
                    end
                end
                
                if isempty(epoch) || ~strcmp(class(epoch),'us.physion.ovation.domain.concrete.Epoch')
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
                end
                
                % Adding Numeric data
                % Device names are optional, and should correlate with keys in the
                % EquipmentSetup map
                
                field = fieldnames(trial);
                for name = 1:length(field)
                    if isnumeric(trial.(field{name}))                        
                        numericData = NumericData();
                        
                        deviceNames = array2set({rig.devices.amplifier.deviceName});
                        sourceNames = array2set({cellSource.getIdentifier});
                        numericData.addData(field{name}, trial.(field{name}),IdentifyUnits(field{name}), trial.params.sampratein, 'Hz');
                        epoch.insertNumericMeasurement(field{name},...
                            sourceNames,...
                            deviceNames,...
                            numericData);
                        
                    end
                    
                end
                break
                
            end
            break
        end
        break
    end
    
    %end
    
end
    
    
    
    %% Clean up options
    
    if 1
        toDelete = context.getObjectWithURI('ovation://e0a2ba73-f8c1-45ee-b69e-c6d223c8ba3b/');
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