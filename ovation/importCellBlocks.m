function importCellBlocks(D,cellID,cellGroup,cellSource)                              
import ovation.*

cd(fullfile(D,cellID.name))
rawfs = dir([fullfile(D,cellID.name),'\*_Raw_*']);

blocks = asarray(cellGroup.getEpochGroups);
for f = 1:length(rawfs)
    t = load(rawfs(f).name);
    blocks(f) = t.params.trialBlock;
    
    label = t.params.protocol;
    for t = 1:length(t.tags)
        tag = t.tags{t};
        label = [label '_' tag];
    end
    
    block = [];
    for b = 1:length(blocks)
        if strcmp(label,char(blocks(b).getLabel))
            block = blocks(b);
            break
        end
        
    end
    if isempty(block)
        dv = datevec(rawfs(f).date);
        block = cellGroup.insertEpochGroup(label,...
            datetime(dv(1),dv(2),dv(3),dv(4),dv(5),dv(6)),...
            [],...
            [],...
            []);
        
    end
    
    epochProtocol = context.getProtocol(t.protocol);
    if(isempty(epochProtocol))
        epochProtocol = context.insertProtocol(t.protocol,'');
    end

    
    epoch = block.insertEpoch(...
        start,...
        fin,...
        epochProtocol,...
        struct2map(t.params),...
        struct2map(t.params));
    
    epoch.addInputSource('cell',...
        cellSource);
    
    %% Adding Numeric data
    % Device names are optional, and should correlate with keys in the
    % EquipmentSetup map
    
    fields = fieldnames(t);
    for name = 1:length(fields)
        if isnumeric(t.(fields{name})
            numericData = NumericData();

            deviceNames = array2set({'MultiClamp700B'});
            sourceNames = array2set({'cell'});
            numericData.addData(fields{name}, t.fields{name}, 'mV', t.params.sampratein, 'Hz');
            epoch.insertNumericMeasurement(name,...
                sourceNames,...
                deviceNames,...
                numericData);
            
        end
    end
    % TA: Where should I put the genotype of the fly (Source - child of fly?)?
    % TA: what should the device names be ("Piezo Actuator" or more specific "Physik Instrumente P840.20"?
    % TA: what are typical device params like?
    % TA: woah!  This didn't work!  cause a bunch of errors
    
    
end



% currentSineProtocol = context.getProtocol('CurrentSine');
% if(isempty(currentSineProtocol))
%     currentSineProtocol = context.insertProtocol('CurrentSine', 'Inject current sine wave',...
%         'CurrentSine',...
%         'https://github.com/tony-azevedo/FlySound/',...
%         'e5f0b4bc7fa1445f41e19d60f6a3f92dd04d455f');
% end
% end