#pragma rtGlobals=1		// Use modern global access method.
Function DisplayFigFromMatlab(dataFolder, decimateBy)
	String dataFolder
	Variable decimateBy
	
	String line_waves, lim_wave, curWave, curPrefix,color,X,start,delta,marker,markerfacecolor,errbar,errbarx,linestylevalue
	Variable i,r,g,b,m,l
	Variable str_pos
	Variable oldNpts, newNpts
	
	SetDataFolder dataFolder

	line_waves = WaveList("*_Y",";","")
	do 
		curWave = StringFromList(i, line_waves)
		if (strlen(curWave) == 0)
			break
		endif
		str_pos = strsearch (curWave, "_Y",0)
		curPrefix = curWave[0,str_pos-1]

		//get X data
		sprintf  X, "%s_X",  curPrefix

		//display		
		if (i == 0)
			if (WaveExists($X))
				Display $curWave vs $X
			else
				Display $curWave
			endif
		else
			if (WaveExists($X))
				AppendToGraph $curWave vs $X
			else
				AppendToGraph $curWave
			endif			
		endif
		
		//set Xscale if no Xwave
		if (WaveExists($X) == 0)
			sprintf  start, "%s_start",  curPrefix
			sprintf  delta, "%s_delta",  curPrefix
			NVAR start_v = $start
			NVAR delta_v = $delta
			//print start
			//print delta
			SetScale/P x start_v,delta_v,"", curWave
		endif		
		
		//decimate 
		if (decimateBy > 1)
		 	oldNpts = numpnts($curWave)
		 	newNpts = oldNpts / decimateBy
		 	Make /O/N=(newNpts) newWave
		 	SetScale x, leftx($curWave), rightx($curWave), newWave
		 	//SetScale x, leftx($curWave), rightx($curWave), newWave
		 	newWave = mean($curWave, x, x+(decimateBy-1)*deltax($curWave))
		 	Duplicate /O newWave, $curWave
		 	
		 	if (WaveExists($X))
		 		//Make /O/N=(newNpts) newX
		 		//Duplicate /O $X, newX
		 		Resample /DOWN=(decimateBy) /N=1  $X
		 		//Duplicate /O newX, $X
		 	endif
		endif
		
		//set axis labels
		if (WaveExists(Xlabel))
			Wave /T Xlabel_wv = Xlabel
			label bottom Xlabel_wv
	 	endif
		if (WaveExists(Ylabel))
			Wave /T Ylabel_wv = Ylabel
			label left Ylabel_wv
	 	endif
		
		//set color
		sprintf  color, "%s_color",  curPrefix
		if (WaveExists($color))	
			Wave colorWave = $color	
			r = round(colorWave[0]*(2^16-1))
			g = round(colorWave[1]*(2^16-1))
			b = round(colorWave[2]*(2^16-1))
			ModifyGraph rgb($curWave) = (r,g,b)
		endif		

		//set linestyle
		sprintf  linestylevalue, "%s_linestyle",  curPrefix
		if (WaveExists($linestylevalue))	
			Wave styleWave = $linestylevalue
			l = styleWave[0]
			ModifyGraph lstyle($curWave)=l
		endif	
	
		//set markers
		sprintf  marker, "%s_marker",  curPrefix
		if (WaveExists($marker))	
			Wave markerWave = $marker
			m = markerWave[0]
			if(m!=14)
				//print m
				sprintf markerfacecolor, "%s_markercolor",  curPrefix
				Wave faceColor = $markerfacecolor
				r = round(faceColor[0]*(2^16-1))
				g = round(faceColor[1]*(2^16-1))
				b = round(faceColor[2]*(2^16-1))
				//print r,g,b
				ModifyGraph rgb($curWave) = (r,g,b)
				ModifyGraph mode($curWave)=3,marker($curWave)=m
			endif
		endif

		//set errorbars y
		sprintf  errbar, "%s_Yerr",  curPrefix
		if (WaveExists($errbar))	
			ErrorBars $curWave Y,wave=($errbar,$errbar)
		endif
		
		//set errorbars x
		sprintf  errbarx, "%s_Xerr",  curPrefix
		if (WaveExists($errbarx))	
			ErrorBars $curWave XY,wave=($errbarx,$errbarx),wave=($errbar,$errbar)
		endif
		
		i += 1
	while(1)
	//print "here"
	//legend
	//Legend/C/N=text0/F=0/A=RT
	
	DoWindow $dataFolder
	if (V_flag == 1) //window exists
		DoWindow /K $dataFolder
	endif
	DoWindow/C/T $dataFolder, dataFolder
	//print "here"
	
	SetDataFolder root:
	print "here"
end


