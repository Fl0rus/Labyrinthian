Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
$Global:FrmSizeX = 640
$Global:FrmSizeY = 480
#Initial labyrint width & Height
$global:SizeX = 50
$global:SizeY= 40
#Global brushes
$global:brushw = New-Object Drawing.SolidBrush White
$global:brushbl = New-Object Drawing.SolidBrush Black
$global:brushg = New-Object Drawing.SolidBrush Green
$global:brushdb = New-Object Drawing.SolidBrush DarkBlue
$global:brushfin = New-Object Drawing.SolidBrush Purple
$global:brushbc = New-Object Drawing.SolidBrush Lavender
$global:brushr = New-Object Drawing.SolidBrush Tomato
$global:brushlc = New-Object Drawing.SolidBrush WhiteSmoke
$global:brushPlayer = New-Object Drawing.SolidBrush Red

#Global settings
$Global:DrawWhileBuilding = $false
$Global:DrawWhileSearching = $true
$global:PlayerPause = 10
$global:ClearLabBeforeSearching = $true
$global:Randomness = 3
$global:SolveAlgoritms =@('Straight Random','Straight Fixed','Random','Fixed','Radar')
$global:SolveAlgoritm = 'Straight Random'
$global:gaps = $false
$global:randomgaps = 0
$global:moves = 0


Clear-Host
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = "$Global:FrmSizeX,$Global:FrmSizeY"
$FrmLabyrinthian.text                       = "Labyrinth"
$FrmLabyrinthian.TopMost                    = $true
$FrmLabyrinthian.BackColor                  = '#808080'
$FrmLabyrinthian.StartPosition = 'Manual'
$FrmLabyrinthian.Location                    = New-Object System.Drawing.Point(0,0)
#$FrmLabyrinthian.TransparencyKey = "#808080"

$BtnCreateLabyrinth                         = New-Object system.Windows.Forms.Button
$BtnCreateLabyrinth.text                    = "Create"
$BtnCreateLabyrinth.width                   = 75
$BtnCreateLabyrinth.height                  = 25
$BtnCreateLabyrinth.location                = New-Object System.Drawing.Point(0,0)
$BtnCreateLabyrinth.Font                    = 'Microsoft Sans Serif,10'
$BtnCreateLabyrinth.BackColor               = "#999999"

$BtnSolveLabyrinth                         = New-Object system.Windows.Forms.Button
$BtnSolveLabyrinth.text                    = "Solve"
$BtnSolveLabyrinth.width                   = 75
$BtnSolveLabyrinth.height                  = 25
$BtnSolveLabyrinth.location                = New-Object System.Drawing.Point(75,0)
$BtnSolveLabyrinth.Font                    = 'Microsoft Sans Serif,10'
$BtnSolveLabyrinth.BackColor               = "#999999"
$BtnSolveLabyrinth.Enabled = $false

$BtnSettings                         = New-Object system.Windows.Forms.Button
$BtnSettings.text                    = "Settings"
$BtnSettings.width                   = 75
$BtnSettings.height                  = 25
$BtnSettings.location                = New-Object System.Drawing.Point(150,0)
$BtnSettings.Font                    = 'Microsoft Sans Serif,10'
$BtnSettings.BackColor               = "#999999"
$BtnSettings.Enabled = $true

$prgCalc = New-object System.Windows.Forms.ProgressBar
$prgCalc.Width = $FrmLabyrinthian.width-175
$prgCalc.Height = 20
$prgcalc.value = 0
$prgcalc.Location = New-Object System.Drawing.Point(275,0)
$prgCalc.Text = $global:SolveAlgoritm

$lblCalc = New-Object System.Windows.Forms.Label
$lblCalc.Width = 50
$lblCalc.Height = 25
$lblCalc.TextAlign = 32 #MiddleCenter
$lblCalc.Location = New-Object System.Drawing.Point(225,0)
$lblCalc.Text = $global:SolveAlgoritm
#$lblCalc.BackColor = 'Transparant'

#settings controls
$chkDrawLab = New-Object System.Windows.Forms.Checkbox
$chkDrawLab.AutoSize = $true
$chkDrawLab.Width = 25
$chkDrawLab.Height = 25
$chkDrawLab.Text = "Draw while building"
$chkDrawLab.Location = New-Object System.Drawing.Point(10,10)

