#pragma rtGlobals=1		// Use modern global access method.
#pragma rtGlobals=1  // Use modern global access method.

//Macro FormatGraph()
//ModifyGraph fSize=18,font="Helvetica Neue"
//ModifyGraph tick=2,nticks=2,manTick=0
//ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0.05,1}
//ModifyGraph margin(left)=54,margin(bottom)=54,margin(top)=18,margin(right)=18
//End

Macro AddBaseline()
AppendToGraph baseline vs baselinelim
ModifyGraph rgb=(0,0,0),lstyle(baseline)=1
End

Macro FormatInset()
ModifyGraph fSize=12
End

Macro FormatAsTrace()
ModifyGraph axThick(left)=0
ModifyGraph nticks=0,axThick=0
Label left "";DelayUpdate
Label bottom ""
ModifyGraph margin=10
SetAxis left -1,2.5
SetAxis bottom -.399,4
ModifyGraph gFont="Helvetica Neue",gfSize=12
End

Macro Formatbaselinecorrected()
ModifyGraph axThick(left)=0
ModifyGraph nticks=0,axThick=0
Label left "";DelayUpdate
Label bottom ""
ModifyGraph margin=10
SetAxis left -3,4
SetAxis bottom -1.999,4.5
End

Macro FormatGraphScratch()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=0,manTick=0

ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0.05,1}
ModifyGraph margin(left)=18,margin(bottom)=18,margin(top)=18,margin(right)=18
SetAxis bottom -0.7,10
ModifyGraph axThick=0
ModifyGraph rgb=(0,0,0)
End

Macro FormatERGWOMargins()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=0,manTick=0
ModifyGraph manTick(left)={0,0,0,5},manMinor(left)={0,50}
ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0.05,1}
ModifyGraph margin(left)=5,margin(bottom)=5,margin(top)=5,margin(right)=18
SetAxis bottom -0.149,1.5
ModifyGraph axThick=0
ModifyGraph rgb=(0,0,0)
End

Macro FormatGraphForSlide()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=2,nticks=2,manTick=0
ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0.05,1}
ModifyGraph margin(left)=54,margin(bottom)=54,margin(top)=18,margin(right)=18
End

Macro FormatGraphForPaperFigure()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=5,manTick=0
ModifyGraph axisEnab(left)={0.00,1},axisEnab(bottom)={0.00,1}
ModifyGraph margin(left)=72,margin(bottom)=54,margin(top)=18,margin(right)=18
ModifyGraph minor(bottom)=0
End

Macro FormatGraphForModelPaperFigure()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=5,manTick=0
ModifyGraph axisEnab(left)={0.00,1},axisEnab(bottom)={0.05,1}
ModifyGraph margin(left)=72,margin(bottom)=54,margin(top)=18,margin(right)=18
ModifyGraph minor(bottom)=0
End

Macro FormatSurfacePlot()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=5,manTick=0
ModifyGraph axisEnab(left)={0.0,1},axisEnab(bottom)={0.0,1}
ModifyGraph margin(left)=40,margin(bottom)=40,margin(top)=20,margin(right)=20
ModifyGraph minor(bottom)=0
ModifyGraph mirror=2
Label bottom ""
Label left ""
End

Macro FormatModelTracesPlot()
ModifyGraph fSize=18,font="Helvetica Neue"
ModifyGraph tick=0,nticks=5,manTick=0
ModifyGraph nticks(left)=2
ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0.005,1}
ModifyGraph margin(left)=40,margin(bottom)=40,margin(top)=10,margin(right)=10
ModifyGraph minor(bottom)=0
ModifyGraph mirror=0
Label bottom ""
Label left ""
ModifyGraph manTick(left)={0,1,0,0},manMinor(left)={0,50}
End

Macro FormatExamplesPlot()
FormatGraphForPaperFigure()
Label bottom ""
Label left ""
ModifyGraph axisEnab(left)={0.05,1},axisEnab(bottom)={0,1}
//RemoveFromGraph L003_Y
//RemoveFromGraph L001_Y
//RemoveFromGraph L005_Y
//ModifyGraph prescaleExp(left)=1
ModifyGraph nticks=2;DelayUpdate
SetAxis bottom 1,1200
End

Macro SplitWaveIntoSections(OriginalWave, SectionLength, BaseName)
string OriginalWave
variable SectionLength
string BaseName
variable numpts = numpnts($OriginalWave)
variable numsections = numpts/sectionlength
variable cnt = 0;
string NewWaveName
Silent 1; PauseUpdate
do
NewWaveName = BaseName + num2str(cnt)
make/o/n=(SectionLength) $NewWaveName
$NewWaveName[0,SectionLength] = $OriginalWave[cnt*SectionLength + p]
cnt = cnt + 1
while (cnt < numsections)
end

#pragma rtGlobals=1 // Use modern global access method.

Macro NormalizeYaxis()
ModifyGraph manTick(left)={0,1,0,0},manMinor(left)={0,50}
End

Macro Append2DwaveToGraph(XWave, YWave)
string xwave
string ywave
variable yrow = dimsize($ywave,1)
variable i=0
do
	AppendToGraph $ywave[*][i] vs $xwave
	i += 1
while (i<yrow)

END

