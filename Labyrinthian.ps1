Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
Clear-Host

$Global:FrmSizeX = 640
$Global:FrmSizeY = 480
#Initial labyrint width & Height
$global:SizeX = 40
$global:SizeY= 30
#Global brushes
$global:brushw = New-Object Drawing.SolidBrush White
$global:brushbl = New-Object Drawing.SolidBrush Black
$global:brushg = New-Object Drawing.SolidBrush Green
$global:brushdb = New-Object Drawing.SolidBrush DarkBlue
$global:brushfin = New-Object Drawing.SolidBrush Purple
$global:brushbc = New-Object Drawing.SolidBrush Lavender
$global:brushr = New-Object Drawing.SolidBrush Tomato
$global:brushlc = New-Object Drawing.SolidBrush WhiteSmoke
$global:brushPlayer = New-Object Drawing.SolidBrush Fuchsia

#Global timer
$global:Stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch
#Global settings Create
$Global:DrawWhileBuilding = $true
$global:DrawWhileSolving = $true
$global:BuildPause= 3
$global:Randomness = 3
$global:CreateAlgoritms =@('Depth-First','Prim','Wilson','Aldous-Broder','Eller')
$global:CreateAlgoritm = 'Prim'
$global:Startpoints = @('Random','Center','Top-Left','Top-Right','Bottom-Right','Bottom-Left')
$global:Startpoint = 'Random'
$Global:Finishpoints = @('Endpoint Random','Endpoint Far','Endpoint Last','Endpoint First','Center','Random','Top-Left','Top-Right','Bottom-Right','Bottom-Left')
$global:Finishpoint = 'Endpoint Far'
$global:Gaps = $false

#Global settings Solve
$global:PlayerPause = 2
$global:DeadEndFilling = $true
$global:SolveAlgoritms =@('Radar','Follow-Wall','Random','Fixed')
$global:SolveAlgoritm = 'Radar'
$global:ClearLabBeforeSolving = $true
$global:maxmoves=($global:SizeX*$global:SizeY)
$global:moves = 0

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

$timTimer = New-object System.Windows.Forms.Timer
$timTimer.Enabled = $false
$timTimer.Interval = 500

##########################
#Create Settings controls #
##########################
$chkDrawLab = New-Object System.Windows.Forms.Checkbox
$chkDrawLab.AutoSize = $true
$chkDrawLab.Width = 25
$chkDrawLab.Height = 25
$chkDrawLab.Text = "Draw while building"
$chkDrawLab.Location = New-Object System.Drawing.Point(10,10)

$lblCreateAlgoritm = New-Object System.Windows.Forms.Label
$lblCreateAlgoritm.AutoSize = $true
$lblCreateAlgoritm.width = 70
$lblCreateAlgoritm.height = 30
$lblCreateAlgoritm.TextAlign = 16 #MiddleLeft
$lblCreateAlgoritm.location = New-object System.Drawing.Point(10,35)
$lblCreateAlgoritm.Text = "Create Algoritm"

$cmbCreateAlgoritm = New-Object System.Windows.Forms.ComboBox
$cmbCreateAlgoritm.Width = 125
$cmbCreateAlgoritm.Height = 30
$cmbCreateAlgoritm.AutoSize = $true
$cmbCreateAlgoritm.DropDownStyle = 2
$cmbCreateAlgoritm.AutoCompleteMode  = 0
$cmbCreateAlgoritm.location = New-object System.Drawing.Point(100,35)
For ($i=0;$i -lt $global:CreateAlgoritms.count;$i++) {
    [void]$cmbCreateAlgoritm.items.Add($global:CreateAlgoritms[$i])
    If ($global:CreateAlgoritms[$i] -eq $global:CreateAlgoritm) {$global:CreateAlgoritmIndex =$i}
}
$cmbCreateAlgoritm.SelectedIndex= $global:CreateAlgoritmIndex

$lblStartpoint = New-Object System.Windows.Forms.Label
$lblStartpoint.AutoSize = $true
$lblStartpoint.width = 70
$lblStartpoint.height = 30
$lblStartpoint.TextAlign = 16 #MiddleLeft
$lblStartpoint.location = New-object System.Drawing.Point(10,70)
$lblStartpoint.Text = "Start Point"

$cmbStartpoint = New-Object System.Windows.Forms.ComboBox
$cmbStartpoint.Width = 125
$cmbStartpoint.Height = 30
$cmbStartpoint.AutoSize = $true
$cmbStartpoint.DropDownStyle = 2
$cmbStartpoint.AutoCompleteMode  = 0
$cmbStartpoint.location = New-object System.Drawing.Point(100,70)
For ($i=0;$i -lt $global:Startpoints.count;$i++) {
    [void]$cmbStartpoint.items.Add($global:Startpoints[$i])
    If ($global:Startpoints[$i] -eq $global:startpoint) {$global:StartpointIndex =$i}
}
$cmbStartpoint.SelectedIndex= $global:StartpointIndex

