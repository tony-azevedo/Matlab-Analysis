function toPDF_button_callBack2(hObject,eventData)
plotCanvas = findobj(get(get(hObject,'parent'),'parent'),'type','axes');
tempFig = figure;
set(plotCanvas,'parent',tempFig)
