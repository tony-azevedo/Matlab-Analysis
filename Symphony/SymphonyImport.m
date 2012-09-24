function epochGroups = SymphonyImport(ctx,...
        symphonyHDF5Path,...
        metadataXMLPath,...
        epochGroupRoot...
        )
    % Imports a Symphony data file into Ovation.
    %
    %   epochGroups = SymphonyImport(context, h5Path, xmlPath,
    %                                  epochGroupRoot);
    %
    %            context: Ovation DataContext instance
    %             h5Path: Full path to Symphony HDF5 file
    %            xmlPath: Full path to Symphony metadata XML file
    %     epochGroupRoot: Ovation object root for this experiment's data
    %                     (i.e. an Experiment or EpochGroup instance)
    %
    %  Returns an array of imported EpochGroups.
    
    import ovation.*;
    
    %% Java HDF5 library
    import ch.systemsx.cisd.hdf5.*
    
    %% Open HDF5 file for reading
    reader = HDF5Factory.openForReading(symphonyHDF5Path);
    
    %% Load Metadata
    metadata = parseSymphonyXMLMetadata(metadataXMLPath);
    
    %% Add Sources
    disp('  Updating Sources...');
    sources = metadata.source;
    fields = fieldnames(sources);
    for i = 1:length(fields)
        disp(['    ' num2str(i) ' of ' num2str(length(fields)) '...' ]);
        updateSource(ctx, sources.(fields{i}), []);
    end
    
    %% Load EpochGroups
    rootMembers = reader.getGroupMemberInformation('/',true);
    firstGroup = true;
    for i = 0:(rootMembers.size()-1)
        m = rootMembers.get(i);
        if(m.isGroup())
            g = readEpochGroup(ctx,...
                epochGroupRoot,...
                reader,...
                m.getPath,...
                metadata);
            
            if(firstGroup)
                epochGroups(1) = g;
                firstGroup = false;
            else
                epochGroups(end+1) = g; %#ok<AGROW>
            end
            
        end
    end
    
    %% Add notes to the Experiment
    for i = 1:length(metadata.notes)
        note = metadata.notes(i);
        
        if(isfield(note, 'time') && isfield(note, 'text'))
            
            % Find the Experiment from epochGroupRoot
            if(isa(epochGroupRoot, 'ovation.EpochGroup'))
                target = epochGroupRoot.getExperiment();
            else
                target = epochGroupRoot;
            end
            
            % Add a timeline annotation with the note text
            target.addTimelineAnnotation(note.text, 'symphony_note', note.time);
            
        end
    end
    
end


function updateSource(ctx, src, parent)
    
    ovSrc = findSource(ctx, src.uuid);
    if(isempty(ovSrc))
        if(isempty(parent))
            parent = ctx;
        end
        
        disp(['        Creating a new Source with UUID ' char(src.uuid) '...']);
        ovSrc = parent.insertSource(src.label);
        ovSrc.addProperty('__symphony__uuid__', src.uuid);
    else
        assert((isempty(parent) && isempty(ovSrc.getParent())) || parent.equals(ovSrc.getParent()));
    end
    
    if(isfield(src, 'children'))
        cNames = fieldnames(src.children);
        for i = 1:length(cNames)
            updateSource(ctx, src.children.(cNames{i}), ovSrc);
        end
    end
end

function src = findSource(ctx, symphony_uuid)
    
    %TODO: this can be changed to the query below once issue #734 is
    %resolved:
    % ['any(elementsOfType(properties("__symphony__uuid__"), class:ovation.StringValue), value=="' char(symphony_uuid) '")']
    
    src = [];
    
    disp(['      Searching for Source with UUID ' char(symphony_uuid) '...']);
    sources = ctx.getSources();
    for i = 1:length(sources)
        s = sources(i);
        %     iter = ctx.query('Source', 'true');
        %     while(iter.hasNext())
        %         s = iter.next();
        uuid = s.getOwnerProperty('__symphony__uuid__');
        if(strcmp(uuid,symphony_uuid))
            src = s;
            disp(['        Found Source with UUID ' char(symphony_uuid) '...']);
            return;
        end
    end
end

