function s = savePDF(fig,savedir,auxdir,name)

if ~isdir(fullfile(savedir,auxdir))
    mkdir(fullfile(savedir,auxdir))
end

fn = fullfile(savedir,auxdir,[name '.pdf']);
figure(fig)
eval(['export_fig ' regexprep(fn,'\sAzevedo',''' Azevedo''') ' -pdf -transparent']);

% set(fig,'paperpositionMode','auto');
% saveas(fig,fullfile(savedir,auxdir,name),'fig');
s = 1;