function metadata = parseSymphonyXMLMetadata(xmlPath)
	
	dom = xmlread(xmlPath);
	xRoot = dom.getDocumentElement();
	
	dispatch = struct(...
		'source', @parseSource,...
		'notes', @parseNotes...
		);
	
	ignoreNodes = {'#text'};
	
	metadata = struct(...
        'source',struct(),...
        'notes', struct()...
        );
	
	cNodes = xRoot.getChildNodes();
	for i = 0:(cNodes.getLength() - 1)
		childNode = cNodes.item(i);
		if(~any(strcmp(childNode.getNodeName(), ignoreNodes)))
            name = char(childNode.getNodeName());
			fn = dispatch.(name);
			metadata.(name) = fn(childNode, struct());
		end
	end
end


function srcMetadata = parseSource(sourceNode, srcMetadata)
%Recursively parse a source node

    uuid = sourceNode.getAttribute('identifier');
    label = sourceNode.getAttribute('label');
    
    uuid_key = genvarname(char(uuid));
	
    srcMetadata.(uuid_key).label = label;
    srcMetadata.(uuid_key).uuid = uuid;
    
    cNodes = sourceNode.getChildNodes();
    for i = 0:(cNodes.getLength() - 1)
        childNode = cNodes.item(i);
        if(childNode.getNodeName().equals(sourceNode.getNodeName()))
            if(~isfield(srcMetadata.(uuid_key), 'children'))
                srcMetadata.(uuid_key).children = struct();
            end
            
            srcMetadata.(uuid_key).children = parseSource(childNode, ...
                srcMetadata.(uuid_key).children);
        end
    end
end


function notesMetadata = parseNotes(notesNode, ~)

	cNodes = notesNode.getChildNodes();
    notes(cNodes.getLength()) = struct('time', [],...
        'text', []...
        );
    
    totalNotes = 0;
    for i = 0:(cNodes.getLength() - 1);
        childNode = cNodes.item(i);
        if(childNode.getNodeName().equals('note'))
            
            fmt = org.joda.time.format.DateTimeFormat.forPattern('MM/dd/yyyy hh:mm:ss aa Z');
            dateText = childNode.getAttribute('time');
            notes(totalNotes+1).time = fmt.parseDateTime(dateText);

            ncNodes = childNode.getChildNodes();
            assert(ncNodes.getLength() == 1);
            textNode = ncNodes.item(0);
            
            notes(totalNotes+1).text = textNode.getTextContent();
            
            totalNotes = totalNotes + 1;
        end
    end
    
    notesMetadata = notes(1:totalNotes);
end