function epochGroup = readEpochGroup(context,...
        parent,...
        reader,...
        epochGroupPath,... % HDF5 EpochGroup path
        metadata... % Expt metadata
        )
    
    import ovation.*;
    
    [startTime, endTime] = groupTimes(reader, epochGroupPath);
    
    label = reader.getStringAttribute(epochGroupPath, 'label');
    srcId = reader.getStringAttribute(epochGroupPath, 'source');
    
    if(srcId.isEmpty() || srcId.equals('<none>'))
%         if(parent.getClass().getCanonicalName().equals(Experiment.class))
%             error('Source is required for root EpochGroups');
%         else
%             assert(~isempty(parent.getSource()));
%         end
        
        source = []; % parent.getSource();
    else
        source = findSource(context,...
            srcId...
            );
    end
    
    disp(['  Inserting EpochGroup ("' char(label) '")...']);
    
    if(isempty(source))
        epochGroup = parent.insertEpochGroup(label,...
            startTime,...
            endTime...
            );
    else
        epochGroup = parent.insertEpochGroup(source,...
            label,...
            startTime,...
            endTime...
            );
    end
    
    %% Add properties
    
    if(hasProperties(reader, epochGroupPath))
        if(isGroup(reader, epochGroupPath, 'properties'))
            properties = readDictionary(reader, epochGroupPath, 'properties');
            fnames = fieldnames(properties);
            for i = 1:length(fnames)
                key = fnames{i};
                value = properties.(key);
                epochGroup.addProperty(key, value);
            end
        else
            props = reader.readCompoundArray(...
                [char(epochGroupPath) '/properties'],...
                getClass(ch.systemsx.cisd.hdf5.HDF5CompoundDataMap));
            
            for i = 1:length(props)
                epochGroup.addProperty(props(i).get('key'), props(i).get('value'));
            end
        end
    end
    
    % Symphony UUID
    epochGroup.addProperty('__symphony__uuid__', reader.getStringAttribute(epochGroupPath, 'symphony.uuid'));
    
    
    %% Add keywords
    if(hasKeywords(reader, epochGroupPath))
        addKeywords(reader, epochGroupPath, epochGroup);
    end
    
    
    
    %% Add Epochs
    epochInfos = reader.getGroupMemberInformation(...
        [char(epochGroupPath) '/epochs'],...
        true...
        );
    
    prevEpoch = [];
    for i = 0:(epochInfos.size() - 1)
        epochPath = epochInfos.get(i).getPath();
        
        disp(['    Epoch ' num2str(i+1) '...']);
        
        epoch = readEpoch(epochGroup,...
            reader,...
            epochPath...
            );
        
        if(~isempty(prevEpoch))
            epoch.setPreviousEpoch(prevEpoch);
        end
        
        prevEpoch = epoch;
    end
    
    %% Iterate sub-EpochGroups, recursing
    subGroups = reader.getGroupMemberInformation(...
        [char(epochGroupPath) '/epochGroups'],...
        true);
    for i = 0:(subGroups.size() - 1)
        grpPath = subGroups.get(i).getPath();
        readEpochGroup(context,...
            epochGroup,...
            reader,...
            grpPath,...
            metadata...
            );
    end
    
end

function g = isGroup(reader, group, name)
    import ch.systemsx.cisd.hdf5.*
    info =  reader.getObjectInformation([char(group) '/' name]);
    g = info.getType() == HDF5ObjectType.GROUP;
end