$lblFinishpoint = New-Object System.Windows.Forms.Label
$lblFinishpoint.AutoSize = $true
$lblFinishpoint.width = 70
$lblFinishpoint.height = 30
$lblFinishpoint.TextAlign = 16 #MiddleLeft
$lblFinishpoint.location = New-object System.Drawing.Point(10,100)
$lblFinishpoint.Text = "Finish Point"

$cmbFinishpoint = New-Object System.Windows.Forms.ComboBox
$cmbFinishpoint.Width = 125
$cmbFinishpoint.Height = 30
$cmbFinishpoint.AutoSize = $true
$cmbFinishpoint.DropDownStyle = 2
$cmbFinishpoint.AutoCompleteMode  = 0
$cmbFinishpoint.location = New-object System.Drawing.Point(100,100)
For ($i=0;$i -lt $global:Finishpoints.count;$i++) {
    [void]$cmbFinishpoint.items.Add($global:Finishpoints[$i])
    If ($global:Finishpoints[$i] -eq $global:Finishpoint) {$global:FinishpointIndex =$i}
}
$cmbFinishpoint.SelectedIndex= $global:FinishpointIndex

$sldWidth = New-Object System.Windows.Forms.Trackbar
$sldwidth.AutoSize = $true
$sldwidth.Text = "Width"
$sldWidth.width = 200
$sldWidth.Height = 30
$sldWidth.location = New-Object System.Drawing.Point(10,145)
$sldwidth.Maximum = 200
$sldWidth.Minimum = 5
$sldwidth.AutoSize = $True
$sldwidth.TickStyle = 2
$sldwidth.TickFrequency = 10
$sldWidth.Orientation = 0

$sldwidthNum = New-Object System.Windows.Forms.NumericUpDown
$sldwidthNum.width = 45
$sldwidthNum.Height = 30
$sldwidthNum.Location = New-Object System.Drawing.Point(210,145)
$sldwidthNum.Maximum = 200
$sldwidthNum.Minimum = 5

$lblWidth = New-Object System.Windows.Forms.Label
$lblWidth.width = 50
$lblWidth.height =30
$lblWidth.location = New-object System.Drawing.Point(260,145)
$lblWidth.Text = "Width"

$sldHeight = New-Object System.Windows.Forms.Trackbar
$sldHeight.AutoSize = $true
$sldHeight.Text = "Height"
$sldHeight.width = 200
$sldHeight.Height = 30
$sldHeight.location = New-Object System.Drawing.Point(10,200)
$sldHeight.Maximum = 150
$sldHeight.Minimum = 5
$sldHeight.TickFrequency = 10
$sldHeight.TickStyle = 2
$sldHeight.Orientation = 0

$sldHeightNum = New-Object System.Windows.Forms.NumericUpDown
$sldHeightNum.width = 45
$sldHeightNum.Height = 25
$sldHeightNum.Location = New-Object System.Drawing.Point(210,200)
$sldHeightNum.Maximum = 150
$sldHeightNum.Minimum =5

$lblHeight = New-Object System.Windows.Forms.Label
$lblHeight.width = 50
$lblHeight.height =30
$lblHeight.location = New-object System.Drawing.Point(260,200)
$lblHeight.Text = "Height"

$lblRandom = New-Object System.Windows.Forms.Label
$lblRandom.width = 80
$lblRandom.height = 30
$lblRandom.location = New-object System.Drawing.Point(10,245)
$lblRandom.Text = "Randomness (Depth-First)"

$sldRandom = New-Object System.Windows.Forms.Trackbar
$sldRandom.AutoSize = $true
$sldRandom.Text = "Randomness (Depth-First)"
$sldRandom.width = 200
$sldRandom.Height = 30
$sldRandom.location = New-Object System.Drawing.Point(90,245)
$sldRandom.Maximum = 100
$sldRandom.Minimum = 1
$sldRandom.TickFrequency = 10
$sldRandom.TickStyle = 2
$sldRandom.Orientation = 0

$sldRandomNum = New-Object System.Windows.Forms.NumericUpDown
$sldRandomNum.width = 45
$sldRandomNum.Height = 25
$sldRandomNum.Location = New-Object System.Drawing.Point(300,245)
$sldRandomNum.Maximum = 100
$sldRandomNum.Minimum = 1

$lblBuildSpeed = New-Object System.Windows.Forms.Label
$lblBuildSpeed.width = 50
$lblBuildSpeed.height = 30
$lblBuildSpeed.location = New-object System.Drawing.Point(10,290)
$lblBuildSpeed.Text = "Build Speed"