$chkDrawSol = New-Object System.Windows.Forms.Checkbox
$chkDrawSol.AutoSize = $true
$chkDrawSol.Width = 25
$chkDrawSol.Height = 25
$chkDrawSol.Text = "Draw while solving"
$chkDrawSol.Location = New-Object System.Drawing.Point(10,30)

$sldWidth = New-Object System.Windows.Forms.Trackbar
$sldwidth.AutoSize = $true
$sldwidth.Text = "Width"
$sldWidth.width = 200
$sldWidth.Height = 30
$sldWidth.location = New-Object System.Drawing.Point(10,60)
$sldwidth.Maximum = 200
$sldWidth.Minimum = 5
$sldwidth.AutoSize = $True
$sldwidth.TickStyle = 2
$sldwidth.TickFrequency = 10
$sldWidth.Orientation = 0

$sldwidthNum = New-Object System.Windows.Forms.NumericUpDown
$sldwidthNum.width = 45
$sldwidthNum.Height = 30
$sldwidthNum.Location = New-Object System.Drawing.Point(210,60)
$sldwidthNum.Maximum = 200
$sldwidthNum.Minimum = 5

$lblWidth = New-Object System.Windows.Forms.Label
$lblWidth.width = 50
$lblWidth.height =30
$lblWidth.location = New-object System.Drawing.Point(260,60)
$lblWidth.Text = "Width"

$sldHeight = New-Object System.Windows.Forms.Trackbar
$sldHeight.AutoSize = $true
$sldHeight.Text = "Height"
$sldHeight.width = 200
$sldHeight.Height = 30
$sldHeight.location = New-Object System.Drawing.Point(10,100)
$sldHeight.Maximum = 150
$sldHeight.Minimum = 5
$sldHeight.TickFrequency = 10
$sldHeight.TickStyle = 2
$sldHeight.Orientation = 0

$sldHeightNum = New-Object System.Windows.Forms.NumericUpDown
$sldHeightNum.width = 45
$sldHeightNum.Height = 25
$sldHeightNum.Location = New-Object System.Drawing.Point(210,100)
$sldHeightNum.Maximum = 150
$sldHeightNum.Minimum =5

$lblHeight = New-Object System.Windows.Forms.Label
$lblHeight.width = 50
$lblHeight.height =30
$lblHeight.location = New-object System.Drawing.Point(260,100)
$lblHeight.Text = "Height"

$sldSpeed = New-Object System.Windows.Forms.Trackbar
$sldSpeed.AutoSize = $true
$sldSpeed.Text = "Speed"
$sldSpeed.width = 200
$sldSpeed.Height = 30
$sldSpeed.location = New-Object System.Drawing.Point(10,150)
$sldSpeed.Maximum = 250
$sldSpeed.Minimum = 0
$sldSpeed.TickFrequency = 10
$sldSpeed.TickStyle = 2
$sldSpeed.Orientation = 0

$sldSpeedNum = New-Object System.Windows.Forms.NumericUpDown
$sldSpeedNum.width = 45
$sldSpeedNum.Height = 25
$sldSpeedNum.Location = New-Object System.Drawing.Point(210,150)
$sldSpeedNum.Maximum = 250
$sldSpeedNum.Minimum =0

$lblSpeed = New-Object System.Windows.Forms.Label
$lblSpeed.width = 50
$lblSpeed.height =30
$lblSpeed.location = New-object System.Drawing.Point(260,150)
$lblSpeed.Text = "Speed"

$sldRandom = New-Object System.Windows.Forms.Trackbar
$sldRandom.AutoSize = $true
$sldRandom.Text = "Randomness"
$sldRandom.width = 200
$sldRandom.Height = 30
$sldRandom.location = New-Object System.Drawing.Point(10,200)
$sldRandom.Maximum = 100
$sldRandom.Minimum = 1
$sldRandom.TickFrequency = 10
$sldRandom.TickStyle = 2
$sldRandom.Orientation = 0

$sldRandomNum = New-Object System.Windows.Forms.NumericUpDown
$sldRandomNum.width = 45
$sldRandomNum.Height = 25
$sldRandomNum.Location = New-Object System.Drawing.Point(210,200)
$sldRandomNum.Maximum = 100
$sldRandomNum.Minimum = 1

