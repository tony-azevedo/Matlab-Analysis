#pragma rtGlobals=1		// Use modern global access method.
Function LoadHDFFile(fname)
	String fname	
	String varFolder
	Variable pos
	pos = strsearch (fname, ".",0)
	varFolder = fname[0,pos-1]
	
	Variable fileID
	NewPath /O hdf5path "HD:Users:Greg:hdf5_temp:"
	HDF5OpenFile /R /P=hdf5path fileID as fname
	//list data members (for debugging)
	//HDF5ListGroup fileID, "FigData"
	//print S_HDF5ListGroup
	
	if (V_flag == 0)	// file ok?
		NewDataFolder /O $varFolder
		HDF5LoadGroup /O $varFolder,fileID, "FigData"
		HDF5CloseFile fileID
	endif
End