$sldBuildSpeed = New-Object System.Windows.Forms.Trackbar
$sldBuildSpeed.AutoSize = $true
$sldBuildSpeed.Text = "Build Speed"
$sldBuildSpeed.width = 200
$sldBuildSpeed.Height = 30
$sldBuildSpeed.location = New-Object System.Drawing.Point(60,290)
$sldBuildSpeed.Maximum = 250
$sldBuildSpeed.Minimum = 0
$sldBuildSpeed.TickFrequency = 10
$sldBuildSpeed.TickStyle = 2
$sldBuildSpeed.Orientation = 0

$sldBuildSpeedNum = New-Object System.Windows.Forms.NumericUpDown
$sldBuildSpeedNum.width = 45
$sldBuildSpeedNum.Height = 25
$sldBuildSpeedNum.Location = New-Object System.Drawing.Point(270,290)
$sldBuildSpeedNum.Maximum = 250
$sldBuildSpeedNum.Minimum =0

##########################
#Solve Settings controls #
##########################
$chkDrawSol = New-Object System.Windows.Forms.Checkbox
$chkDrawSol.AutoSize = $true
$chkDrawSol.Width = 25
$chkDrawSol.Height = 25
$chkDrawSol.Text = "Draw while solving"
$chkDrawSol.Location = New-Object System.Drawing.Point(10,10)

$lblSolveSpeed = New-Object System.Windows.Forms.Label
$lblSolveSpeed.width = 50
$lblSolveSpeed.height =30
$lblSolveSpeed.location = New-object System.Drawing.Point(10,40)
$lblSolveSpeed.Text = "Speed"

$sldSolveSpeed = New-Object System.Windows.Forms.Trackbar
$sldSolveSpeed.AutoSize = $true
$sldSolveSpeed.Text = "Speed"
$sldSolveSpeed.width = 200
$sldSolveSpeed.Height = 30
$sldSolveSpeed.location = New-Object System.Drawing.Point(60,40)
$sldSolveSpeed.Maximum = 250
$sldSolveSpeed.Minimum = 0
$sldSolveSpeed.TickFrequency = 10
$sldSolveSpeed.TickStyle = 2
$sldSolveSpeed.Orientation = 0

$sldSolveSpeedNum = New-Object System.Windows.Forms.NumericUpDown
$sldSolveSpeedNum.width = 45
$sldSolveSpeedNum.Height = 25
$sldSolveSpeedNum.Location = New-Object System.Drawing.Point(270,40)
$sldSolveSpeedNum.Maximum = 250
$sldSolveSpeedNum.Minimum =0

$lblSolveAlgoritm = New-Object System.Windows.Forms.Label
$lblSolveAlgoritm.AutoSize = $true
$lblSolveAlgoritm.width = 70
$lblSolveAlgoritm.height = 30
$lblSolveAlgoritm.TextAlign = 16 #MiddleLeft
$lblSolveAlgoritm.location = New-object System.Drawing.Point(10,85)
$lblSolveAlgoritm.Text = "Solve Algoritm"

$cmbSolveAlgoritm = New-Object System.Windows.Forms.ComboBox
$cmbSolveAlgoritm.Width = 125
$cmbSolveAlgoritm.Height = 30
$cmbSolveAlgoritm.AutoSize = $true
$cmbSolveAlgoritm.DropDownStyle = 2
$cmbSolveAlgoritm.AutoCompleteMode  = 0
$cmbSolveAlgoritm.location = New-object System.Drawing.Point(95,85)
For ($i=0;$i -lt $global:SolveAlgoritms.count;$i++) {
    [void]$cmbSolveAlgoritm.items.Add($global:SolveAlgoritms[$i])
    If ($global:SolveAlgoritms[$i] -eq $global:SolveAlgoritm) {$global:SolveAlgoritmIndex =$i}
}
$cmbSolveAlgoritm.SelectedIndex= $global:SolveAlgoritmIndex

