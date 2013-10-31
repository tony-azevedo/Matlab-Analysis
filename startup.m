%addpath <path/to/ovation-matlab>
import ovation.* % the matlab api
import us.physion.ovation.*
import us.physion.ovation.api.*
import us.physion.ovation.values.*

set(0,'DefaultAxesFontName','Arial')

if ispref('AcquisitionPrefs')
%     rmpref('AcquisitionPrefs')
end

cd C:\Users\Anthony' Azevedo'\Acquisition\