#pragma rtGlobals=1		// Use modern global access method.

Menu "Murder"
	"GraphKiller"
	"LayoutKiller"
	"WaveKiller"
	"KillWavesStartingWith"
	"KillWavesEndingWith"
	"KillWavesContaining"
	"HideGraphWavesContaining"
	"ShowGraphWavesContaining"
	"Clonewindow"
End

Function ListFolders()
string ll
//ll=(DataFolderDir(1))
ll=GetDataFolder(1)
print(ll)
end

Function GraphKiller()
	string bb,deathList, nextToDie
	variable i = 0
	deathlist = WinList ("*",";","WIN:1")
	do
		nextToDie = stringFromList(i,deathList,";")
		if (strLen(nextToDie)==0)
			break
		endif
		KillWindow $nextToDie
		i+=1
	while(1)
	print num2str(i) + " graphs were killed"
End

Function LayoutKiller()
	string bb,deathList, nextToDie
	variable i = 0
	deathlist = WinList ("*",";","WIN:4")
	do
		nextToDie = stringFromList(i,deathList,";")
		if (strLen(nextToDie)==0)
			break
		endif
		KillWindow $nextToDie
		i+=1
	while(1)
	print num2str(i) + " layouts were killed"
End

Function WaveKiller()
	string deathList, nextToDie
	variable i = 0
	deathlist = WaveList ("*",";","")
	do
		nextToDie = stringFromList(i,deathList)
		if (strLen(nextToDie)==0)
			break
		endif
		killwaves/z $nextToDie
		i+=1
	while(1)
	print num2str(i) + " waves were killed"
End

Function KillWavesStartingWith()
	string DeathPrefix = ""
	string bb,deathList, nextToDie
	variable i = 0
	Prompt deathPrefix , "choose to kill"
	DoPrompt "Prefix of doom", DeathPrefix
	
	if (strLen(deathPrefix)==0)
		return -1
	endif
	if (V_flag)
		return -1
	endif
	bb= deathPrefix + "*"
	deathlist = WaveList (bb,";","")
	do
		nextToDie = stringFromList(i,deathList)
		if (strLen(nextToDie)==0)
			break
		endif
		killwaves/z $nextToDie
		i+=1
	while(1)
	print num2str(i) + " waves starting with '" + deathPrefix + "' were killed"
End

Function KillWavesContaining()
	string DeathString = "*-*"
	string bb,deathList, nextToDie
	variable i = 0
	Prompt deathString , "choose to kill"
	DoPrompt "string of doom", deathString
	
	if (strLen(deathString)==0)
		return -1
	endif
	if (V_flag)
		return -1
	endif
	deathlist = WaveList (DeathString,";","")
	do
		nextToDie = stringFromList(i,deathList)
		if (strLen(nextToDie)==0)
			break
		endif
		killwaves/z $nextToDie
		i+=1
	while(1)
	print num2str(i) + " waves with '" + deathString + "' were killed"
End

Function KillWavesEndingWith()
	string DeathSuffix = ""
	string bb,deathList, nextToDie
	variable i = 0
	Prompt DeathSuffix , "choose to kill"
	DoPrompt "Suffix of doom", DeathSuffix
	
	if (strLen(deathSuffix)==0)
		return -1
	endif
	if (V_flag)
		return -1
	endif
	bb= "*"+ deathSuffix
	deathlist = WaveList (bb,";","")
	do
		nextToDie = stringFromList(i,deathList)
		if (strLen(nextToDie)==0)
			break
		endif
		killwaves/z $nextToDie
		i+=1
	while(1)
	print num2str(i) + " waves ending in '" + deathSuffix + "' were killed"
END


Function HideGraphWavesContaining()
	string hideString = "*_*"
	string bb,traceList,hideList, nextToHide
	variable i = 0
	Prompt hideString , "choose to hide"
	DoPrompt "string of invisibility", hideString
	
	if (strLen(hideString)==0)
		return -1
	endif
	if (V_flag)
		return -1
	endif
	traceList = TraceNameList("",";",1)
	hideList = ListMatch (traceList,hideString,";")
	do
		nextToHide = stringFromList(i,hideList)
		if (strLen(nextToHide)==0)
			break
		endif
		ModifyGraph hideTrace($nextToHide)=1
		i+=1
	while(1)
	print num2str(i) + " waves with '" + hideString + "' were made invisible"
End

Function ShowGraphWavesContaining()
	string hideString = "*_*"
	string bb,traceList,hideList, nextToHide
	variable i = 0
	Prompt hideString , "choose to hide"
	DoPrompt "string of invisibility", hideString
	
	if (strLen(hideString)==0)
		return -1
	endif
	if (V_flag)
		return -1
	endif
	traceList = TraceNameList("",";",1)
	hideList = ListMatch (traceList,hideString,";")
	do
		nextToHide = stringFromList(i,hideList)
		if (strLen(nextToHide)==0)
			break
		endif
		ModifyGraph hideTrace($nextToHide)=0
		i+=1
	while(1)
	print num2str(i) + " waves with '" + hideString + "' were made visible"
End

Function CloneWindow([win,replace,with])
	String win // Name of the window to clone.  
	String replace,with // Replace some string in the windows recreation macro with another string.  
	Variable freeze // Make a frozen clone (basically just a picture).  
 
	if(ParamIsDefault(replace) || ParamIsDefault(with))
		replace=""; with=""
	endif
	if(ParamIsDefault(win))
		win=WinName(0,1)
	endif
	String win_rec=WinRecreation(win,0)
	Variable i
	for(i=0;i<ItemsInList(replace);i+=1)
		String one_replace=StringFromList(i,replace)
		String one_with=StringFromList(i,with)
		win_rec=ReplaceString(one_replace,win_rec,one_with)
	endfor
	Execute /Q win_rec
End