$chkDeadEndFill = New-Object System.Windows.Forms.Checkbox
$chkDeadEndFill.AutoSize = $true
$chkDeadEndFill.Checked = $global:DeadEndFilling
$chkDeadEndFill.Width = 25
$chkDeadEndFill.Height = 25
$chkDeadEndFill.Text = "Dead End Filling"
$chkDeadEndFill.Location = New-Object System.Drawing.Point(10,110)

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
#Tab controls for settings page
$tabSettings = New-Object System.Windows.Forms.TabControl
$tabSettings.Location = New-Object System.Drawing.Point(0,0)
$tabSettings.Appearance =0
$tabSettings.BackColor = '#d3d3d3'
$tabSettings.TabPages.Add('Create')
$tabpageCreate = $tabSettings.Controls[0]
$tabSettings.TabPages.Add('Solve')
$tabpageSolve = $tabSettings.Controls[1]
$tabCreatecontrols = @(
    $chkDrawLab,
    $lblCreateAlgoritm,$cmbCreateAlgoritm,
    $lblStartpoint,$cmbStartpoint,
    $lblFinishpoint,$cmbFinishpoint,
    $sldWidth,$sldwidthNum,$lblWidth,
    $sldHeight,$sldHeightNum,$lblHeight
    $sldRandom,$sldRandomNum,$lblRandom,
    $lblBuildSpeed,$sldBuildSpeed,$sldBuildSpeedNum
)
$tabSolvecontrols = @(
    $chkDrawSol,
    $sldSolveSpeed,$sldSolveSpeedNum,$lblSolveSpeed,
    $lblSolveAlgoritm,$cmbSolveAlgoritm,
    $chkDeadEndFill
)

foreach ($tabcreatecontrol in $tabcreatecontrols) {$tabpageCreate.Controls.Add($tabcreatecontrol)}
foreach ($tabSolvecontrol in $tabSolvecontrols) {$tabpageSolve.Controls.Add($tabSolvecontrol)}

$FrmLabyrinthianSettings = New-Object system.Windows.Forms.Form
$FrmLabyrinthianSettings.BackColor                  = '#d3d3d3'
$FrmLabyrinthianSettings.StartPosition              = 'Manual'
$FrmLabyrinthianSettings.controls.AddRange(@(
    $tabSettings,
    $btnok,$btnApply,$btnCancel
))

