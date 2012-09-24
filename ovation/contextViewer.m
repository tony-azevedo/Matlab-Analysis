% Script to view data base context easily

projects = context.getProjects();
sources = context.getSources();

%%

fprintf('\n -- Context Projects: \n\n');
for p = 1:length(projects)
    fprintf('%s\n',char(projects(p).getName))
    tags = projects(p).getTags;
    for t = 1:length(tags)
        fprintf('\t%s\n',char(tags(t)));
    end
    experiments = projects(p).getExperiments;
    for e = 1:length(experiments)
        epGrps = experiments(e).getEpochGroups;
        sources = experiments(e).getSources;
        fprintf('\t\t%d.%d.%d (%d Sources, %d EGs): %s\n',...
            experiments(e).getStartTime.getDayOfMonth,...
            experiments(e).getStartTime.getMonthOfYear,...
            experiments(e).getStartTime.getYear,...
            length(sources),...
            length(epGrps),...
            char(experiments(e).getPurpose.toString));
        for s = 1:length(sources);
            tags = sources(s).getTags;            
            fprintf('\t\t\t%s: ',...
                char(sourceLabel(sources(s))));
            for t = 1:length(tags)
                tgstr = sprintf('%s - ',char(tags(t)));
            end
            if length(tags)>1; fprintf('%s\n',tgstr(1:end-3)), else fprintf('\n');end
        end
        for eg = 1:length(epGrps);
            props = epGrps(eg).getProperties;
            keys = props.keySet.toArray;
            fprintf('\t\t\t%d Epochs: [',...
                epGrps(eg).getEpochCount);
            fprintf('%s]\n',char(epGrps(eg).getLabel));
            %             prpstr = '';
            %             for k = 1:length(keys)
            %                 val = cell(props.get(keys(k)));
            %                 if isa(val{1},'double');
            %                     prpstr = sprintf('%s%s - %g, ',...
            %                         prpstr,...
            %                         char(keys(k)),...
            %                         val{1});
            %                 elseif isa(val{1},'char');
            %                     prpstr = sprintf('%s%s - %s,',...
            %                         prpstr,...
            %                         char(keys(k)),...
            %                         val{1});
            %                 end
            %             end
            %             fprintf('%s]\n',prpstr(1:end-1))
        end
    end
end

%% 
fprintf('\n -- %d Context Sources\n\n',length(sources))

sources = context.getSources();
curparent = sources(1);
for s = 1:length(sources)
    l = char(sources(s).getLabel);
    tbstr = '';
    for i = 1:depth(sources(s))
        tbstr = [tbstr,'\t']; %#ok<AGROW>
    end
    fmstr = [tbstr,'%s'];
    fprintf(fmstr,l);
    
    fprintf(': %s;\n',char(sources(s).getOwner.getUsername));

    tags = cell(sources(s).getTags);
    for t = 1:length(tags)
        fprintf('%s\t - %s\n',tbstr,tags{t});
    end
end

%% Example queries