function d = readDictionary(reader, group, name)
    % Read the attributes on a group into a Matlab struct. Because
    % attributes ares strongly typed, we have to provide explicit support
    % for each type. Currently supports string, and int32/64 and float32/64
    % scalars and arrays.
    
    import ch.systemsx.cisd.hdf5.*;
    import ovation.*;
    
    if(~isGroup(reader, group, name))
        error('ovation:symphony_importer:file_structure',...
            [name ' is not a group in ' group]);
    end
    
    d = struct();
    
    dictGroup = fullfile(char(group), char(name));
    attributeNames = reader.getAllAttributeNames(dictGroup).toArray();
    for i = 1:length(attributeNames)
        attrName = char(attributeNames(i));
        attrInfo = reader.getAttributeInformation(dictGroup, attrName);
        
        % STRING
        if(attrInfo.getDataClass() == HDF5DataClass.STRING)
            
            d.(attrName) = char(reader.getStringAttribute(dictGroup, attrName));
            
            % INTEGER (int64, int32)
        elseif(attrInfo.getDataClass() == HDF5DataClass.INTEGER)
            
            % Long, Int
            if(attrInfo.getElementSize() == 4)
                if(attrInfo.getNumberOfElements() > 1)
                    d.(attrName) = NumericData(...
                        int32(reader.getIntArrayAttribute(dictGroup,...
                        attrName))'...
                        );
                else
                    d.(attrName) = int32(reader.getIntAttribute(dictGroup, attrName));
                end
            elseif(attrInfo.getElementSize() == 8)
                if(attrInfo.getNumberOfElements() > 1)
                    d.(attrName) = NumericData(...
                        int64(reader.getLongArrayAttribute(dictGroup,...
                        attrName))'...
                        );
                else
                    d.(attrName) = int64(reader.getLongAttribute(dictGroup, attrName));
                end
            elseif(attrInfo.getElementSize() == 2)
                if(attrInfo.getNumberOfElements() > 1)
                    d.(attrName) = NumericData(...
                        int64(reader.getShortArrayAttribute(dictGroup,...
                        attrName))'...
                        );
                else
                    d.(attrName) = int16(reader.getShortAttribute(dictGroup, attrName));
                end
            else
                error('ovation:symphony_importer:unsuppored_attribute_type',...
                    [dictGroup '.' attrName ' is not a supported attribute type']);
            end
            
            % DOUBLE (float32, float64)
        elseif(attrInfo.getDataClass() == HDF5DataClass.FLOAT)
            
            %Float, Double
            if(attrInfo.getElementSize() == 4)
                if(attrInfo.getNumberOfElements() > 1)
                    d.(attrName) = NumericData(...
                        single(reader.getFloatArrayAttribute(dictGroup,...
                        attrName))'...
                        );
                else
                    d.(attrName) = single(reader.getFloatAttribute(dictGroup, attrName));
                end
            elseif(attrInfo.getElementSize() == 8)
                if(attrInfo.getNumberOfElements() > 1)
                    d.(attrName) = NumericData(...
                        reader.getDoubleArrayAttribute(dictGroup,...
                        attrName)'...
                        );
                else
                    d.(attrName) = reader.getDoubleAttribute(dictGroup, attrName);
                end
            else
                error('ovation:symphony_importer:unsuppored_attribute_type',...
                    [dictGroup '.' attrName ' is not a supported attribute type']);
            end
        elseif(attrInfo.getDataClass() == HDF5DataClass.BOOLEAN)
            d.(attrName) = reader.getBooleanAttribute(dictGroup, attrName);
        else
            error('ovation:symphony_importer:unsuppored_attribute_type',...
                [dictGroup '.' attrName ' is not a supported attribute type']);
        end
        
    end
end

function epoch = readEpoch(epochGroup,...
        reader,...
        epochPath...
        )
    
    import ovation.*;
    
    startTime = startDateTime(reader, epochPath);
    endTime = startTime.plusSeconds(reader.getFloatAttribute(epochPath,...
        'durationSeconds'...
        )...
        );
    
    protocolID = reader.getStringAttribute(epochPath, 'protocolID');
    
    % Protocol parameters
    if(isGroup(reader, epochPath, 'protocolParameters'))
        protocolParameters = struct2map(readDictionary(reader,...
            epochPath,...
            'protocolParameters'));
    else
        props = reader.readCompoundArray(...
            [char(epochPath) '/protocolParameters'],...
            getClass(ch.systemsx.cisd.hdf5.HDF5CompoundDataMap));
        
        parameters = struct();
        for i = 1:length(props)
            if(~isempty(props(i).get('key')))
                parameters.(char(props(i).get('key'))) = props(i).get('value');
            end
        end
        
        protocolParameters = struct2map(parameters);
    end
    
    epoch = epochGroup.insertEpoch(startTime,...
        endTime,...
        protocolID,...
        protocolParameters...
        );
    
    %% Add keywords
    if(hasKeywords(reader, epochPath))
        addKeywords(reader, epochPath, epoch);
    end
    %% Read stimuli
    readStimuli(epoch,...
        reader,...
        epochPath...
        );
    %% Read responses
    readResponses(epoch,...
        reader,...
        epochPath...
        );
end

