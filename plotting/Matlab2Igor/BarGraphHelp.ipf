#pragma rtGlobals=1		// Use modern global access method.

Macro BarGraphWithDataSetup(N)
variable N
variable cnt = 1
variable dblcnt = 1.0;
variable wavenameisok;
KillWaves/Z span1, point1,height1
Make/N=2/D span1
Make/N = 1/D point1
point1 = 1
span1[0] = .55
span1[1] = 1.45
Duplicate span1 height1
Edit span1 height1 point1
string spanName
string heightName
string pointName
do
	cnt+=1
	dblcnt = dblcnt+1.0;
	spanName = "span"+num2istr(cnt)
	heightName = "height"+num2istr(cnt)
	pointName = "point"+num2istr(cnt)
	if (CheckName(spanName, 1) != 0)
		KillWaves $spanName, $pointName, $heightName
	endif

	Duplicate span1 $spanName 
	Duplicate point1 $pointName
	Duplicate height1 $heightName
	$pointName = $pointName * cnt;
	print $spanName
	$spanName = dblcnt + $spanName -1.0;
	print $spanName
	
	AppendToTable $spanName, $pointName, $heightName
while (cnt < N+1)
End


Macro MakeBar(dataFolder)
string dataFolder

SetDataFolder dataFolder

AppendToGraph bar_Y vs bar_X
AppendToGraph mean_Y vs mean_X; 
AppendToGraph data_Y vs data_X

Macro BarGraphColumnChooser(N)
variable N
variable scalefactor
scalefactor = 1/(height_X[0]);
data_X = (data_X+0.1)*scalefactor*N - 0.1
mean_X[0] = N+0.1
height_X[0] = N
wavestats/Q bar_X
bar_X = bar_X-V_avg+height_X
End


Macro ModifyBarAppearance(N)
variable N
string cat
string dataname
string barname
string semname
string meanname
string barnumber
if (N==0)
	barnumber = "";
else
	barnumber = "#" + num2istr(N)
endif 
barname = "bar_Y" +barnumber
dataname =  "data_Y" +barnumber
meanname = "mean_Y" + barnumber
semname = "mean_Yerr"
ModifyGraph mode($meanname)=2,mode($dataname)=3,marker($dataname)=19;
ModifyGraph mode($barname)=5,hbFill($barname)=5;
ErrorBars $meanname Y,wave=($semname,$semname)
ReorderTraces $dataname,{$meanname}
ReorderTraces $meanname,{$barname,$dataname}
SetDataFolder root:


Macro BarGraphAxes()
ModifyGraph nticks(bottom)=0,minor=1,axThick(bottom)=0
