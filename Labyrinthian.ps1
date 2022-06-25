Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
Clear-Host


$Global:Startpoints = @('Random','Center','Top-Left','Top-Right','Bottom-Right','Bottom-Left')
$Global:Finishpoints = @('Endpoint Random','Endpoint Far','Endpoint Last','Endpoint First','Center','Random','Top-Left','Top-Right','Bottom-Right','Bottom-Left')
$Global:CreateAlgoritms = @('Depth-First','Prim','Wilson','Aldous-Broder','Sidewinder','Eller','Rusty Lake','Mines of Moria')
$Global:SolveAlgoritms =@('Radar','Follow-Wall','Fixed-UDLR','Random')

#Global brushes
$Global:brushw = New-Object Drawing.SolidBrush White
#$Global:brushbl = New-Object Drawing.SolidBrush Black
$Global:brushg = New-Object Drawing.SolidBrush Green
#$Global:brushdb = New-Object Drawing.SolidBrush DarkBlue
$Global:brushfin = New-Object Drawing.SolidBrush Purple
$Global:brushbc = New-Object Drawing.SolidBrush Lavender
$Global:brushr = New-Object Drawing.SolidBrush Tomato
$Global:brushBC = New-Object Drawing.SolidBrush GreenYellow
$Global:brushPlayer = New-Object Drawing.SolidBrush Fuchsia

$RegKeyPath = "HKCU:\Software\Labyrinthian"
#Init Reg key
If (Test-Path $RegKeyPath) {
    $ErrorActionPreference="SilentlyContinue" #Error Supressing because of bug in Get-ItemPoropertyValue; see https://github.com/PowerShell/PowerShell/issues/5906
    #Get-settings
    $Global:FrmSizeX = Get-ItemPropertyValue -path $RegKeyPath -Name FRMSizeX
    $Global:FrmSizeY = Get-ItemPropertyValue -path $RegKeyPath -Name FRMSizeY
    #global settings Create
    $Global:SizeX = Get-ItemPropertyValue -path $RegKeyPath -Name SizeX
    $Global:SizeY= Get-ItemPropertyValue -path $RegKeyPath -Name SizeY
    $Global:DrawWhileBuilding = Get-ItemPropertyValue -path $RegKeyPath -Name DrawWhileBuilding
    $Global:BuildPause= Get-ItemPropertyValue -path $RegKeyPath -Name BuildPause 
    $Global:Randomness = Get-ItemPropertyValue -path $RegKeyPath -Name Randomness
    $Global:MoreRandomness = Get-ItemPropertyValue -path $RegKeyPath -Name MoreRandomness
    $Global:MoreRandomness = Get-ItemPropertyValue -path $RegKeyPath -Name RandomnessFactor
    $Global:CreateAlgoritmIndex = Get-ItemPropertyValue -path $RegKeyPath -Name CreateAlgoritmIndex
    $Global:StartpointIndex = Get-ItemPropertyValue -path $RegKeyPath -Name StartpointIndex
    $Global:FinishpointIndex = Get-ItemPropertyValue -path $RegKeyPath -Name FinishpointIndex

    #Global settings Solve
    $Global:PlayerPause = Get-ItemPropertyValue -path $RegKeyPath -Name PlayerPause
    $Global:DrawWhileSolving = Get-ItemPropertyValue -path $RegKeyPath -Name DrawWhileSolving
    $Global:DeadEndFilling = Get-ItemPropertyValue -path $RegKeyPath -Name DeadEndFilling
    $Global:SolveAlgoritmIndex = Get-ItemPropertyValue -path $RegKeyPath -Name SolveAlgoritmIndex
    $Global:ClearLabBeforeSolving = Get-ItemPropertyValue -path $RegKeyPath -Name ClearLabBeforeSolving
    $ErrorActionPreference="Continue"
} 
#init settings
#Global settings Create
#Initial labyrint width & Height
If ($null -eq $Global:FrmSizeX) {$Global:FrmSizeX = 1280}
If ($null -eq $Global:FrmSizeY) {$Global:FrmSizeY = 720}
If ($null -eq $Global:SizeX) {$Global:SizeX = 30}
If ($null -eq $Global:SizeY) {$Global:SizeY= 15}
If ($null -eq $Global:DrawWhileBuilding) {$Global:DrawWhileBuilding = $true}
If ($null -eq $Global:BuildPause) {$Global:BuildPause= 1}
If ($null -eq $Global:Randomness){$Global:Randomness = 3}
If ($null -eq $Global:MoreRandomness){$Global:MoreRandomness = $true}
If ($null -eq $Global:CreateAlgoritmIndex){$Global:CreateAlgoritmIndex = 0} 
If ($null -eq $Global:StartpointIndex){$Global:StartpointIndex = 0}
If ($null -eq $Global:FinishpointIndex){$Global:FinishpointIndex = 0}
#Global settings Solve
If ($null -eq $Global:PlayerPause){$Global:PlayerPause = 2}
If ($null -eq $Global:DrawWhileSolving){$Global:DrawWhileSolving = $true}
If ($null -eq $Global:DeadEndFilling){$Global:DeadEndFilling = $true}
If ($null -eq $Global:SolveAlgoritmIndex){$Global:SolveAlgoritmIndex=0}
If ($null -eq $Global:ClearLabBeforeSolving){$Global:ClearLabBeforeSolving = $true}

