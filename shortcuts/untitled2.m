currentSelection = getSelectedText();
if ischar(currentSelection) &&...
        regexp(currentSelection,'_F') &&...
        regexp(currentSelection,'_C') &&...
        sum(regexp(currentSelection(1:8),'\d')) == 21
    
    yymmdd = currentSelection(1:6);
    
    if ismac
        D_ = getpref('USERDIRECTORY','MAC');
    elseif ispc
        D_ = getpref('USERDIRECTORY','PC');
    end
    D_ = fullfile(D_,'Raw_Data',yymmdd,currentSelection);
    cd(D_)
    quickShow
else
    beep
end

clear D_ currentSelection yymmdd jTxt jTextArea jDesktop cmdWin