$lblRandom = New-Object System.Windows.Forms.Label
$lblRandom.width = 50
$lblRandom.height =30
$lblRandom.location = New-object System.Drawing.Point(260,200)
$lblRandom.Text = "Randomness"

$lblSolveAlgoritm = New-Object System.Windows.Forms.Label
$lblSolveAlgoritm.AutoSize = $true
$lblSolveAlgoritm.width = 70
$lblSolveAlgoritm.height = 30
$lblSolveAlgoritm.TextAlign = 16 #MiddleLeft
$lblSolveAlgoritm.location = New-object System.Drawing.Point(10,250)
$lblSolveAlgoritm.Text = "Solve Algoritm"

$cmbSolveAlgoritm = New-Object System.Windows.Forms.ComboBox
$cmbSolveAlgoritm.Width = 125
$cmbSolveAlgoritm.Height = 30
$cmbSolveAlgoritm.AutoSize = $true
$cmbSolveAlgoritm.DropDownStyle = 2
$cmbSolveAlgoritm.AutoCompleteMode  = 0
$cmbSolveAlgoritm.location = New-object System.Drawing.Point(90,250)
$cmbSolveAlgoritm.DataSource = $global:SolveAlgoritms
$cmbSolveAlgoritm.SelectedItem = 0

$btnOk = New-Object System.Windows.Forms.Button
$btnOk.Height = 30
$btnok.width = 100
$btnOk.AutoSize = $true
$btnOk.Location = New-object System.Drawing.Point(10,360)
$btnOk.Text = "Ok"

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Width = 100
$btnApply.Height = 30
$btnApply.AutoSize = $true
$btnApply.Location = New-object System.Drawing.Point(150,360)
$btnApply.Text = "Apply"

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Width = 100
$btnCancel.Height = 30
$btnCancel.AutoSize = $true
$btnCancel.Location = New-object System.Drawing.Point(290,360)
$btnCancel.Text = "Cancel"

$FrmLabyrinthian.controls.AddRange(@(
    $BtnCreateLabyrinth,$BtnSolveLabyrinth,$BtnSettings,$prgCalc,$lblCalc
))
$FrmLabyrinthianSettings = New-Object system.Windows.Forms.Form
$FrmLabyrinthianSettings.BackColor                  = '#d3d3d3'
$FrmLabyrinthianSettings.StartPosition              = 'Manual'
$FrmLabyrinthianSettings.controls.AddRange(@(
    $chkDrawLab,$chkDrawSol,
    $sldWidth,$sldwidthNum,$lblWidth,
    $sldHeight,$sldHeightNum,$lblHeight,
    $sldSpeed,$sldSpeedNum,$lblSpeed,
    $sldRandom,$sldRandomNum,$lblRandom,
    $lblSolveAlgoritm,$cmbSolveAlgoritm,
    $btnok,$btnApply,$btnCancel
))

Function ShowSettings(){
    $FrmLabyrinthianSettings.ClientSize                 = "400,400"
    $FrmLabyrinthianSettings.text                       = "Labyrinth settings"
    $FrmLabyrinthianSettings.TopMost                    = $true

    $chkDrawSol.Checked = $Global:DrawWhileSearching
    $chkDrawLab.Checked = $Global:DrawWhileBuilding

    $sldWidth.Value = $global:SizeX
    $sldwidthNum.value= $global:SizeX
    $sldHeight.Value = $global:SizeY
    $sldHeightNum.value = $global:SizeY
    $sldSpeed.Value = $global:PlayerPause
    $sldSpeedNum.value = $global:PlayerPause
    $sldRandom.Value = $global:Randomness
    $sldRandomNum.Value = $global:Randomness
    $cmbSolveAlgoritm.SelectedItem = $global:SolveAlgoritmIndex
    $FrmLabyrinthianSettings.StartPosition = 'CenterParent'
    $FrmLabyrinthianSettings.ShowDialog()
}
Function SaveSettings {
    $Global:DrawWhileBuilding = $chkDrawLab.Checked
    $Global:DrawWhileSearching = $chkDrawSol.Checked
    $global:PlayerPause = $sldSpeed.Value
    If ($global:SizeX -ne $sldWidth.Value -or $global:SizeY -ne $sldHeight.Value) {
        $global:SizeX = $sldWidth.Value
        $global:SizeY = $sldHeight.Value
        $BtnSolveLabyrinth.Enabled=$false
    }
    $global:Randomness = $sldRandom.Value
    If ($global:SolveAlgoritm -ne $cmbSolveAlgoritm.SelectedValue) {
        $global:SolveAlgoritm = $cmbSolveAlgoritm.SelectedValue
        $global:SolveAlgoritmIndex = $cmbSolveAlgoritm.SelectedItem
        $lblCalc.Text = $global:SolveAlgoritm
        $global:moves = 0
    }
}

