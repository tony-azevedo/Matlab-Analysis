%% Importing new cell directory (cell -> experiment, fly -> source)
% need source
import ovation.*;

context = NewDataContext('Anthony_Azevedo@hms.harvard.edu');

% project = context.insertProject('AMMC-B1 neurons', 'Function, connectivity, mechanisms of sound encoding in B1 neurons', datetime(2013,4,3,8,0,0));
project = context.getObjectWithURI('ovation://a3c4c68c-6993-4223-8c3e-076add7badd6/');

% genotypeSource = context.insertSource('genotype', ';pJFRC7/pJFRC7;VT30609-Gal4/VT30609-Gal4');
genotypeSource = context.getObjectWithURI('ovation://4d204c8b-a272-43f0-9dc2-259625b10518/');

% genotypeSource = context.insertSource('genotype', 'GH86-Gal4/GH86-Gal4;pJFRC7/pJFRC7;;');
genotypeSource = context.getObjectWithURI('ovation://8ae6267b-28e3-4e0e-afe6-6b2b528d4b4d/');

% need to get the genotype from the acq struct, even if I fuck it up, find
% a close enough match

% Create two protocols. 
% Protocols are optional, and can be attached at any point on the TimelineElement hierarchy (Experiments, EpochGroups, Epochs). 
% We will create a protocol for the Source generation epoch, and the piezoSine EpochGroup.
% Need to make these for all Protocols

protocols = what('FlySoundProtocols');
for p = 1:length(protocols.m)
    protocol = protocols.m{p};
    piezoSineProtocol = context.getProtocol('PiezoSine.131205');
    if(isempty(piezoSineProtocol))
        piezoSineProtocol = context.insertProtocol('PiezoSine.131205', 'Move antenna with Sine wave');
    end
    
end

female3doFlyGenerationProtocol = context.getProtocol('Female, 3do');
if(isempty(flyGenerationProtocol))
    flyGenerationProtocol = context.insertProtocol(...
        'Female, 3do', ...
        'Female, 3do');
end


cellGenerationProtocol = context.getProtocol('Cock-eyed Prep');
if(isempty(cellGenerationProtocol))
    cellGenerationProtocol = context.insertProtocol(...
        'Cock-eyed Prep', ...
        '1) Mount fly in holder, pull off legs, pull scutellum back; 2) Glue scutellum; 3) Front - rotate head 90 deg, glue in place; 4) Back - glue around head, keep arista free; 5) Front - glue face to prevent leakage; 6) Score around and remove eye, remove fat/tissue; 7) Desheath directly above (lateral to) antennal nerve');
end