Function ShowSettings(){
    $FrmLabyrinthianSettings.ClientSize                 = "400,400"
    $FrmLabyrinthianSettings.text                       = "Labyrinth settings"
    $FrmLabyrinthianSettings.TopMost                    = $true
    $FrmLabyrinthianSettings.FormBorderStyle = 3 #https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.formborderstyle?view=windowsdesktop-6.0
    $FrmLabyrinthianSettings.Showintaskbar = $false
    $FrmLabyrinthianSettings.MinimizeBox = $false
    $FrmLabyrinthianSettings.ControlBox = $false
    
    $tabSettings.Width = $FrmLabyrinthianSettings.Width -16
    $tabSettings.Height = $FrmLabyrinthianSettings.Height -90
    
    $chkDrawSol.Checked = $Global:DrawWhileSolving
    $chkDrawLab.Checked = $Global:DrawWhileBuilding
    $chkDeadEndFill.Checked = $global:DeadEndFilling
    $sldWidth.Value = $global:SizeX
    $sldwidthNum.value= $global:SizeX
    $sldHeight.Value = $global:SizeY
    $sldHeightNum.value = $global:SizeY
    If($global:isCreating -or $global:isSolving) {
        $sldWidth.Enabled = $false
        $sldwidthNum.Enabled = $false
        $sldHeight.Enabled = $false
        $sldHeightNum.Enabled = $false
    } Else {
        $sldWidth.Enabled = $true
        $sldwidthNum.Enabled = $true
        $sldHeight.Enabled = $true
        $sldHeightNum.Enabled = $true
    }
    $sldSolveSpeed.Value = $global:PlayerPause
    $sldSolveSpeedNum.value = $global:PlayerPause
    $sldBuildSpeed.Value = $global:BuildPause
    $sldBuildSpeedNum.value = $global:BuildPause
    $sldRandom.Value = $global:Randomness
    $sldRandomNum.Value = $global:Randomness
    $cmbSolveAlgoritm.SelectedItem = $global:SolveAlgoritmIndex
    $cmbStartpoint.SelectedIndex = $global:StartpointIndex
    $cmbFinishpoint.SelectedIndex = $global:FinishpointIndex 
    $FrmLabyrinthianSettings.StartPosition = 'CenterParent'
    $FrmLabyrinthianSettings.Update()
    $FrmLabyrinthianSettings.ShowDialog()
}
Function SaveSettings {
    Param (
        [Switch]$Apply
    )
    $Global:DrawWhileBuilding = $chkDrawLab.Checked
    $global:DrawWhileSolving = $chkDrawSol.Checked
    $global:DeadEndFilling = $chkDeadEndFill.Checked
    $global:PlayerPause = $sldSolveSpeed.Value
    $global:BuildPause = $sldBuildSpeed.Value
    If ($global:SizeX -ne $sldWidth.Value -or $global:SizeY -ne $sldHeight.Value) {
        $global:SizeX = $sldWidth.Value
        $global:SizeY = $sldHeight.Value
        $global:maxmoves=($global:SizeX*$global:SizeY)
        $BtnSolveLabyrinth.Enabled=$false
    }
    $global:Randomness = $sldRandom.Value
    If ($global:SolveAlgoritm -ne $cmbSolveAlgoritm.SelectedItem) {
        $global:SolveAlgoritm = $cmbSolveAlgoritm.SelectedItem
        $global:SolveAlgoritmIndex = $cmbSolveAlgoritm.SelectedIndex
    }
    If ($global:CreateAlgoritm -ne $cmbCreateAlgoritm.SelectedItem) {
        $global:CreateAlgoritm = $cmbCreateAlgoritm.SelectedItem 
        $global:CreateAlgoritmIndex = $cmbCreateAlgoritmIndex.SelectedIndex 
    }
    $global:Startpoint = $cmbStartpoint.SelectedItem
    $global:StartpointIndex = $cmbStartpoint.SelectedIndex
    $global:Finishpoint = $cmbFinishpoint.SelectedItem
    $global:FinishpointIndex = $cmbFinishpoint.SelectedIndex

}
Function InitLabyrinth(){
    $BtnCreateLabyrinth.Enabled = $false
    $BtnSolveLabyrinth.Enabled = $false
    #Draw stuff prep
    $global:Graphics = $FrmLabyrinthian.CreateGraphics()
    [System.Collections.ArrayList]$global:labyrinth = @()
    #$Size =  $global:SizeX *  $global:SizeY
    For($i=0;$i -lt $global:SizeX;$i++) {
        $global:labyrinth += ,(@()) 
        For ($o=0;$o -lt $global:SizeY;$o++) {
            $global:labyrinth[$i] += 0
        }
    }
    $prgcalc.width = $FrmLabyrinthian.Width-225
    ClearLabyrinth
    CreateLabyrinth
    If(-not $Global:DrawWhileBuilding){DrawLabyrinth}
    $BtnCreateLabyrinth.Enabled = $true
    $BtnSolveLabyrinth.Enabled = $true
}
<#
# Create the Labyrinth
#>
Function CreateLabyrinth () {
    $global:isCreating = $true
    #determine startingpoint in the maze
    Switch ($global:Startpoint) {
        'Random'{
            $x = Get-Random -Minimum 1 -Maximum ($global:SizeX-1)
            $y = Get-Random -Minimum 1 -Maximum ($global:SizeY-1)
        }
        'Center' {
            $x = [math]::Round(($global:SizeX-1)/2)
            $y = [math]::Round(($global:SizeY-1)/2)
        }
        'Top-Left'{
            $x = 0
            $y = 0
        }
        'Top-Right'{
            $x = $global:SizeX-1
            $y = 0
        }
        'Bottom-Right'{
            $x = $global:SizeX-1
            $y = $global:SizeY-1
        }
        'Bottom-Left'{
            $x = 0
            $y = $global:SizeY-1
        }
        default{
            Write-Host "$global:startpoint not in set"
        }
    }
    $Global:Start=@($x,$y)
    $global:labyrinth[$x][$y] = 256 #start
    $pointer=0
    $progress=0
    $pointermax=0
    $prgcalc.Minimum=0
    $prgCalc.Maximum=$global:SizeX*$global:SizeY
    [System.Collections.ArrayList]$moved = @()
    [System.Collections.ArrayList]$global:endpoints = @()
    $moved.add(@($x,$y))
    If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
    $previousmove = 0
    Switch($global:CreateAlgoritm){
        'Depth-First' {
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
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $global:BuildPause
                    }
                    $progress++
                } ElseIf ($pointer -gt $pointermax) {
                    $pointermax=$pointer+1
                    $global:endpoints.Add(@($x,$y))
                    If (($x -lt $global:SizeX) -and ($x -gt 0) -and ($y -gt 0) -and ($y -lt $global:SizeY) -and $global:gaps){
                        $global:labyrinth[$x][$y] += $previousmove
                    }
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $global:BuildPause
                    }
                } Else {
                    $pointer--
                    $x = $moved[$pointer][0]
                    $y = $moved[$pointer][1]
                    #Write-host "Step $pointer = Niewe scan op punt $x $y"
                }
            }
        }
        'Prim' {
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
                    #deur gemaakt
                    $global:labyrinth[$x][$y] += $movedetection[3]
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                    }
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
                    $moved.add(@($x,$y))
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $global:BuildPause
                    }
                    $pointer++
                    #Write-host "Step $pointer = Moved to $x $y"
                    $prgCalc.Value = $progress
                    $nextspot = $moved[(Get-Random -Minimum 0 -Maximum $moved.count)] 
                    $x = $nextspot[0]
                    $y = $nextspot[1]
                    $progress++
                } Elseif ($pointer -eq 0) {
                    $pointer--
                } Else {
                    $compare = $global:labyrinth[$x][$y] -band 15
                    If($compare -eq 1 -or $compare -eq 2 -or $compare -eq 4 -or $compare -eq 8) {
                        $global:endpoints.Add(@($x,$y))
                    }
                    $removespot = $moved | Where-object {$_[0] -eq $x -and $_[1] -eq $y}
                    $pointer--
                    If ($pointer -gt 0) {
                        $moved.Remove($removespot)
                        $nextspot = $moved[(Get-Random -Minimum 0 -Maximum $moved.count)] 
                        $x = $nextspot[0]
                        $y = $nextspot[1]
                    }
                    #Write-host "Step $pointer = Niewe scan op punt $x $y"
                }
            }
        }
        'Wilson-ip' {
            [System.Collections.ArrayList]$Searchpath = @()
            $moved.add(@(Get-Random -Minimum 0 -Maximum $global:SizeX),(Get-Random -Minimum 0 -Maximum $global:SizeY))
            While($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If ($y -gt 0) {
                    If (($global:labyrinth[$x][$y-1] -bor 15) -eq 15){
                        $posDir.Add(@($global:labyrinth[$x][$y-1],$x,($y-1),1)) #Up
                    }
                } #up
                If ($y -lt ( $global:SizeY-1)) {
                    If (($global:labyrinth[$x][$y+1] -bor 15) -eq 15 ) {
                        $posDir.Add(@(($global:labyrinth[$x][$y+1]),$x,($y+1),2)) #Down
                    }
                } #down
                If ($x -gt 0) {
                    If (($global:labyrinth[$x-1][$y] -bor 15) -eq 15) {
                        $posDir.Add(@(($global:labyrinth[$x-1][$y]),($x-1),$y,4)) #left
                    }
                }  #left
                If ($x -lt ( $global:SizeX-1)) {
                    If(($global:labyrinth[$x+1][$y] -bor 15) -eq 15) {
                        $posDir.Add(@(($global:labyrinth[$x+1][$y]),($x+1),$y,8))#right
                    }
                } #right
                #Random direction
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) {
                    $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    $global:labyrinth[$x][$y] += $movedetection[3]
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                    }
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
                    $nextpoint = $Searchpath | Where-object {$_[0] -eq $x -and $_[1] -eq $y}
                    If ($null -eq $nextpoint) {
                        $nextpoint = $moved | Where-object {$_[0] -eq $x -and $_[1] -eq $y}
                        If ($null -eq $nextpoint){
                            $Searchpath.add(@($x,$y))
                        } Else {

                        }
                    } Else {

                    }
                }
            }
        }
        'Eller-ip' {
            While($Workingrow -le $global:SizeY) {


                $WorkingRow++
            }
        }
        default {Write-Host "$global:CreateAlgoritm not yet implemented"}
    }
    #End point placing
    If ($pointer -ne 0) {
        Switch ($Global:Finishpoint){
            'Endpoint Random'{
                $endpoint=$global:endpoints[(Get-Random -Minimum 0 -Maximum ($global:endpoints.Count-1))]
                $global:Finish=@($endpoint[0],$endpoint[1])
            }
            'Endpoint Far' {
                $maxdistance=0
                ForEach($endpoint in $global:endpoints){
                    $distance = [math]::abs(($endpoint[0]+$endpoint[1])-($global:start[0]+$global:start[1]))
                    If($distance -gt $maxdistance) {
                        $maxdistance = $distance 
                        $global:Finish=$endpoint
                    }
                }
            }
            'Endpoint Last' {
                $global:Finish=$global:endpoints[($global:endpoints.Count-1)]
            }
            'Endpoint First' {
                $global:Finish=$global:endpoints[0]
            }
            'Center' {
                $global:Finish=@([math]::Round(($global:SizeX-1)/2),[math]::Round(($global:SizeY-1)/2))
            }
            'Random'{
                $global:Finish=@(Get-Random -Minimum 1 -Maximum ($global:SizeX-1),Get-Random -Minimum 1 -Maximum ($global:SizeY-1))        }
            'Top-Left' {$global:Finish=@(0,0)}
            'Top-Right'{$global:Finish=@(($global:SizeX-1),0)}
            'Bottom-Right'{$global:Finish=@(($global:SizeX-1),($global:SizeY-1))}
            'Bottom-Left'{$global:Finish=@(0,($global:SizeY-1))}
        }
    } Else {
        $global:Finish=$Global:Start #Create 1 pixel labyrinth
    }
    $removespot = $global:endpoints | Where-object {$_[0] -eq $global:Finish[0] -and $_[1] -eq $global:Finish[1]}
    $global:endpoints.Remove($removespot)
    $global:labyrinth[$global:Finish[0]][$global:Finish[1]] = 512 #finish
    If($Global:DrawWhileBuilding){DrawExplorer -x $global:Finish[0] -y $global:Finish[1]}
    $Global:FirstSolve = $true
    $global:isCreating = $false
}
<#
# Solve the Labyrinth
#>
Function SolveLabyrinth {
    Param ()
    $global:isSolving = $true
    $global:moves=0
    $global:maxmoves=($global:SizeX*$global:SizeY)
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
    If ($global:ClearLabBeforeSolving -and -not $Global:FirstSolve) {DrawLabyrinth}
    $Global:FirstSolve = $false
    #Write-host "$global:start $global:finish"
    If (($global:DeadEndFilling) -and ($global:endpoints.count -gt 0)) {
        $prgCalc.Maximum = $global:endpoints.count
        $i=0
        $previouslocationX = -1
        $previouslocationY = -1
        ForEach($endpoint in $global:endpoints){
            [System.Collections.ArrayList]$posDir = @()
            $posdir.add($endpoint)
            Do {
                #Fill with bread crumb
                $movechoice = $posDir[0]
                $x=$movechoice[0]
                $y=$movechoice[1]
                [System.Collections.ArrayList]$posDir = @()
                If (($global:labyrinth[$x][$y] -band 1) -eq 1 -and -not (($x -eq $previouslocationX) -and (($y-1) -eq $previouslocationY))) {$posdir.add(@($x,($y-1),32))}
                If (($global:labyrinth[$x][$y] -band 2) -eq 2 -and -not (($x -eq $previouslocationX) -and (($y+1) -eq $previouslocationY))) {$posdir.add(@($x,($y+1),16))}
                If (($global:labyrinth[$x][$y] -band 4) -eq 4 -and -not ((($x-1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) {$posdir.add(@(($x-1),$y,128))}
                If (($global:labyrinth[$x][$y] -band 8) -eq 8 -and -not ((($x+1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) {$posdir.add(@(($x+1),$y,64))}
                $numofposdir = $posdir.Count
                If ($numofposdir -eq 1){
                    $global:labyrinth[$x][$y] += 240
                    $previouslocationX = $x
                    $previouslocationY = $y
                    If($global:DrawWhileSolving){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $global:PlayerPause
                    }
                } Else {
                    $previouslocationX = -1
                    $previouslocationY = -1
                }
            } While ($numofposdir -eq 1)
            $i++
            $prgCalc.Value = $i
        }
        #DrawLabyrinth
    }
    #start solving
    $x =$global:start[0]
    $y =$global:start[1]
    $Progress=1
    $progressmax=1
    $prgCalc.Value =$global:moves
    $prgCalc.Maximum = $global:maxmoves
    [System.Collections.ArrayList]$moved=@()
    $moved.Add(@($x,$y))
    $previousDirection = 0 
    While (($global:labyrinth[$x][$y] -band 512) -ne 512) {
        [System.Collections.ArrayList]$posDir = @()
        If (($global:labyrinth[$x][$y] -band 1) -eq 1 -and (($global:labyrinth[$x][($y-1)] -band 240) -eq 0)) {$posdir.add(@($x,($y-1),16))}
        If (($global:labyrinth[$x][$y] -band 2) -eq 2 -and (($global:labyrinth[$x][($y+1)] -band 240) -eq 0)) {$posdir.add(@($x,($y+1),32))}
        If (($global:labyrinth[$x][$y] -band 4) -eq 4 -and (($global:labyrinth[($x-1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x-1),$y,64))}
        If (($global:labyrinth[$x][$y] -band 8) -eq 8 -and (($global:labyrinth[($x+1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x+1),$y,128))}
        $numofposdir = $posdir.Count
        If($global:moves -lt $global:maxmoves) {
            $global:moves++
            $prgCalc.Value = $global:moves
        }
        If ($numofposdir -ne 0) {
            #Search Algoritms
            Switch ($global:SolveAlgoritm) {
                'Follow-Wall' {
                    Switch($previousDirection) {
                        16 {
                            $movechoice = $posDir | where-Object {$_[2] -eq 64}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 16}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 128}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 32}}
                        }
                        32 {
                            $movechoice = $posDir | where-Object {$_[2] -eq 128}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 32}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 64}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 16}}
                        }
                        64 {
                            $movechoice = $posDir | where-Object {$_[2] -eq 32}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 64}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 16}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 128}}
                        }
                        128 {
                            $movechoice = $posDir | where-Object {$_[2] -eq 16}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 128}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 32}}
                            If ($null -eq $movechoice) {$movechoice = $posDir | where-Object {$_[2] -eq 64}}
                        }
                        default {$movechoice = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]}
                    }
                    $direction = $movechoice[2]
                }
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
                    $difmin = $global:maxmoves
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
                default {
                    $movechoice = $global:Finish
                    Write-host "$global:SolveAlgoritm not implemented"
                }
            }
            $global:labyrinth[$x][$y]-=($global:labyrinth[$x][$y] -band 240)
            $global:labyrinth[$x][$y]+=$direction
            $Previousdirection = $direction
            If($global:DrawWhileSolving){
                $global:labyrinth[$x][$y]+=1024
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
            If($global:DrawWhileSolving){
                $global:labyrinth[$x][$y]+=1024
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
                If($global:DrawWhileSolving){
                    $global:labyrinth[$x][$y]+=1024
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
    $prgCalc.Value = $global:maxmoves
    If(-not $global:DrawWhileSolving){DrawLabyrinth}
    #Write-Log "$global:CreateAlgoritm - $global:SolveAlgoritm - moves: $global:moves"
    $global:isSolving = $false
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
        $y
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
            #Player
            {(1024 -band $_) -eq 1024} {
                $global:Graphics.FillRectangle($global:brushPlayer,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:labyrinth[$x][$y]-= 1024
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
        }
    }
    $FrmLabyrinthian.Update()
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
function ChangeSolveSpeed () {
    $sldSolveSpeedNum.Value = $sldSolveSpeed.Value
}
function ChangeSolveSpeedNum () {
    $sldSolveSpeed.Value = $sldSolveSpeedNum.Value 
}
function ChangeBuildSpeed () {
    $sldBuildSpeedNum.Value = $sldBuildSpeed.Value
}
function ChangeBuildSpeedNum () {
    $sldBuildSpeed.Value = $sldBuildSpeedNum.Value 
}
function ChangeRandom () {
    $sldRandomNum.Value = $sldRandom.Value
}
function ChangeRandomNum () {
    $sldRandom.Value = $sldRandomNum.Value 
}
$BtnCreateLabyrinth.Add_Click({
    InitLabyrinth
})
$BtnSolveLabyrinth.Add_Click({
    $BtnCreateLabyrinth.Enabled = $false
    $BtnSolveLabyrinth.Enabled = $false
    SolveLabyrinth
    $BtnCreateLabyrinth.Enabled = $true
    $BtnSolveLabyrinth.Enabled = $true
})
$BtnSettings.Add_Click({ ShowSettings })
$sldWidth.Add_Scroll({ ChangeSizeX })
$sldwidthNum.Add_ValueChanged({ChangeSizeXNum})
$sldHeight.Add_Scroll({ ChangeSizeY })
$sldHeightNum.Add_ValueChanged({ChangeSizeYNum})
$sldSolveSpeed.Add_Scroll({ ChangeSolveSpeed })
$sldSolveSpeedNum.Add_ValueChanged({ChangeSolveSpeedNum})
$sldBuildSpeed.Add_Scroll({ ChangeBuildSpeed })
$sldBuildSpeedNum.Add_ValueChanged({ChangeBuildSpeedNum})
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
    $FrmLabyrinthianSettings.Hide()
    $FrmLabyrinthianSettings.Close()
    SaveSettings
})
$btnApply.Add_Click({
    SaveSettings -Apply
})
$btnCancel.Add_Click({
    $FrmLabyrinthianSettings.Close()
})
$lblCalc.Add_Click({
    If($timTimer.Enabled) {
        $timTimer.Stop()
        $timTimer.Enabled =$false
    } Else {
        $timTimer.Enabled =$true
        $timTimer.Start()
        $global:timerticks =0
    }
})
$FrmLabyrinthian.Add_Shown({
    InitLabyrinth
})
$timTimer.Add_Tick({
    If ($global:isSolving){
        $lblCalc.ForeColor ='Red'
        $lblCalc.Text = $global:moves
    } Else {
        Switch ($global:timerticks){
            0 {$lblCalc.ForeColor ='Black';$lblCalc.Text = $global:CreateAlgoritm}
            1 {$lblCalc.ForeColor = 'Black';$lblCalc.Text = $global:SolveAlgoritm}
            2 {$lblCalc.ForeColor ='GreenYellow';$lblCalc.Text = $global:maxmoves}
            3 {$lblCalc.ForeColor ='Red';$lblCalc.Text = $global:moves}
            Default {$global:timerticks = -1}
        }
        $global:timerticks++
    }
    $FrmLabyrinthian.Update()
    [System.Windows.Forms.Application]::DoEvents()
})
$FrmLabyrinthian.Add_FormClosed({
    $timTimer.Stop()
    $timTimer.Dispose()
})
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)
#End