$Global:SolveAlgoritm = $Global:SolveAlgoritms[$Global:SolveAlgoritmIndex] 
$Global:CreateAlgoritm = $Global:CreateAlgoritms[$Global:CreateAlgoritmIndex]
$Global:Startpoint = $Global:Startpoints[$Global:StartpointIndex]
$Global:Finishpoint = $Global:Finishpoints[$Global:FinishpointIndex]

$Global:RandomFactor = $Global:Randomness
$Global:maxmoves=($Global:SizeX*$Global:SizeY)
$Global:moves = 0

#### Form controls
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = "$Global:FrmSizeX,$Global:FrmSizeY"
$FrmLabyrinthian.text                       = "Labyrinth"
$FrmLabyrinthian.TopMost                    = $true
$FrmLabyrinthian.BackColor                  = '#808080'
$FrmLabyrinthian.StartPosition = 'Manual'
$FrmLabyrinthian.Location                    = New-Object System.Drawing.Point(0,0)

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
$prgCalc.Text = $Global:SolveAlgoritm

$lblCalc = New-Object System.Windows.Forms.Label
$lblCalc.Width = 50
$lblCalc.Height = 25
$lblCalc.TextAlign = 32 #MiddleCenter
$lblCalc.Location = New-Object System.Drawing.Point(225,0)
$lblCalc.Text = $Global:SolveAlgoritm

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
For ($i=0;$i -lt $Global:CreateAlgoritms.count;$i++) {
    [void]$cmbCreateAlgoritm.items.Add($Global:CreateAlgoritms[$i])
    If ($Global:CreateAlgoritms[$i] -eq $Global:CreateAlgoritm) {$Global:CreateAlgoritmIndex =$i}
}
$cmbCreateAlgoritm.SelectedIndex= $Global:CreateAlgoritmIndex

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
For ($i=0;$i -lt $Global:Startpoints.count;$i++) {
    [void]$cmbStartpoint.items.Add($Global:Startpoints[$i])
    If ($Global:Startpoints[$i] -eq $Global:startpoint) {$Global:StartpointIndex =$i}
}
$cmbStartpoint.SelectedIndex= $Global:StartpointIndex

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
For ($i=0;$i -lt $Global:Finishpoints.count;$i++) {
    [void]$cmbFinishpoint.items.Add($Global:Finishpoints[$i])
    If ($Global:Finishpoints[$i] -eq $Global:Finishpoint) {$Global:FinishpointIndex =$i}
}
$cmbFinishpoint.SelectedIndex= $Global:FinishpointIndex

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
$sldRandom.width = 130
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
$sldRandomNum.Location = New-Object System.Drawing.Point(225,245)
$sldRandomNum.Maximum = 100
$sldRandomNum.Minimum = 1

$chkMoreRandomness = New-Object System.Windows.Forms.Checkbox
$chkMoreRandomness.AutoSize = $true
$chkMoreRandomness.Width = 25
$chkMoreRandomness.Height = 25
$chkMoreRandomness.Text = "More Randomness"
$chkMoreRandomness.Location = New-Object System.Drawing.Point(275,245)

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
For ($i=0;$i -lt $Global:SolveAlgoritms.count;$i++) {
    [void]$cmbSolveAlgoritm.items.Add($Global:SolveAlgoritms[$i])
    If ($Global:SolveAlgoritms[$i] -eq $Global:SolveAlgoritm) {$Global:SolveAlgoritmIndex =$i}
}
$cmbSolveAlgoritm.SelectedIndex= $Global:SolveAlgoritmIndex

