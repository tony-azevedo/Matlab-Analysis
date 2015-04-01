%addpath <path/to/ovation-matlab>
import ovation.* % the matlab api
import us.physion.ovation.*
import us.physion.ovation.api.*
import us.physion.ovation.values.*

set(0,'DefaultAxesFontName','Arial')

if ispref('AcquisitionPrefs')
%     rmpref('AcquisitionPrefs')
end

javaaddpath 'C:\Program Files (x86)\MATLAB\R2013b\java\jar\ij-1.49g.jar'
javaaddpath 'C:\Program Files (x86)\MATLAB\R2013b\java\jar\ij-1.49g.jar'

cd C:\Users\Anthony' Azevedo'\Acquisition\