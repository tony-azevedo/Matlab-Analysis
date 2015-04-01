function lims = lesstight(lims)
dif = .05*diff(lims);
lims = lims + [-dif dif];