Function DisplayFigFromMatlabNoKill(dataFolder, decimateBy)
	String dataFolder
	Variable decimateBy
	
	String line_waves, lim_wave, curWave, curPrefix,color,X,start,delta,marker,markerfacecolor,errbar,errbarx,linestylevalue
	Variable i,r,g,b,m,l,Xscale,Yscale
	Variable str_pos
	Variable oldNpts, newNpts
	
	//SetDataFolder dataFolder

	line_waves = WaveList("*_Y",";","")
	do 
		curWave = StringFromList(i, line_waves)
		if (strlen(curWave) == 0)
			break
		endif
		str_pos = strsearch (curWave, "_Y",0)
		curPrefix = curWave[0,str_pos-1]

		//get X data
		sprintf  X, "%s_X",  curPrefix

		//display		
		if (i == 0)
			if (WaveExists($X))
				Display $curWave vs $X
			else
				Display $curWave
			endif
		else
			if (WaveExists($X))
				AppendToGraph $curWave vs $X
			else
				AppendToGraph $curWave
			endif			
		endif
		
		//set Xscale if no Xwave
		if (WaveExists($X) == 0)
			sprintf  start, "%s_start",  curPrefix
			sprintf  delta, "%s_delta",  curPrefix
			NVAR start_v = $start
			NVAR delta_v = $delta
			//print start
			//print delta
			SetScale/P x start_v,delta_v,"", curWave
		endif		
		
		//decimate 
		if (decimateBy > 1)
		 	oldNpts = numpnts($curWave)
		 	newNpts = oldNpts / decimateBy
		 	Make /O/N=(newNpts) newWave
		 	SetScale x, leftx($curWave), rightx($curWave), newWave
		 	//SetScale x, leftx($curWave), rightx($curWave), newWave
		 	newWave = mean($curWave, x, x+(decimateBy-1)*deltax($curWave))
		 	Duplicate /O newWave, $curWave
		 	
		 	if (WaveExists($X))
		 		//Make /O/N=(newNpts) newX
		 		//Duplicate /O $X, newX
		 		Resample /DOWN=(decimateBy) /N=1  $X
		 		//Duplicate /O newX, $X
		 	endif
		endif
		
		//set axis labels
		if (WaveExists(Xlabel))
			Wave /T Xlabel_wv = Xlabel
			label bottom Xlabel_wv
	 	endif
		if (WaveExists(Ylabel))
			Wave /T Ylabel_wv = Ylabel
			label left Ylabel_wv
	 	endif
	 	
 		if (WaveExists(Xscale))
 			Wave thisXscale=Xscale
			ModifyGraph log(bottom)=thisXscale[0]
 		endif
		if (WaveExists(Yscale))
 			Wave thisYscale=Yscale	 		
			ModifyGraph log(left)=thisYscale
		endif
		
		//set color
		sprintf  color, "%s_color",  curPrefix
		if (WaveExists($color))	
			Wave colorWave = $color	
			r = round(colorWave[0]*(2^16-1))
			g = round(colorWave[1]*(2^16-1))
			b = round(colorWave[2]*(2^16-1))
			ModifyGraph rgb($curWave) = (r,g,b)
		endif		

		//set linestyle
		sprintf  linestylevalue, "%s_linestyle",  curPrefix
		if (WaveExists($linestylevalue))	
			Wave styleWave = $linestylevalue
			l = styleWave[0]
			ModifyGraph lstyle($curWave)=l
		endif
	
		//set markers
		sprintf  marker, "%s_marker",  curPrefix
		if (WaveExists($marker))	
			Wave markerWave = $marker
			m = markerWave[0]
			if(m!=14)
				//print m
				sprintf markerfacecolor, "%s_markercolor",  curPrefix
				if (WaveExists($markerfacecolor))
				Wave faceColor = $markerfacecolor
				r = round(faceColor[0]*(2^16-1))
				g = round(faceColor[1]*(2^16-1))
				b = round(faceColor[2]*(2^16-1))
				//print r,g,b
				ModifyGraph rgb($curWave) = (r,g,b)
				ModifyGraph mode($curWave)=3,marker($curWave)=m
				endif
			endif
		endif

		//set errorbars y
		sprintf  errbar, "%s_Yerr",  curPrefix
		if (WaveExists($errbar))	
			ErrorBars $curWave Y,wave=($errbar,$errbar)
		endif
		
		//set errorbars x
		sprintf  errbarx, "%s_Xerr",  curPrefix
		if (WaveExists($errbarx))	
			ErrorBars $curWave XY,wave=($errbarx,$errbarx),wave=($errbar,$errbar)
		endif
		
		i += 1
	while(1)
	//legend
	Legend/C/N=text0/F=0/A=RT
end

Macro MakeFig(h5name)
	string h5name
	variable h5file
	string h5path="Aydabelle:Users:fred:hdf5_temp:" +h5name+".h5"
	if (WinType(h5name)==1)
		KillWindow $h5name
	endif
	KillDataFolder/Z root:$h5name
	NewDataFolder/o/s root:$h5name
	HDF5OpenFile h5file as h5path
	HDF5LoadGroup :,h5file , h5name
	HDF5CloseFile h5file
	DisplayFigFromMatlab(h5name,1)
	SetDataFolder root:
	DoWindow/C/R $h5name
	formatgraph()
end

Macro RefreshData(h5name)
	string h5name
	variable h5file
	string h5path="HD:Users:juan:hdf5_temp:TestMatlabFig2Igor:" +h5name+".h5"
	SetDataFolder root:$h5name
	Killwaves/A/Z
	HDF5OpenFile h5file as h5path
	HDF5LoadGroup/o :,h5file , h5name
	HDF5CloseFile h5file
	SetDataFolder root:
end

Macro MakeScaleBars(StartX, EndX, StartY, EndY, XLabel, YLabel)
	variable StartX
	variable EndX
	variable StartY
	variable EndY
	string XLabel
	string YLabel
	ModifyGraph noLabel=2,axThick=0
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine StartX, StartY, StartX, EndY
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine StartX, EndY, EndX, EndY
	SetDrawEnv xcoord= bottom,ycoord= left
	SetDrawEnv fname= "Helvetica",fsize= 16
	DrawText (StartX+EndX)/2, EndY*1.05, XLabel
	SetDrawEnv xcoord= bottom,ycoord= left
	SetDrawEnv fname= "Helvetica",fsize= 16
	DrawText StartX*.95, (StartY + EndY)/2, YLabel
end
