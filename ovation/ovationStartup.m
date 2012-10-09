% ovationStartup
% Does the main things involved in getting Symphony data into ovation
% 
acquisitionFolder = '/Users/tony/acquistion';
dataFolder = '/Users/tony/data';
connection_file = fullfile(dataFolder, 'database.connection');


context = NewDataContext(connection_file, 'tony');

contextViewer

%%
import org.joda.*;
project_name = 'Paper about mouse brains';
amp_name = 'amp model 3400';
amp_manufacturer_name = 'National Instruments';


epochGroupRoot = context.