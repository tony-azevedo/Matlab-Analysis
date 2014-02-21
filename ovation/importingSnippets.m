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
for p_ind = 1:length(protocols.m)
    protocol = protocols.m{p_ind};
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