$chkDeadEndFill = New-Object System.Windows.Forms.Checkbox
$chkDeadEndFill.AutoSize = $true
$chkDeadEndFill.Checked = $Global:DeadEndFilling
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
    $sldRandom,$sldRandomNum,$lblRandom,$chkMoreRandomness,
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
    $chkDeadEndFill.Checked = $Global:DeadEndFilling
    $sldWidth.Value = $Global:SizeX
    $sldwidthNum.value= $Global:SizeX
    $sldHeight.Value = $Global:SizeY
    $sldHeightNum.value = $Global:SizeY
    If($Global:isCreating -or $Global:isSolving) {
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
    $sldSolveSpeed.Value = $Global:PlayerPause
    $sldSolveSpeedNum.value = $Global:PlayerPause
    $sldBuildSpeed.Value = $Global:BuildPause
    $sldBuildSpeedNum.value = $Global:BuildPause
    $chkMoreRandomness.Checked = $Global:MoreRandomness
    If ($Global:MoreRandomness) {
        $sldRandom.Value = $Global:RandomFactor
        $sldRandomNum.Value = $Global:RandomFactor
    } Else {
        $sldRandom.Value = $Global:Randomness
        $sldRandomNum.Value = $Global:Randomness
    }
    $cmbCreateAlgoritm.SelectedIndex = $Global:CreateAlgoritmIndex
    $cmbSolveAlgoritm.SelectedIndex = $Global:SolveAlgoritmIndex
    $cmbStartpoint.SelectedIndex = $Global:StartpointIndex
    $cmbFinishpoint.SelectedIndex = $Global:FinishpointIndex 
    $FrmLabyrinthianSettings.StartPosition = 'CenterParent'
    $FrmLabyrinthianSettings.Update()
    $FrmLabyrinthianSettings.ShowDialog()
}
Function SaveSettings {
    Param (
        [Switch]$Apply
    )
    $Global:DrawWhileBuilding = $chkDrawLab.Checked
    $Global:DrawWhileSolving = $chkDrawSol.Checked
    $Global:DeadEndFilling = $chkDeadEndFill.Checked
    $Global:PlayerPause = $sldSolveSpeed.Value
    $Global:BuildPause = $sldBuildSpeed.Value
    If ($Global:SizeX -ne $sldWidth.Value -or $Global:SizeY -ne $sldHeight.Value) {
        $Global:SizeX = $sldWidth.Value
        $Global:SizeY = $sldHeight.Value
        $Global:maxmoves=($Global:SizeX*$Global:SizeY)
        $BtnSolveLabyrinth.Enabled=$false
    }
    $Global:MoreRandomness = $chkMoreRandomness.Checked
    If ($Global:MoreRandomness) {
        $Global:RandomFactor = $sldRandom.Value
    } Else {
        $Global:RandomNess = $sldRandom.Value
    }
    $Global:Randomness = $sldRandom.Value
    If ($Global:SolveAlgoritm -ne $cmbSolveAlgoritm.SelectedItem) {
        $Global:SolveAlgoritm = $cmbSolveAlgoritm.SelectedItem
        $Global:SolveAlgoritmIndex = $cmbSolveAlgoritm.SelectedIndex
    }
    If ($Global:CreateAlgoritm -ne $cmbCreateAlgoritm.SelectedItem) {
        $Global:CreateAlgoritm = $cmbCreateAlgoritm.SelectedItem 
        $Global:CreateAlgoritmIndex = $cmbCreateAlgoritm.SelectedIndex 
    }
    $Global:Startpoint = $cmbStartpoint.SelectedItem
    $Global:StartpointIndex = $cmbStartpoint.SelectedIndex
    $Global:Finishpoint = $cmbFinishpoint.SelectedItem
    $Global:FinishpointIndex = $cmbFinishpoint.SelectedIndex

}
Function InitLabyrinth(){
    $BtnCreateLabyrinth.Enabled = $false
    $BtnSolveLabyrinth.Enabled = $false
    #Draw stuff prep
    $Global:Graphics = $FrmLabyrinthian.CreateGraphics()
    [System.Collections.ArrayList]$Global:labyrinth = @()
    #$Size =  $Global:SizeX *  $Global:SizeY
    For($i=0;$i -lt $Global:SizeX;$i++) {
        $Global:labyrinth += ,(@()) 
        For ($o=0;$o -lt $Global:SizeY;$o++) {
            $Global:labyrinth[$i] += 0
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
    $Global:isCreating = $true
    #determine startingpoint in the maze
    Switch ($Global:Startpoint) {
        'Random'{
            $x = Get-Random -Minimum 1 -Maximum ($Global:SizeX-1)
            $y = Get-Random -Minimum 1 -Maximum ($Global:SizeY-1)
        }
        'Center' {
            $x = [math]::Round(($Global:SizeX-1)/2)
            $y = [math]::Round(($Global:SizeY-1)/2)
        }
        'Top-Left'{
            $x = 0
            $y = 0
        }
        'Top-Right'{
            $x = $Global:SizeX-1
            $y = 0
        }
        'Bottom-Right'{
            $x = $Global:SizeX-1
            $y = $Global:SizeY-1
        }
        'Bottom-Left'{
            $x = 0
            $y = $Global:SizeY-1
        }
        default{
            Write-Host "$Global:startpoint not in set"
        }
    }
    $Global:Start=@($x,$y)
    $Global:labyrinth[$x][$y] = 256 #start
    $pointer=0
    $progress=0
    $pointermax=0
    $prgcalc.Minimum=0
    $prgCalc.Maximum=$Global:SizeX*$Global:SizeY
    [System.Collections.ArrayList]$moved = @()
    [System.Collections.ArrayList]$Global:endpoints = @()
    $previousmove = 0
    Switch($Global:CreateAlgoritm){
        'Depth-First' {
            $moved.add("$x,$y")
            If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
            While($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If ($y -gt 0) {
                    If ($Global:labyrinth[$x][$y-1] -eq 0){
                        $posDir.Add(@($Global:labyrinth[$x][$y-1],$x,($y-1),1)) #Up
                    }
                } #up
                If ($y -lt ( $Global:SizeY-1)) {
                    If ($Global:labyrinth[$x][$y+1] -eq 0 ) {
                        $posDir.Add(@(($Global:labyrinth[$x][$y+1]),$x,($y+1),2)) #Down
                    }
                } #down
                If ($x -gt 0) {
                    If ($Global:labyrinth[$x-1][$y] -eq 0) {
                        $posDir.Add(@(($Global:labyrinth[$x-1][$y]),($x-1),$y,4)) #left
                    }
                }  #left
                If ($x -lt ( $Global:SizeX-1)) {
                    If($Global:labyrinth[$x+1][$y] -eq 0) {
                        $posDir.Add(@(($Global:labyrinth[$x+1][$y]),($x+1),$y,8))#right
                    }
                } #right
                #Random direction
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) {
                    $movedetection = $posdir | Where-Object {$_[3] -eq $previousmove}
                    If ($null -eq $movedetection) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } Elseif ((Get-Random -Minimum 0 -Maximum $Global:Randomness) -eq 0) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    }
                    $previousmove = $movedetection[3]
                    #deur gevonden
                    $Global:labyrinth[$x][$y] += $movedetection[3]
                    $moved.Add("$x,$y")
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
                    $Global:labyrinth[$x][$y] += $value
                    #Write-host "Step $pointer = Moved to $x $y"
                    $prgCalc.Value = $progress
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Global:BuildPause
                    }
                    $progress++
                } ElseIf ($pointer -gt $pointermax) {
                    $pointermax=$pointer+1
                    $Global:endpoints.Add(@($x,$y))
                    If (($x -lt $Global:SizeX) -and ($x -gt 0) -and ($y -gt 0) -and ($y -lt $Global:SizeY) -and $Global:gaps){
                        $Global:labyrinth[$x][$y] += $previousmove
                    }
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Global:BuildPause
                    }
                    If ($Global:MoreRandomness) {
                        $Global:Randomness = (Get-Random -Minimum 1 -Maximum ($Global:RandomFactor+1))
                    }
                } Else {
                    $pointer--
                    $x = [int](($moved[$pointer]).Split(','))[0]
                    $y = [int](($moved[$pointer]).Split(','))[1]
                    #Write-host "Step $pointer = Niewe scan op punt $x $y"
                }
            }
        }
        'Prim' {
            $moved.add("$x,$y")
            If($Global:DrawWhileBuilding){DrawExplorer -x $x -y $y}
            While($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If ($y -gt 0) {
                    If ($Global:labyrinth[$x][$y-1] -eq 0){
                        $posDir.Add(@($Global:labyrinth[$x][$y-1],$x,($y-1),1)) #Up
                    }
                } #up
                If ($y -lt ( $Global:SizeY-1)) {
                    If ($Global:labyrinth[$x][$y+1] -eq 0 ) {
                        $posDir.Add(@(($Global:labyrinth[$x][$y+1]),$x,($y+1),2)) #Down
                    }
                } #down
                If ($x -gt 0) {
                    If ($Global:labyrinth[$x-1][$y] -eq 0) {
                        $posDir.Add(@(($Global:labyrinth[$x-1][$y]),($x-1),$y,4)) #left
                    }
                }  #left
                If ($x -lt ( $Global:SizeX-1)) {
                    If($Global:labyrinth[$x+1][$y] -eq 0) {
                        $posDir.Add(@(($Global:labyrinth[$x+1][$y]),($x+1),$y,8))#right
                    }
                } #right
                #Random direction
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) {
                    $movedetection = $posdir | Where-Object {$_[3] -eq $previousmove}
                    If ($null -eq $movedetection) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } Elseif ((Get-Random -Minimum 0 -Maximum $Global:Randomness) -eq 0) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    }
                    $previousmove = $movedetection[3]
                    #deur gemaakt
                    $Global:labyrinth[$x][$y] += $movedetection[3]
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
                    $Global:labyrinth[$x][$y] += $value
                    $moved.add("$x,$y")
                    If($Global:DrawWhileBuilding){
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Global:BuildPause
                    }
                    $pointer++
                    #Write-host "Step $pointer = Moved to $x $y"
                    $prgCalc.Value = $progress
                    If ($global:Randomness -gt 1) {
                        If ((Get-Random -Minimum 0 -Maximum $Global:Randomness) -ne 0) {
                            $nextspot = $moved[($moved.count)-1] 
                        } Else {
                            $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count)-1))] 
                        }
                    } Else {
                        $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count)-1))] 
                    }
                    $x = [int]($nextspot.split(',')[0])
                    $y = [int]($nextspot.split(',')[1])
                    $progress++
                } Elseif ($pointer -le 1) {
                    $pointer--
                } Else {
                    $compare = $Global:labyrinth[$x][$y] -band 15
                    If($compare -eq 1 -or $compare -eq 2 -or $compare -eq 4 -or $compare -eq 8) {
                        $Global:endpoints.Add(@($x,$y))
                    }
                    #$removespot = $moved | Where-object {$_[0] -eq $x -and $_[1] -eq $y}
                    $pointer--
                    #$moved.Remove($removespot)
                    $moved.RemoveAt($moved.indexof("$x,$y"))
                    $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count)-1))] 
                    $x = [int]($nextspot.split(',')[0])
                    $y = [int]($nextspot.split(',')[1])
                    #Write-host "Step $pointer = Niewe scan op punt $x $y"
                }
            }
        }
        'Wilson-ip' {
            [System.Collections.ArrayList]$Searchpath = @()
            $moved.add(@(Get-Random -Minimum 0 -Maximum $Global:SizeX),(Get-Random -Minimum 0 -Maximum $Global:SizeY))
            While($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If ($y -gt 0) {
                    If (($Global:labyrinth[$x][$y-1] -bor 15) -eq 15){
                        $posDir.Add(@($Global:labyrinth[$x][$y-1],$x,($y-1),1)) #Up
                    }
                } #up
                If ($y -lt ( $Global:SizeY-1)) {
                    If (($Global:labyrinth[$x][$y+1] -bor 15) -eq 15 ) {
                        $posDir.Add(@(($Global:labyrinth[$x][$y+1]),$x,($y+1),2)) #Down
                    }
                } #down
                If ($x -gt 0) {
                    If (($Global:labyrinth[$x-1][$y] -bor 15) -eq 15) {
                        $posDir.Add(@(($Global:labyrinth[$x-1][$y]),($x-1),$y,4)) #left
                    }
                }  #left
                If ($x -lt ( $Global:SizeX-1)) {
                    If(($Global:labyrinth[$x+1][$y] -bor 15) -eq 15) {
                        $posDir.Add(@(($Global:labyrinth[$x+1][$y]),($x+1),$y,8))#right
                    }
                } #right
                #Random direction
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) {
                    $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    $Global:labyrinth[$x][$y] += $movedetection[3]
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
                    $Global:labyrinth[$x][$y] += $value
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
            While($Workingrow -le $Global:SizeY) {


                $WorkingRow++
            }
        }
        default {
            #Default empty labyrinth
            For ($x=0;$x -lt $Global:SizeX;$x++) {
                For ($y=0;$y -lt $Global:SizeY;$y++) {
                    If ($x -eq 0) {$Global:labyrinth[$x][$y]+=8}
                    If ($x -eq ($Global:SizeX-1)) {$Global:labyrinth[$x][$y]+=4}
                    If ($y -eq 0) {$Global:labyrinth[$x][$y]+=2}
                    If ($y -eq ($Global:SizeY-1)) {$Global:labyrinth[$x][$y]+=1}
                    $compare = $Global:labyrinth[$x][$y] -band 15
                    Switch ($compare) {
                        0 {$Global:labyrinth[$x][$y]+=15}
                        1 {$Global:labyrinth[$x][$y]+=12}
                        2 {$Global:labyrinth[$x][$y]+=12}
                        4 {$Global:labyrinth[$x][$y]+=3}
                        8 {$Global:labyrinth[$x][$y]+=3}
                        default {$Global:endpoints.Add(@($x,$y))}
                    }
                    If($Global:DrawWhileBuilding) {DrawExplorer -x $x -y $y}
                }
            }
            Write-Host "$Global:CreateAlgoritm not yet implemented"
        }
    }
    #End point placing
    If ($Global:endpoints.count -gt 0) {
        Switch ($Global:Finishpoint){
            'Endpoint Far' {
                $maxdistance=0
                ForEach($endpoint in $Global:endpoints){
                    $distance = [math]::abs(($endpoint[0]+$endpoint[1])-($Global:start[0]+$Global:start[1]))
                    If($distance -gt $maxdistance) {
                        $maxdistance = $distance 
                        $Global:Finish=$endpoint
                    }
                }
            }
            'Endpoint Random'{
                $endpoint=$Global:endpoints[(Get-Random -Minimum 0 -Maximum ($Global:endpoints.Count-1))]
                $Global:Finish=@($endpoint[0],$endpoint[1])
            }
            'Endpoint Last' {
                $Global:Finish=$Global:endpoints[($Global:endpoints.Count-1)]
            }
            'Endpoint First' {
                $Global:Finish=$Global:endpoints[0]
            }
            'Center' {
                $Global:Finish=@([math]::Round(($Global:SizeX-1)/2),[math]::Round(($Global:SizeY-1)/2))
            }
            'Random'{
                $Global:Finish=@((Get-Random -Minimum 0 -Maximum ($Global:SizeX-1)),(Get-Random -Minimum 0 -Maximum ($Global:SizeY-1)))}
            'Top-Left' {$Global:Finish=@(0,0)}
            'Top-Right'{$Global:Finish=@(($Global:SizeX-1),0)}
            'Bottom-Right'{$Global:Finish=@(($Global:SizeX-1),($Global:SizeY-1))}
            'Bottom-Left'{$Global:Finish=@(0,($Global:SizeY-1))}
        }
    } Else {
        $Global:Finish=$Global:Start #Create 1 pixel labyrinth
    }
    $removespot = $Global:endpoints | Where-object {$_[0] -eq $Global:Finish[0] -and $_[1] -eq $Global:Finish[1]}
    $Global:endpoints.Remove($removespot)
    $Global:labyrinth[$Global:Finish[0]][$Global:Finish[1]] = 512 #finish
    If($Global:DrawWhileBuilding){DrawExplorer -x $Global:Finish[0] -y $Global:Finish[1]}
    $Global:FirstSolve = $true
    $Global:isCreating = $false
}
<#
# Solve the Labyrinth
#>
Function SolveLabyrinth {
    Param ()
    $Global:isSolving = $true
    $Global:moves=0
    $Global:maxmoves=($Global:SizeX*$Global:SizeY)
    #Clear breadcrumbs
    For($i=0;$i -lt  $Global:SizeX;$i++) {
        For ($o=0;$o -lt  $Global:SizeY;$o++) {
            $breadcrumb = ($Global:labyrinth[$i][$o]) -band 240
            If($breadcrumb -ne 0) {
                $Global:labyrinth[$i][$o]-=$breadcrumb #remove breadcrumbs
            }
        }
    }
    #ClearLabyrinth
    If ($Global:ClearLabBeforeSolving -and -not $Global:FirstSolve) {DrawLabyrinth}
    $Global:FirstSolve = $false
    #Write-host "$Global:start $Global:finish"
    If (($Global:DeadEndFilling) -and ($Global:endpoints.count -gt 0)) {
        $prgCalc.Maximum = $Global:endpoints.count
        $i=0
        $previouslocationX = -1
        $previouslocationY = -1
        ForEach($endpoint in $Global:endpoints){
            [System.Collections.ArrayList]$posDir = @()
            $posdir.add($endpoint)
            Do {
                #Fill with bread crumb
                $movechoice = $posDir[0]
                $x=$movechoice[0]
                $y=$movechoice[1]
                [System.Collections.ArrayList]$posDir = @()
                If (($Global:labyrinth[$x][$y] -band 1) -eq 1 -and -not (($x -eq $previouslocationX) -and (($y-1) -eq $previouslocationY))) {$posdir.add(@($x,($y-1),32))}
                If (($Global:labyrinth[$x][$y] -band 2) -eq 2 -and -not (($x -eq $previouslocationX) -and (($y+1) -eq $previouslocationY))) {$posdir.add(@($x,($y+1),16))}
                If (($Global:labyrinth[$x][$y] -band 4) -eq 4 -and -not ((($x-1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) {$posdir.add(@(($x-1),$y,128))}
                If (($Global:labyrinth[$x][$y] -band 8) -eq 8 -and -not ((($x+1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) {$posdir.add(@(($x+1),$y,64))}
                $numofposdir = $posdir.Count
                If ($numofposdir -eq 1){
                    $Global:labyrinth[$x][$y] += 240
                    $previouslocationX = $x
                    $previouslocationY = $y
                    If($Global:DrawWhileSolving){
                        DrawExplorer -x $x -y $y
                        #Start-Sleep -Milliseconds $Global:PlayerPause
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
    $x =$Global:start[0]
    $y =$Global:start[1]
    $Progress=1
    $progressmax=1
    $prgCalc.Value =$Global:moves
    $prgCalc.Maximum = $Global:maxmoves
    [System.Collections.ArrayList]$moved=@()
    $moved.Add(@($x,$y))
    $previousDirection = 0 
    While (($Global:labyrinth[$x][$y] -band 512) -ne 512) {
        [System.Collections.ArrayList]$posDir = @()
        If (($Global:labyrinth[$x][$y] -band 1) -eq 1 -and (($Global:labyrinth[$x][($y-1)] -band 240) -eq 0)) {$posdir.add(@($x,($y-1),16))}
        If (($Global:labyrinth[$x][$y] -band 2) -eq 2 -and (($Global:labyrinth[$x][($y+1)] -band 240) -eq 0)) {$posdir.add(@($x,($y+1),32))}
        If (($Global:labyrinth[$x][$y] -band 4) -eq 4 -and (($Global:labyrinth[($x-1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x-1),$y,64))}
        If (($Global:labyrinth[$x][$y] -band 8) -eq 8 -and (($Global:labyrinth[($x+1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x+1),$y,128))}
        $numofposdir = $posdir.Count
        If($Global:moves -lt $Global:maxmoves) {
            $Global:moves++
            $prgCalc.Value = $Global:moves
        }
        If ($numofposdir -ne 0) {
            #Search Algoritms
            Switch ($Global:SolveAlgoritm) {
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
                'Fixed-UDLR' {
                    $movechoice = $posDir[0]
                    $direction = $movechoice[2]
                }
                'Radar' {
                    #Radar = Look over the hedges to see which direction
                    $difmin = $Global:maxmoves
                    For ($i=0;$i -lt $numofposdir;$i++) {
                        $difx = [math]::abs(($posdir[$i])[0] - $Global:Finish[0])
                        $dify = [math]::abs(($posdir[$i])[1] - $Global:Finish[1])
                        $dif = [math]::Sqrt(($difx*$difx)+($dify*$dify))
                        If($dif -le $difmin) {
                            $difmin = $dif
                            $choice = $i
                        }
                    }
                    #Write-Host "$difx - $dify - $dif - $difmin"
                    $movechoice = $posDir[$choice]
                    $direction = $movechoice[2]
                }
                default {
                    $movechoice = $Global:Finish
                    Write-host "$Global:SolveAlgoritm not implemented"
                }
            }
            $Global:labyrinth[$x][$y]-=($Global:labyrinth[$x][$y] -band 240)
            $Global:labyrinth[$x][$y]+=$direction
            $Previousdirection = $direction
            If($Global:DrawWhileSolving){
                $Global:labyrinth[$x][$y]+=1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $Global:PlayerPause
                DrawExplorer -x $x -y $y
            }
            $x = $movechoice[0]
            $y = $movechoice[1]
            $Global:labyrinth[$x][$y]+=240
            $moved.Add(@($x,$y))
            $progress=$moved.count-1
            #Write-host "New route: " -NoNewline
        } ElseIf($progress -gt $progressmax) {
            $progressmax=$Progress+1
            $Global:labyrinth[$x][$y]+= 240 - ($Global:labyrinth[$x][$y] -band 240)
            If($Global:DrawWhileSolving){
                $Global:labyrinth[$x][$y]+=1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $Global:PlayerPause
                DrawExplorer -x $x -y $y
            }
            #Write-host "Deadend at $x $y"
        } Else {
            $Progress--
            $Global:moves--
            If (($Global:labyrinth[$x][$y] -band 240) -ne 240) {
                $Global:labyrinth[$x][$y]+= 240 - ($Global:labyrinth[$x][$y] -band 240)
                If($Global:DrawWhileSolving){
                    $Global:labyrinth[$x][$y]+=1024
                    DrawExplorer -x $x -y $y
                    Start-Sleep -Milliseconds $Global:PlayerPause
                    DrawExplorer -x $x -y $y
                }
            }
            $x = $moved[$progress][0]
            $y = $moved[$progress][1]
            #Write-host "Backtrack: " -NoNewline
            }
        #Write-host "$x $y"
    }
    #$Global:labyrinth[$x][$y]-=64
    $prgCalc.Value = $Global:maxmoves
    If(-not $Global:DrawWhileSolving){DrawLabyrinth}
    #Write-Log "$Global:CreateAlgoritm - $Global:SolveAlgoritm - moves: $Global:moves"
    $Global:isSolving = $false
}
Function ClearLabyrinth () {
    #$FrmLabyrinthian.Refresh()
    $Global:brushb = New-Object Drawing.SolidBrush Gray
    $Global:Graphics = $FrmLabyrinthian.CreateGraphics()
    $Global:Graphics.FillRectangle($Global:brushb,0,0,$FrmLabyrinthian.Width,$FrmLabyrinthian.Height)
    #$FrmLabyrinthian.Update()
}
Function DrawExplorer {
    Param (
        $x,
        $y
    )
    $offsetx = 25
    $offsety = 25
    $ScaleX = (($FrmLabyrinthian.Width-($offsetx*2))/ $Global:SizeX)
    $ScaleY= ((($FrmLabyrinthian.Height - 25)-($offsety*2))/ $Global:SizeY)
    $RoomScaleX = 0.75
    $RoomScaleY = 0.75
    $RoomSizeX = $ScaleX * $RoomScaleX
    $RoomsizeY = $Scaley * $RoomScaleY
    $RoomScaleXX =1-$RoomScaleX
    $RoomScaleYY =1-$RoomScaleY
    If ((($Global:labyrinth[$x][$y] -band 240) -ne 0) -and (($Global:labyrinth[$x][$y] -band 240) -ne 240)) {
        Switch($Global:labyrinth[$x][$y]) {
            {(16 -band $_) -eq 16} {
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,((($y)-$RoomScaleYY)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(32 -band $_) -eq 32} {
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,((($y)+$RoomScaleYY)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(64 -band $_) -eq 64} {
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushr,((($x)-$RoomScaleXX)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(128 -band $_) -eq 128} {
                $Global:Graphics.FillRectangle($Global:brushr,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushr,((($x)+$RoomScaleXX)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #Player
            {(1024 -band $_) -eq 1024} {
                $Global:Graphics.FillRectangle($Global:brushPlayer,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:labyrinth[$x][$y]-= 1024
            }
        }
    } Else {
        Switch($Global:labyrinth[$x][$y]) {
            0 {
                $Global:Graphics.FillRectangle($Global:brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
            }
            {(1 -band $_) -eq 1} {
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,(($y-0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(2 -band $_) -eq 2} {
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(4 -band $_) -eq 4} {
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushw,(($x-0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(8 -band $_) -eq 8} {
                $Global:Graphics.FillRectangle($Global:brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $Global:Graphics.FillRectangle($Global:brushw,(($x+0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
        }
        Switch($Global:labyrinth[$x][$y]) {
            #Breadcrumbs
            {(240 -band $_) -eq 240} {
                $Global:Graphics.FillRectangle($Global:brushBC,(($x)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #Start
            {(256 -band $_) -eq 256} {
                $Global:Graphics.FillRectangle($Global:brushg,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            #Finish
            {(512 -band $_) -eq 512} {
                $Global:Graphics.FillRectangle($Global:brushfin,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
        }
    }
    $FrmLabyrinthian.Update()
    [System.Windows.Forms.Application]::DoEvents()
}
Function DrawLabyrinth {    
    Param ()
    For($y=0;$y -lt  $Global:SizeY;$y++) { 
        For($x=0;$x -lt  $Global:SizeX;$x++) {
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

$FrmLabyrinthian.Add_ResizeEnd({
    $Global:FrmSizeX = $FrmLabyrinthian.Width
    $Global:FrmSizeY = $FrmLabyrinthian.Height
    ClearLabyrinth
    DrawLabyrinth
    $prgCalc.width=$FrmLabyrinthian.width-225})
$FrmLabyrinthian.Add_SizeChanged({
    If ($FrmLabyrinthian.WindowState -ne 'Normal' -or $Global:PreviousState -ne 'Normal') {
        ClearLabyrinth;DrawLabyrinth;$prgCalc.width=$FrmLabyrinthian.width-225
        $Global:PreviousState = $FrmLabyrinthian.WindowState
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
$FrmLabyrinthian.Add_Shown({
    InitLabyrinth
})
$lblCalc.Add_Click({
    If($timTimer.Enabled) {
        $timTimer.Stop()
        $timTimer.Enabled =$false
    } Else {
        $timTimer.Enabled =$true
        $timTimer.Start()
        $Global:timerticks =0
    }
})
$timTimer.Add_Tick({
    If ($Global:isSolving){
        $lblCalc.ForeColor ='Red'
        $lblCalc.Text = $Global:moves
    } Else {
        Switch ($Global:timerticks){
            0 {$lblCalc.ForeColor ='Black';$lblCalc.Text = $Global:CreateAlgoritm}
            1 {$lblCalc.ForeColor = 'Black';$lblCalc.Text = $Global:SolveAlgoritm}
            2 {$lblCalc.ForeColor ='GreenYellow';$lblCalc.Text = $Global:maxmoves}
            3 {$lblCalc.ForeColor ='Red';$lblCalc.Text = $Global:moves}
            Default {$Global:timerticks = -1}
        }
        $Global:timerticks++
    }
    $FrmLabyrinthian.Update()
    [System.Windows.Forms.Application]::DoEvents()
})
$FrmLabyrinthian.Add_FormClosed({
    $timTimer.Stop()
    $timTimer.Dispose()
})
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)

#Create Key for Settings
$regkey = New-Item -Path $RegKeyPath -Force
$regkey = Set-Item -Path $RegKeyPath -Value "Labyrinthian keys"
#Save settings to registry
$regkey = New-ItemProperty -Path $RegKeyPath -Name FRMSizeX -PropertyType Dword -Value $Global:FrmSizeX
$regkey = New-ItemProperty -Path $RegKeyPath -Name FRMSizeY -PropertyType Dword -Value $Global:FrmSizeY
$regkey = New-ItemProperty -Path $RegKeyPath -Name SizeX -PropertyType Dword -Value $Global:SizeX
$regkey = New-ItemProperty -Path $RegKeyPath -Name SizeY -PropertyType Dword -Value $Global:SizeY
$regkey = New-ItemProperty -Path $RegKeyPath -Name DrawWhileBuilding -PropertyType Dword -Value $Global:DrawWhileBuilding
$regkey = New-ItemProperty -Path $RegKeyPath -Name BuildPause -PropertyType Dword -Value $Global:BuildPause
$regkey = New-ItemProperty -Path $RegKeyPath -Name Randomness -PropertyType Dword -Value $Global:Randomness
$regkey = New-ItemProperty -Path $RegKeyPath -Name MoreRandomness -PropertyType Dword -Value $Global:MoreRandomness
$regkey = New-ItemProperty -Path $RegKeyPath -Name RandomnessFactor -PropertyType Dword -Value $Global:MoreRandomness
$regkey = New-ItemProperty -Path $RegKeyPath -Name CreateAlgoritmIndex -PropertyType Dword -Value $Global:CreateAlgoritmIndex
$regkey = New-ItemProperty -Path $RegKeyPath -Name StartpointIndex -PropertyType Dword -Value $Global:StartpointIndex
$regkey = New-ItemProperty -Path $RegKeyPath -Name FinishpointIndex -PropertyType Dword -Value $Global:FinishpointIndex
$regkey = New-ItemProperty -Path $RegKeyPath -Name PlayerPause -PropertyType Dword -Value $Global:PlayerPause
$regkey = New-ItemProperty -Path $RegKeyPath -Name DrawWhileSolving -PropertyType Dword -Value $Global:DrawWhileSolving
$regkey = New-ItemProperty -Path $RegKeyPath -Name DeadEndFilling -PropertyType Dword -Value $Global:DeadEndFilling
$regkey = New-ItemProperty -Path $RegKeyPath -Name SolveAlgoritmIndex -PropertyType Dword -Value $Global:SolveAlgoritmIndex 
$regkey = New-ItemProperty -Path $RegKeyPath -Name ClearLabBeforeSolving -PropertyType Dword -Value $Global:ClearLabBeforeSolving 
#End