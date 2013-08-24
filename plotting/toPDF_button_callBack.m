function toPDF_button_callBack(hObject,eventData)
figData = guidata(hObject);
try plotCanvas = figData.canvas;
catch
    plotCanvas = figData.panel;
end
ch = get(plotCanvas,'children');
tempFig = figure;
moving_ch = [];

for i=1:length(ch)
    if ~isprop(ch(i),'style') || ~strfind(get(ch(i),'style'), 'button')
        moving_ch = [moving_ch ch(i)];
    end
end

for i=1:length(moving_ch)
    set(moving_ch(i),'parent',tempFig);
end
end