function readResponses(epoch, reader, epochPath)
    
    try
        responseInfos = reader.getGroupMemberInformation(...
            [char(epochPath) '/responses'],...
            true...
            );
        
        for i = 0:(responseInfos.size() - 1)
            respPath = responseInfos.get(i).getPath();
            deviceName = reader.getStringAttribute(responseInfos.get(i).getPath(),...
                'deviceName'...
                );
            deviceManufacturer = reader.getStringAttribute(responseInfos.get(i).getPath(),...
                'deviceManufacturer'...
                );
            
            readResponse(epoch,...
                deviceName,...
                deviceManufacturer,...
                reader,...
                respPath...
                );
        end
    catch ME %#ok<NASGU>
        epoch.addTag('symphony_missing_responses');
    end
    
end

function readResponse(epoch, deviceName, deviceManufacturer, reader, respPath)
    
    import ovation.*;
    
    srate = reader.getFloatAttribute(respPath, 'sampleRate');
    srateUnits = reader.getStringAttribute(respPath, 'sampleRateUnits');
    
    
    file = H5F.open(char(reader.getFile()), 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
    dset = H5D.open(file, [char(respPath) '/data']);
    
    %
    % Get dataspace and allocate memory for read buffer.
    %
    space = H5D.get_space (dset);
    [~, dims, ~] = H5S.get_simple_extent_dims (space);
    dims = fliplr(dims);
    
    %
    % Read the data.
    %
    datatype = H5T.open(file, 'MEASUREMENT');
    rdata=H5D.read (dset, datatype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
    
    C = onCleanup(@() cleanup(dset,space,datatype,file));
    
    device = epoch.getEpochGroup().getExperiment().externalDevice(...
        deviceName,...
        deviceManufacturer...
        );
    
    deviceParams = readDeviceParameters(reader,respPath, srate);
    
    [deviceParams,hasDuplicates] = consolidateDeviceParameters(deviceParams);
    
    deviceParamsMap = java.util.HashMap();
    ks = deviceParams.keys;
    for i = 1:length(ks)
        if(~isempty(deviceParams(ks{i})))
            deviceParamsMap.put(ks{i}, deviceParams(ks{i}));
        end
    end
    
    units = unique(cellstr(rdata.unit'));
    if(numel(units) > 1)
        error('ovation:symphony_importer:units', 'Units are not homogenous in response data.');
    end
    
    response = epoch.insertResponse(device,...
        deviceParamsMap,...
        NumericData(single(rdata.quantity')),...
        units{1},...
        [], ...
        srate,...
        srateUnits,...
        Response.NUMERIC_DATA_UTI);
    
    if(hasDuplicates)
        response.addTag('symphony_multiple_device_parameters');
    end
    
    function cleanup(dset,space,datatype,file)
        H5D.close(dset);
        H5S.close(space);
        H5T.close(datatype);
        H5F.close(file);
    end
    
end

function [result,hasDuplicates] = consolidateDeviceParameters(deviceParams)
    
    hasDuplicates = false;
    
    result = containers.Map;
    
    keys = deviceParams.keys;
    for i = 1:length(keys)
        
        k = keys{i};
        
        v = deviceParams(k);
        
        if(isempty(v))
            continue;
        end
        
        if(length(v) > 1)
            hasDuplicates = true;
            
            isNum = true;
            for j = 1:length(v)
                if(~isnumeric(v{j}))
                    isNum = false;
                end
            end
            
            if(isNum)
                v = unique(cell2mat(v));
                if(length(v) > 1)
                    v = {ovation.NumericData(v)};
                else
                    v = {v(1)};
                end
            else
                % Temporary fix Refs #777
                tmp = {};
                for j = 1:length(v)
                    if(~isnumeric(v{j}))
                        tmp{end+1} = v{j}; %#ok<AGROW>
                    end
                end
                
                v = tmp;
                
                v = unique(v);
                tmp = v{1};
                
                % Temporary fix Refs #777
                tmp = tmp(double(tmp) < intmax('int16'));
                % Temporary fix Refs #777
                tmp = tmp(tmp ~= '''');
                
                for j = 2:length(v)
                    val = v{j};
                    
                    % Temporary fix Refs #777
                    val = val(double(val) < intmax('int16'));
                    
                    % Temporary fix Refs #777
                    val = val(val ~= '''');
                    
                    
                    tmp = [tmp ',' val]; %#ok<AGROW>
                end
                v = {tmp};
            end
        end
        
        % Temporary fix Refs #777
        k = k(double(k) < intmax('int16'));
        
        result(k) = v{1};
    end
end

function parameters = readDeviceParameters(reader, respPath, srate)
    
    spansGroup = [char(respPath) '/dataConfigurationSpans'];
    nSpans = reader.getAllGroupMembers(spansGroup).size();
    cStart = 0;
    
    parameters = containers.Map();
    
    for i = 0:(nSpans - 1)
        span = [spansGroup '/span_' num2str(i)];
        startTimeSeconds = reader.getFloatAttribute(span, 'startTimeSeconds');
        gapSeconds = abs(startTimeSeconds - cStart);
        if gapSeconds > 0 && (nargin >= 3 && gapSeconds > (1/srate))
            warning('ovation:symphony_importer:missing_configuration_span', 'Response appears to have missing device configuration span');
        end
        
        cStart = cStart + reader.getFloatAttribute(span, 'timeSpanSeconds');
        
        nodes = reader.getAllGroupMembers(span);
        for j = 0:(nodes.size() - 1)
            
            if(isGroup(reader, span, char(nodes.get(j))))
                params = readDictionary(reader, span, char(nodes.get(j)));
                fnames = fieldnames(params);
                for k = 1:length(fnames)
                    key = fnames{k};
                    value = params.(key);
                    
                    if(parameters.isKey(key))
                        values = parameters(key);
                    else
                        values = {};
                    end
                    
                    values{end+1} = value; %#ok<AGROW>
                    
                    parameters(key) = values;
                end
            else
                params = readTableKVPs(reader, [span '/' char(nodes.get(j))]);
                
                for k = 1:length(params)
                    if(isempty(nodes.get(j)))
                        continue;
                    end
                    
                    key = [char(nodes.get(j)) '_' char(params(k).get('key'))];
                    if(parameters.isKey(key))
                        values = parameters(key);
                    else
                        values = {};
                    end
                    
                    v = params(k).get('value');
                    if(~isnan(str2double(v)))
                        v = str2double(v);
                    end
                    
                    if(isnumeric(v) && (int32(v) == v))
                        v = int32(v);
                    end
                    
                    values{end+1} = v; %#ok<AGROW>
                    
                    parameters(key) = values;
                end
            end
        end
    end
end

function readStimuli(epoch, reader, epochPath)
    
    try
        stimuliInfos = reader.getGroupMemberInformation(...
            [char(epochPath) '/stimuli'],...
            true...
            );
        for i = 0:(stimuliInfos.size()-1)
            stimPath = stimuliInfos.get(i).getPath();
            deviceName = reader.getStringAttribute(stimuliInfos.get(i).getPath(),...
                'deviceName'...
                );
            deviceManufacturer = reader.getStringAttribute(stimuliInfos.get(i).getPath(),...
                'deviceManufacturer'...
                );
            readStimulus(epoch,...
                deviceName,...
                deviceManufacturer,...
                reader,...
                stimPath...
                );
        end
    catch ME %#ok<NASGU>
        epoch.addTag('symphony_missing_stimuli');
    end
    
end

function readStimulus(epoch, deviceName, deviceManufacturer, reader, stimPath)
    
    import ovation.*;
    
    stimulusID = reader.getStringAttribute(stimPath, 'stimulusID');
    
    %% Device
    device = epoch.getEpochGroup().getExperiment().externalDevice(...
        deviceName,...
        deviceManufacturer...
        );
    
    deviceParams = readDeviceParameters(reader, stimPath);
    
    [deviceParams,hasDuplicates] = consolidateDeviceParameters(deviceParams);
    
    deviceParamsMap = java.util.HashMap();
    ks = deviceParams.keys;
    for i = 1:length(ks)
        if(~isempty(deviceParams(ks{i})))
            deviceParamsMap.put(ks{i}, deviceParams(ks{i}));
        end
    end
    
    %% Parameters
    if(hasParameters(reader, stimPath))
        stimParams = readDictionary(reader, stimPath, 'parameters'); 
    else
        stimParams = struct();
    end
    
    stimUnits = reader.getStringAttribute(stimPath, 'stimulusUnits');
    
    %% Insertion
    stimulus = epoch.insertStimulus(device,...
        deviceParamsMap,...
        stimulusID,...
        struct2map(stimParams),...
        stimUnits,...
        []);
    
    if(hasDuplicates)
        stimulus.addTag('symphony_multiple_device_parameters');
    end
end

function kvps = readTableKVPs(reader, tblPath)
    kvps = reader.readCompoundArray(...
        tblPath,...
        getClass(ch.systemsx.cisd.hdf5.HDF5CompoundDataMap));
end

function s = readTable(reader, tblPath)
    kvps = readTableKVPs(reader, tblPath);
    
    for i = 1:length(kvps)
        s.(char(kvps(i).get('key'))) = kvps(i).get('value');
    end
end

function m = readTableMap(reader, tblPath)
    kvps = readTableKVPs(reader, tblPath);
    
    
    m = java.util.HashMap();
    for i = 1:length(kvps)
        m.put(kvps(i).get('key'),...
            kvps(i).get('value')...
            );
    end
end

function addKeywords(reader, grpPath, taggable)
    keywordsStr = reader.getStringAttribute(grpPath, 'keywords');
    keywords = keywordsStr.split(',');
    for i = 1:length(keywords)
        if strcmp(keywords(i),'\')
            kw = '\\';
            warning('ovation:symphony_importer:illegal_keyword_tag', '"\" cannot be used as a KeywordTag in Ovation; using "\\" instead');
        else
            kw = keywords(i);
        end
        taggable.addTag(kw);
    end
end

function b = hasProperties(reader,...
        grpPath...
        )
    
    b = hasDataset(reader, grpPath, 'properties');
end

function b = hasParameters(reader, grpPath)
    b = hasDataset(reader, grpPath, 'parameters');
end

function b = hasDataset(reader,...
        grpPath,...
        datasetName...
        )
    b = false;
    
    grpNames = reader.getAllGroupMembers(grpPath);
    for i = 0:(grpNames.size() - 1)
        if(strcmp(char(grpNames.get(i)), datasetName))
            b = true;
            break;
        end
    end
end

function b = hasKeywords(reader,...
        grpPath...
        )
    
    b = false;
    
    attrNames = reader.getAttributeNames(grpPath);
    for i = 0:(attrNames.size() - 1)
        if(strcmp(char(attrNames.get(i)), 'keywords'))
            b = true;
            break;
        end
    end
    
end

function startTime = startDateTime(reader, grpPath)
    startTicks = reader.getLongAttribute(grpPath, 'startTimeDotNetDateTimeOffsetUTCTicks');
    startTimeZoneOffset = reader.getIntAttribute(grpPath, 'startTimeUTCOffsetHours');
    
    startTime = dotNetTicksToDateTime(startTicks, startTimeZoneOffset);
end

function [startTime,endTime] = groupTimes(reader, epochGroupPath)
    
    startTime = startDateTime(reader, epochGroupPath);
    
    if(reader.hasAttribute(epochGroupPath, 'endTimeDotNetDateTimeOffsetUTCTicks') && ...
        reader.hasAttribute(epochGroupPath, 'endTimeUTCOffsetHours'))

        endTicks = reader.getLongAttribute(epochGroupPath, 'endTimeDotNetDateTimeOffsetUTCTicks');
        endTimeZoneOffset = reader.getIntAttribute(epochGroupPath, 'endTimeUTCOffsetHours');
        
        endTime = dotNetTicksToDateTime(endTicks, endTimeZoneOffset);
    else
        endTime = [];
    end
end

function dateTime = dotNetTicksToDateTime(ticks, timezoneOffset)
    
    import org.joda.time.*;
    
    % The .Net reference date (0001-01-01 0:0:0 UTC)
    dotNetRefDate = DateTime(1,1,1,0,0,0,0,...
        DateTimeZone.UTC);
    
    
    % The Joda Time reference date (1970-01-01 0:0:0 UTC)
    jodaRefDate = DateTime(0, DateTimeZone.UTC);
    
    
    % Create a DateTime with given .Net ticks since reference date (UTC)
    milliseconds = ticks/1e4; % 100 nanosecond ticks
    
    assert(milliseconds < java.lang.Long.MAX_VALUE, ...
        'Long integer overflow.');
    
    refOffsetPeriod = Period(dotNetRefDate, jodaRefDate);
    
    tmp = DateTime(milliseconds,DateTimeZone.UTC);
    
    utcDateTime = tmp.minus(refOffsetPeriod);
    
    % Convert to local time in time zone
    tz = org.joda.time.DateTimeZone.forOffsetHours(timezoneOffset);
    dateTime = utcDateTime.withZone(tz);
    
end
