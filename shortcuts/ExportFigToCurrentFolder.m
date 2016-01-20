save2dir = getpref('FigureMaking','SaveToFolder');
if ~length(dir(save2dir))
    error('%s not found',save2dir);
end

sldkfjExportFig = gcf;

sldkjName = sldkfjExportFig.Name;

[FileName, PathName] = uiputfile(fullfile(save2dir,[sldkjName '.pdf']),'Save As');

if isequal(FileName,0) || isequal(PathName,0)
   error('Canceled');
else
   disp(['User selected ',fullfile(PathName,FileName)])
end
                   
fn = fullfile(PathName,FileName);
figure(sldkfjExportFig)
% eval(['export_fig ' regexprep(fn,'\sAzevedo',''' Azevedo''') ' -pdf -transparent']);
eval(['export_fig ' fn]);

clear Filename PathName save2dir sldkfjExportFig sldkjName fn