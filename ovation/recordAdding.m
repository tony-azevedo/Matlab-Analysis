% Ovation analysis record
clear
import ovation.*;

context = NewDataContext('anthony_azevedo@hms.harvard.edu');

%%

% Create an iterable of inputs
inputs = [measurement1, measurement2, measurement3];

% Designate the protocol for this analysis
protocol = context.getProtocol('First analysis v1');
if(isempty(protocol))
    protocol = context.insertProtocol('First analysis v1',...       % protocol name
                    '...analysis description...',...                % text block describing the analysis (e.g. its algorithms or approaches)
                    'analysis_fn',...                               % name of the "top-level" analysis function
                    'git@github.com:physion/ovation-docs.git',...   % the URL hosting analysis code (we use the Ovation documentation site's GitHub repository as an example)
                    '96ff339f30297f3dda2e14ec9babaa590acd8174',...  % revision number of the analysis code

        );
end


% Record any parameters of the analysis
parameters = struct();
parameters.threshold = 1.0;
parameters.max_n = 10;


ar = project.addAnalysisRecord('First analysis',% record name
    inputs,                                     % iterable of inputs (Measurements and/or AnalysisOutputs)
    protocol,                                   % analysis protocol
    struct2map(parameters)                      % analysis parameters
    );