%%
D = 'C:\Users\Anthony Azevedo\Raw_Data';
celldir = '131126';
celldirs = dir([fullfile(D,celldir) '\' celldir '*']);

for celld = 1:length(celldirs) % loop over cells
    
    acquisitionfile = dir(fullfile(D,celldir,celldirs(celld).name,'Acquisition_*'));
    dv = datevec(acquisitionfile(1).date);
    acqStruct = load(fullfile(D,celldir,celldirs(celld).name,acquisitionfile(1).name),'acqStruct');
    acqStruct = acqStruct.acqStruct;
    
    experimentPurpose = celldirs(celld).name;
    
    % experiments are cells.  These cells might be tagged to allow them to
    % contribute to results, i.e. experiments can contribute to multiple
    % results/analyses.
    experiment = project.insertExperiment(experimentPurpose, datetime(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)));
    
    flySource = context.getObjectWithURI('ovation://9dc60a32-65bc-4ff5-8df5-70acc8e73761/');
        % cellSource.getLabel % cell
        % cellSource.getIdentifier % 131126_F0_C0
        % a = cellSource.getParentSources.iterator,
        % a.hasNext; % 1
        % b = a.first; % source
        % b.getLabel; % Cell Genotype
        % c = b.getParentSources.iterator % empty
        % c.hasNext %

    inputSources = struct('genotype', genotypeSource);
    flySource = genotypeSource.insertSource(struct2map(inputSources),...
			sourceGenerationEpoch,...
			'F1',...% name of the resulting source within the scope of the epoch
			'C1',...% label of the resulting source
			'F1_C1');% id

        
    sourceGenerationEpoch = sourceGenerationEpochGroup.insertEpoch(...
							struct2map(inputSources),...
							[],...
							datetime(2013,7,1,8),... 
							datetime(2013,7,1,8),... 
							sourceGenerationProtocol,... 
							sourceGenerationProtocolParams,... 
							sourceGenerationDeviceParams);

        
    cellGroup = experiment.insertEpochGroup(celldirs(celld).name,...
        datetime(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)),...
        [],...
        [],...
        []);
    
    importCellBlocks(fullfile(D,celldir),celldirs(celld),cellGroup,cellSource)
    %end
    
    bigSpiker = context.getObjectWithURI('ovation://2fd19a3f-91a1-4cd1-8e59-6aac67fdf9da/');
    
    % need experiment
    experiment = context.getObjectWithURI('ovation://e930155d-db71-4487-a862-48555be36ec6/');
    
    % need protocol
    currentSineProtocol = context.getProtocol('CurrentSine');
    if(isempty(currentSineProtocol))
        currentSineProtocol = context.insertProtocol('CurrentSine', 'Inject current sine wave',...
            'CurrentSine',...
            'https://github.com/tony-azevedo/FlySound/',...
            'e5f0b4bc7fa1445f41e19d60f6a3f92dd04d455f');
    end
    
    % find all the blocks
    % for all blocks
    b = dir(regexprep(Trial.name,'Acquisition','Raw_Data'));
    epochGroup = experiment.insertEpochGroup(currentSineProtocol.getName,...
        datevec(b.date),...
        currentSineProtocol,...
        piezoSineProtocolParams,...
        piezoSineDeviceParams);
    
    
end
%% Create an epoch group to contain the PiezoSine epochs
% I made the choice to attach the PiezoSine protocol here (instead of at 
% the Experiment). For data generated by a different protocol during this 
% Experiment (PiezoStep, Sweep, etc), I imagine you'd create a new sibling
% epochGroup, with a new protocol.

piezoSineProtocolParams = struct2map(params);
piezoSineDeviceParams = struct2map(equipmentSetupStruct);

epochGroup = experiment.insertEpochGroup('PiezoSine',...
                                        datetime(2013,7,1,8),...
                                        currentSineProtocol,... 
                                        piezoSineProtocolParams,...
                                        piezoSineDeviceParams);

% Then, when you insert epochs, you don't need to specify a protocol

epochProtocolParams.amplitude = 1;
piezoSineEpoch = epochGroup.insertEpoch(...					
					start,... 
                    fin,... 
					currentSineProtocol,...
                    struct2map(epochProtocolParams),...
                    piezoSineDeviceParams);

%% Adding Numeric data
% Device names are optional, and should correlate with keys in the
% EquipmentSetup map

deviceNames = array2set(['PiezoActuator']);
sourceNames = array2set(['F1']);
numericData = NumericData();
numericData.addData('sgsmonitor', sgsmonitor', 'V', params.sampratein, 'Hz');
piezoSineEpoch.insertNumericMeasurement(name,...
                                        sourceNames,...
                                        deviceNames,...
                                        numericData);
                                    
numericData = NumericData();
numericData.addData('voltage', voltage', 'mV',  params.sampratein, 'Hz');
piezoSineEpoch.insertNumericMeasurement(name,...
                                        sourceNames,...
                                        deviceNames,...
                                        numericData);
 
% TA: Where should I put the genotype of the fly (Source - child of fly?)?
% TA: what should the device names be ("Piezo Actuator" or more specific "Physik Instrumente P840.20"?
% TA: what are typical device params like?
% TA: woah!  This didn't work!  cause a bunch of errors