Function CreateLabyrinth () {
    #Fill labyrinth matrix array
    #ClearLabyrinth
    #Create Labyrinth
    $x = Get-Random -Minimum 1 -Maximum ($global:SizeX-1)
    $y = Get-Random -Minimum 1 -Maximum ($global:SizeY-1)
    $Global:Start=@($x,$y)
    $global:labyrinth[$x][$y] = 256 #start
    $pointer=0
    $progress=0
    $pointermax=0
    $prgcalc.Minimum=0
    $prgCalc.Maximum=$global:SizeX*$global:SizeY
    [System.Collections.ArrayList]$moved = @()
    [System.Collections.ArrayList]$endpoints = @()
    If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
    $previousmove = 0
    While($pointer -ge 0) {
        [System.Collections.ArrayList]$posDir = @()
        If ($y -gt 0) {
            If ($global:labyrinth[$x][$y-1] -eq 0){
                $posDir.Add(@($global:labyrinth[$x][$y-1],$x,($y-1),1)) #Up
            }
        } #up
        If ($y -lt ( $global:SizeY-1)) {
            If ($global:labyrinth[$x][$y+1] -eq 0 ) {
                $posDir.Add(@(($global:labyrinth[$x][$y+1]),$x,($y+1),2)) #Down
            }
        } #down
        If ($x -gt 0) {
            If ($global:labyrinth[$x-1][$y] -eq 0) {
                $posDir.Add(@(($global:labyrinth[$x-1][$y]),($x-1),$y,4)) #left
            }
        }  #left
        If ($x -lt ( $global:SizeX-1)) {
            If($global:labyrinth[$x+1][$y] -eq 0) {
                $posDir.Add(@(($global:labyrinth[$x+1][$y]),($x+1),$y,8))#right
            }
        } #right
        #Random direction
        $numofposdir = $posdir.Count
        If ($numofposdir -ne 0) {
            $movedetection = $posdir | Where-Object {$_[3] -eq $previousmove}
            If ($null -eq $movedetection) {
                $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
            } Elseif ((Get-Random -Minimum 0 -Maximum $global:Randomness) -eq 0) {
                $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
            }
            $previousmove = $movedetection[3]
            #deur gevonden
            $global:labyrinth[$x][$y] += $movedetection[3]
            $moved.Add(@($x,$y))
            $pointer=$moved.count
            $x=$movedetection[1]
            $y=$movedetection[2]
            #Deur naar de andere kant!
            Switch($movedetection[3]){
                1 {$value=2}
                2 {$value=1}
                4 {$value=8}
                8 {$value=4}
            }
            $global:labyrinth[$x][$y] += $value
            #Write-host "Step $pointer = Moved to $x $y"
            $prgCalc.Value = $progress
            If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
            $progress++
        } ElseIf ($pointer -gt $pointermax) {
            $pointermax=$pointer+1
            $endpoints.Add(@($x,$y))
            If (($x -lt $global:SizeX) -and ($x -gt 0) -and ($y -gt 0) -and ($y -lt $global:SizeY) -and $global:gaps){
                $global:labyrinth[$x][$y] += $previousmove
            }
            If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
        } Else {
            $pointer--
            $x = $moved[$pointer][0]
            $y = $moved[$pointer][1]
            #Write-host "Step $pointer = Niewe scan op punt $x $y"
        }
    }
    $BtnSolveLabyrinth.Enabled = $true
    If($global:randomgaps -gt 0) {
        For($i=0;$i -le $randomgaps;$i++) {
            $x = Get-Random -Minimum 1 -Maximum ($global:SizeX-1)
            $y = Get-Random -Minimum 1 -Maximum ($global:SizeY-1)
            $global:labyrinth[$x][$y]+= (15 - $global:labyrinth[$x][$y] -band 15)
        }
    }
    $endpoint=$endpoints[(Get-Random -Minimum 0 -Maximum $endpoints.Count)]
    $global:labyrinth[$endpoint[0]][$endpoint[1]] = 512 #finish
    $global:Finish=@($endpoint[0],$endpoint[1])
    If($Global:DrawWhileBuilding){DrawExplorer -x $endpoint[0] -y $endpoint[1]}
    $Global:FirstSolve = $true
}
Function InitLabyrinth(){
    #Draw stuff prep
    [System.Collections.ArrayList]$global:labyrinth = @()
    #$Size =  $global:SizeX *  $global:SizeY
    For($i=0;$i -lt $global:SizeX;$i++) {
        $global:labyrinth += ,(@()) 
        For ($o=0;$o -lt $global:SizeY;$o++) {
            $global:labyrinth[$i] += 0
        }
    }
    $global:Graphics = $FrmLabyrinthian.CreateGraphics()
    $prgcalc.width = $FrmLabyrinthian.Width-225
}
Function ClearLabyrinth () {
    #$FrmLabyrinthian.Refresh()
    $global:brushb = New-Object Drawing.SolidBrush Gray
    $global:Graphics = $FrmLabyrinthian.CreateGraphics()
    $global:Graphics.FillRectangle($global:brushb,0,0,$FrmLabyrinthian.Width,$FrmLabyrinthian.Height)
    #$FrmLabyrinthian.Update()
}
Function DrawExplorer {
    Param (
        $x,
        $y,
        [ValidateSet("NoDraw", "Draw","Raider")]$marker = 'Draw' 
    )
    $offsetx = 25
    $offsety = 25
    $ScaleX = (($FrmLabyrinthian.Width-($offsetx*2))/ $global:SizeX)
    $ScaleY= ((($FrmLabyrinthian.Height - 25)-($offsety*2))/ $global:SizeY)
    $RoomScaleX = 0.75
    $RoomScaleY = 0.75
    $RoomSizeX = $ScaleX * $RoomScaleX
    $RoomsizeY = $Scaley * $RoomScaleY
    $RoomScaleXX =1-$RoomScaleX
    $RoomScaleYY =1-$RoomScaleY
    If($marker -eq 'Nodraw') {
        $global:Graphics.FillRectangle($global:brushb,($x*$scalex)+$offsetx,($y*$scaleY+0.25)+$offsety,($RoomSizeX),($RoomsizeY))
    }Else{
        If ((($global:labyrinth[$x][$y] -band 240) -ne 0) -and (($global:labyrinth[$x][$y] -band 240) -ne 240)) {
            Switch($global:labyrinth[$x][$y]) {
                {(16 -band $_) -eq 16} {
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,((($y)-$RoomScaleYY)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(32 -band $_) -eq 32} {
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,((($y)+$RoomScaleYY)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(64 -band $_) -eq 64} {
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushr,((($x)-$RoomScaleXX)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(128 -band $_) -eq 128} {
                    $global:Graphics.FillRectangle($global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushr,((($x)+$RoomScaleXX)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
            }
        } Else {
            Switch($global:labyrinth[$x][$y]) {
                0 {
                    $global:Graphics.FillRectangle($global:brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                }
                {(1 -band $_) -eq 1} {
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,(($y-0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(2 -band $_) -eq 2} {
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(4 -band $_) -eq 4} {
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushw,(($x-0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(8 -band $_) -eq 8} {
                    $global:Graphics.FillRectangle($global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $global:Graphics.FillRectangle($global:brushw,(($x+0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
            }
        }
        Switch($global:labyrinth[$x][$y]) {
            #Breadcrumbs
            {(240 -band $_) -eq 240} {
                $global:Graphics.FillRectangle($global:brushlc,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #Start
            {(256 -band $_) -eq 256} {
                $global:Graphics.FillRectangle($global:brushg,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #Finish
            {(512 -band $_) -eq 512} {
                $global:Graphics.FillRectangle($global:brushfin,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #DeadEnds
            {(1024 -band $_) -eq 1024} {
                $global:Graphics.FillRectangle($global:brushPlayer,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:labyrinth[$x][$y]-= 1024
            }
        }
    }
    [System.Windows.Forms.Application]::DoEvents()
}
Function DrawLabyrinth {    
    Param ()
    For($y=0;$y -lt  $global:SizeY;$y++) { 
        For($x=0;$x -lt  $global:SizeX;$x++) {
            DrawExplorer -x $x -y $y
        }
    }   
    $FrmLabyrinthian.Update()
}
Function SolveLabyrinth {
    Param ()
    #Clear breadcrumbs
    For($i=0;$i -lt  $global:SizeX;$i++) {
        For ($o=0;$o -lt  $global:SizeY;$o++) {
            $breadcrumb = ($global:labyrinth[$i][$o]) -band 240
            If($breadcrumb -ne 0) {
                $global:labyrinth[$i][$o]-=$breadcrumb #remove breadcrumbs
            }
        }
    }
    #ClearLabyrinth
    If ($global:ClearLabBeforeSearching -and -not $Global:FirstSolve) {DrawLabyrinth}
    $Global:FirstSolve = $false
    #Write-host "$global:start $global:finish"
    $x =$global:start[0]
    $y =$global:start[1]
    $Progress=1
    $progressmax=1
    $global:moves=0
    $maxmoves=($global:SizeX*$global:SizeY)
    $prgCalc.Value =$global:moves
    $prgCalc.Maximum =$maxmoves
    [System.Collections.ArrayList]$moved=@()
    While (($global:labyrinth[$x][$y] -band 512) -ne 512) {
        [System.Collections.ArrayList]$posDir = @()
        If (($global:labyrinth[$x][$y] -band 1) -eq 1 -and (($global:labyrinth[$x][($y-1)] -band 240) -eq 0)) {$posdir.add(@($x,($y-1),16))}
        If (($global:labyrinth[$x][$y] -band 2) -eq 2 -and (($global:labyrinth[$x][($y+1)] -band 240) -eq 0)) {$posdir.add(@($x,($y+1),32))}
        If (($global:labyrinth[$x][$y] -band 4) -eq 4 -and (($global:labyrinth[($x-1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x-1),$y,64))}
        If (($global:labyrinth[$x][$y] -band 8) -eq 8 -and (($global:labyrinth[($x+1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x+1),$y,128))}
        $numofposdir = $posdir.Count
        If($global:moves -lt $maxmoves) {
            $global:moves++
            $prgCalc.Value = $global:moves
        }
        If ($numofposdir -ne 0) {
            #Search Algoritms
            $Algoritm = ($global:SolveAlgoritm -split ' ')[0]
            If ($Algoritm -eq 'Straight') {
                $checkdir = $posdir | Where-Object {$_[2] -eq $Previousdirection}
                If ($null -ne $checkdir) {
                    $movechoice = $checkdir
                    $direction = $Previousdirection
                } Else {
                    $Algoritm = ($global:SolveAlgoritm -split ' ')[1]
                }
            }
            Switch ($Algoritm) {
                'Straight' {}
                'Random' {
                    $movechoice = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    $direction = $movechoice[2]
                }
                'Fixed' {
                    $movechoice = $posDir[0]
                    $direction = $movechoice[2]
                }
                'Radar' {
                    #Radar = Look over the hedges to see which direction
                    $difmin = $maxmoves
                    For ($i=0;$i -lt $numofposdir;$i++) {
                        $difx = [math]::abs(($posdir[$i])[0] - $global:Finish[0])
                        $dify = [math]::abs(($posdir[$i])[1] - $global:Finish[1])
                        $dif = $difx+$dify
                        If($dif -lt $difmin) {
                            $difmin = $dif
                            $choice = $i
                        }
                    }
                    #Write-Host "$difx - $dify - $dif - $difmin"
                    $movechoice = $posDir[$choice]
                    $direction = $movechoice[2]
                }
            }
            $global:labyrinth[$x][$y]-=($global:labyrinth[$x][$y] -band 240)
            $global:labyrinth[$x][$y]+=$direction
            $Previousdirection = $direction
            If($Global:DrawWhileSearching){
                $global:labyrinth[$x][$y]+= 1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $global:PlayerPause
                DrawExplorer -x $x -y $y
            }
            $x = $movechoice[0]
            $y = $movechoice[1]
            $global:labyrinth[$x][$y]+=240
            $moved.Add(@($x,$y))
            $progress=$moved.count-1
            #Write-host "New route: " -NoNewline
        } ElseIf($progress -gt $progressmax) {
            $progressmax=$Progress+1
            $global:labyrinth[$x][$y]+= 240 - ($global:labyrinth[$x][$y] -band 240)
            If($Global:DrawWhileSearching){
                $global:labyrinth[$x][$y]+= 1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $global:PlayerPause
                DrawExplorer -x $x -y $y
            }
            #Write-host "Deadend at $x $y"
        } Else {
            $Progress--
            $global:moves--
            If (($global:labyrinth[$x][$y] -band 240) -ne 240) {
                $global:labyrinth[$x][$y]+= 240 - ($global:labyrinth[$x][$y] -band 240)
                If($Global:DrawWhileSearching){
                    $global:labyrinth[$x][$y]+= 1024
                    DrawExplorer -x $x -y $y
                    Start-Sleep -Milliseconds $global:PlayerPause
                    DrawExplorer -x $x -y $y
                }
                }
            $x = $moved[$progress][0]
            $y = $moved[$progress][1]
            #Write-host "Backtrack: " -NoNewline
            }
        #Write-host "$x $y"
    }
    #$global:labyrinth[$x][$y]-=64
    $prgCalc.Value = $maxmoves
    If(-not $Global:DrawWhileSearching){DrawLabyrinth}
    Write-Host "$global:SolveAlgoritm - moves: $global:moves"
}
function ChangeSizeX () {
    $sldwidthNum.Value = $sldWidth.Value
}
function ChangeSizeY () {
    $sldHeightNum.Value = $sldHeight.Value
 }
function ChangeSizeXNum () {
    $sldWidth.Value = $sldWidthNum.Value 
}
function ChangeSizeYNum () {
    $sldHeight.Value = $sldHeightNum.Value 
}
function ChangeSpeed () {
    $sldSpeedNum.Value = $sldSpeed.Value
}
function ChangeSpeedNum () {
    $sldSpeed.Value = $sldSpeedNum.Value 
}
function ChangeRandom () {
    $sldRandomNum.Value = $sldRandom.Value
}
function ChangeRandomNum () {
    $sldRandom.Value = $sldRandomNum.Value 
}

$BtnCreateLabyrinth.Add_Click({
    InitLabyrinth
    ClearLabyrinth
    CreateLabyrinth
    If(-not $Global:DrawWhilebuilding){DrawLabyrinth}
})
$BtnSolveLabyrinth.Add_Click({ SolveLabyrinth })
$BtnSettings.Add_Click({ ShowSettings })
$sldWidth.Add_Scroll({ ChangeSizeX })
$sldwidthNum.Add_ValueChanged({ChangeSizeXNum})
$sldHeight.Add_Scroll({ ChangeSizeY })
$sldHeightNum.Add_ValueChanged({ChangeSizeYNum})
$sldSpeed.Add_Scroll({ ChangeSpeed })
$sldSpeedNum.Add_ValueChanged({ChangeSpeedNum})
$sldRandom.Add_Scroll({ ChangeRandom })
$sldRandomNum.Add_ValueChanged({ChangeRandomNum})

$FrmLabyrinthian.Add_ResizeEnd({ClearLabyrinth;DrawLabyrinth;$prgCalc.width=$FrmLabyrinthian.width-225})
$FrmLabyrinthian.Add_SizeChanged({
    If ($FrmLabyrinthian.WindowState -ne 'Normal' -or $global:PreviousState -ne 'Normal') {
        ClearLabyrinth;DrawLabyrinth;$prgCalc.width=$FrmLabyrinthian.width-225
        $global:PreviousState = $FrmLabyrinthian.WindowState
    }
})
$btnOk.Add_Click({
    SaveSettings
    $FrmLabyrinthianSettings.Close()
})
$btnApply.Add_Click({
    SaveSettings
})
$btnCancel.Add_Click({
    $FrmLabyrinthianSettings.Close()
})
$lblCalc.Add_Click({
    $lblCalc.Text = $global:moves
    Start-Sleep -Milliseconds 500
    $lblCalc.Text = $global:SolveAlgoritm
})
$FrmLabyrinthian.Add_Shown({
    InitLabyrinth
    CreateLabyrinth
    If(-not $Global:DrawWhileBuilding){DrawLabyrinth}
})
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)