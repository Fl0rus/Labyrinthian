Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore, PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
Clear-Host

$Script:Startpoints = @('Random', 'Center', 'Top-Left', 'Top-Right', 'Bottom-Right', 'Bottom-Left')
$Script:Finishpoints = @('Endpoint Random', 'Endpoint Far', 'Endpoint Last', 'Endpoint First', 'Center', 'Random', 'Top-Left', 'Top-Right', 'Bottom-Right', 'Bottom-Left')
$Script:CreateAlgoritms = @('Depth-First', 'Prim', 'Wilson', 'Aldous-Broder', 'Sidewinder', 'Eller', 'Rusty Lake', 'Mines of Moria')
$Script:SolveAlgoritms = @('Radar', 'Follow-Wall', 'Fixed-UDLR', 'Random')

#Global brushes
$Script:brushw = New-Object Drawing.SolidBrush White
$Script:brushg = New-Object Drawing.SolidBrush Green
$Script:brushfin = New-Object Drawing.SolidBrush Purple
$Script:brushbc = New-Object Drawing.SolidBrush Lavender
$Script:brushr = New-Object Drawing.SolidBrush Tomato
$Script:brushBC = New-Object Drawing.SolidBrush GreenYellow
$Script:brushPlayer = New-Object Drawing.SolidBrush Fuchsia

$RegKeyPath = 'HKCU:\Software\Labyrinthian'
#Init Reg key
If (Test-Path $RegKeyPath) {
    $ErrorActionPreference = 'SilentlyContinue' #Error Supressing because of bug in Get-ItemPoropertyValue; see https://github.com/PowerShell/PowerShell/issues/5906
    #Get-settings
    $Script:FrmSizeX = Get-ItemPropertyValue -Path $RegKeyPath -Name FRMSizeX
    $Script:FrmSizeY = Get-ItemPropertyValue -Path $RegKeyPath -Name FRMSizeY
    #global settings Create
    $Script:SizeX = Get-ItemPropertyValue -Path $RegKeyPath -Name SizeX
    $Script:SizeY = Get-ItemPropertyValue -Path $RegKeyPath -Name SizeY
    $Script:DrawWhileBuilding = Get-ItemPropertyValue -Path $RegKeyPath -Name DrawWhileBuilding
    $Script:BuildPause = Get-ItemPropertyValue -Path $RegKeyPath -Name BuildPause 
    $Script:Randomness = Get-ItemPropertyValue -Path $RegKeyPath -Name Randomness
    $Script:MoreRandomness = Get-ItemPropertyValue -Path $RegKeyPath -Name MoreRandomness
    $Script:MoreRandomness = Get-ItemPropertyValue -Path $RegKeyPath -Name RandomnessFactor
    $Script:CreateAlgoritmIndex = Get-ItemPropertyValue -Path $RegKeyPath -Name CreateAlgoritmIndex
    $Script:StartpointIndex = Get-ItemPropertyValue -Path $RegKeyPath -Name StartpointIndex
    $Script:FinishpointIndex = Get-ItemPropertyValue -Path $RegKeyPath -Name FinishpointIndex

    #Global settings Solve
    $Script:PlayerPause = Get-ItemPropertyValue -Path $RegKeyPath -Name PlayerPause
    $Script:DrawWhileSolving = Get-ItemPropertyValue -Path $RegKeyPath -Name DrawWhileSolving
    $Script:DeadEndFilling = Get-ItemPropertyValue -Path $RegKeyPath -Name DeadEndFilling
    $Script:SolveAlgoritmIndex = Get-ItemPropertyValue -Path $RegKeyPath -Name SolveAlgoritmIndex
    $Script:ClearLabBeforeSolving = Get-ItemPropertyValue -Path $RegKeyPath -Name ClearLabBeforeSolving
    $ErrorActionPreference = 'Continue'
} 
#init settings
#Global settings Create
#Initial labyrint width & Height
If ($null -eq $Script:FrmSizeX) { $Script:FrmSizeX = 1280 }
If ($null -eq $Script:FrmSizeY) { $Script:FrmSizeY = 720 }
If ($null -eq $Script:SizeX) { $Script:SizeX = 30 }
If ($null -eq $Script:SizeY) { $Script:SizeY = 15 }
If ($null -eq $Script:DrawWhileBuilding) { $Script:DrawWhileBuilding = $true }
If ($null -eq $Script:BuildPause) { $Script:BuildPause = 1 }
If ($null -eq $Script:Randomness) { $Script:Randomness = 3 }
If ($null -eq $Script:MoreRandomness) { $Script:MoreRandomness = $true }
If ($null -eq $Script:CreateAlgoritmIndex) { $Script:CreateAlgoritmIndex = 0 } 
If ($null -eq $Script:StartpointIndex) { $Script:StartpointIndex = 0 }
If ($null -eq $Script:FinishpointIndex) { $Script:FinishpointIndex = 0 }
#Global settings Solve
If ($null -eq $Script:PlayerPause) { $Script:PlayerPause = 2 }
If ($null -eq $Script:DrawWhileSolving) { $Script:DrawWhileSolving = $true }
If ($null -eq $Script:DeadEndFilling) { $Script:DeadEndFilling = $true }
If ($null -eq $Script:SolveAlgoritmIndex) { $Script:SolveAlgoritmIndex = 0 }
If ($null -eq $Script:ClearLabBeforeSolving) { $Script:ClearLabBeforeSolving = $true }

$Script:SolveAlgoritm = $Script:SolveAlgoritms[$Script:SolveAlgoritmIndex] 
$Script:CreateAlgoritm = $Script:CreateAlgoritms[$Script:CreateAlgoritmIndex]
$Script:Startpoint = $Script:Startpoints[$Script:StartpointIndex]
$Script:Finishpoint = $Script:Finishpoints[$Script:FinishpointIndex]

$Script:RandomFactor = $Script:Randomness
$Script:maxmoves = ($Script:SizeX * $Script:SizeY)
$Script:moves = 0

#### Form controls
$FrmLabyrinthian = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize = "$Script:FrmSizeX,$Script:FrmSizeY"
$FrmLabyrinthian.text = 'Labyrinth'
$FrmLabyrinthian.TopMost = $true
$FrmLabyrinthian.BackColor = '#808080'
$FrmLabyrinthian.StartPosition = 'Manual'
$FrmLabyrinthian.Location = New-Object System.Drawing.Point(0, 0)

$BtnCreateLabyrinth = New-Object system.Windows.Forms.Button
$BtnCreateLabyrinth.text = 'Create'
$BtnCreateLabyrinth.width = 75
$BtnCreateLabyrinth.height = 25
$BtnCreateLabyrinth.location = New-Object System.Drawing.Point(0, 0)
$BtnCreateLabyrinth.Font = 'Microsoft Sans Serif,10'
$BtnCreateLabyrinth.BackColor = '#999999'

$BtnSolveLabyrinth = New-Object system.Windows.Forms.Button
$BtnSolveLabyrinth.text = 'Solve'
$BtnSolveLabyrinth.width = 75
$BtnSolveLabyrinth.height = 25
$BtnSolveLabyrinth.location = New-Object System.Drawing.Point(75, 0)
$BtnSolveLabyrinth.Font = 'Microsoft Sans Serif,10'
$BtnSolveLabyrinth.BackColor = '#999999'
$BtnSolveLabyrinth.Enabled = $false

$BtnSettings = New-Object system.Windows.Forms.Button
$BtnSettings.text = 'Settings'
$BtnSettings.width = 75
$BtnSettings.height = 25
$BtnSettings.location = New-Object System.Drawing.Point(150, 0)
$BtnSettings.Font = 'Microsoft Sans Serif,10'
$BtnSettings.BackColor = '#999999'
$BtnSettings.Enabled = $true

$prgCalc = New-Object System.Windows.Forms.ProgressBar
$prgCalc.Width = $FrmLabyrinthian.width - 175
$prgCalc.Height = 20
$prgcalc.value = 0
$prgcalc.Location = New-Object System.Drawing.Point(275, 0)
$prgCalc.Text = $Script:SolveAlgoritm

$lblCalc = New-Object System.Windows.Forms.Label
$lblCalc.Width = 50
$lblCalc.Height = 25
$lblCalc.TextAlign = 32 #MiddleCenter
$lblCalc.Location = New-Object System.Drawing.Point(225, 0)
$lblCalc.Text = $Script:SolveAlgoritm

$timTimer = New-Object System.Windows.Forms.Timer
$timTimer.Enabled = $false
$timTimer.Interval = 500

##########################
#Create Settings controls #
##########################
$chkDrawLab = New-Object System.Windows.Forms.Checkbox
$chkDrawLab.AutoSize = $true
$chkDrawLab.Width = 25
$chkDrawLab.Height = 25
$chkDrawLab.Text = 'Draw while building'
$chkDrawLab.Location = New-Object System.Drawing.Point(10, 10)

$lblCreateAlgoritm = New-Object System.Windows.Forms.Label
$lblCreateAlgoritm.AutoSize = $true
$lblCreateAlgoritm.width = 70
$lblCreateAlgoritm.height = 30
$lblCreateAlgoritm.TextAlign = 16 #MiddleLeft
$lblCreateAlgoritm.location = New-Object System.Drawing.Point(10, 35)
$lblCreateAlgoritm.Text = 'Create Algoritm'

$cmbCreateAlgoritm = New-Object System.Windows.Forms.ComboBox
$cmbCreateAlgoritm.Width = 125
$cmbCreateAlgoritm.Height = 30
$cmbCreateAlgoritm.AutoSize = $true
$cmbCreateAlgoritm.DropDownStyle = 2
$cmbCreateAlgoritm.AutoCompleteMode = 0
$cmbCreateAlgoritm.location = New-Object System.Drawing.Point(100, 35)
For ($i = 0; $i -lt $Script:CreateAlgoritms.count; $i++) {
    [void]$cmbCreateAlgoritm.items.Add($Script:CreateAlgoritms[$i])
    If ($Script:CreateAlgoritms[$i] -eq $Script:CreateAlgoritm) { $Script:CreateAlgoritmIndex = $i }
}
$cmbCreateAlgoritm.SelectedIndex = $Script:CreateAlgoritmIndex

$lblStartpoint = New-Object System.Windows.Forms.Label
$lblStartpoint.AutoSize = $true
$lblStartpoint.width = 70
$lblStartpoint.height = 30
$lblStartpoint.TextAlign = 16 #MiddleLeft
$lblStartpoint.location = New-Object System.Drawing.Point(10, 70)
$lblStartpoint.Text = 'Start Point'

$cmbStartpoint = New-Object System.Windows.Forms.ComboBox
$cmbStartpoint.Width = 125
$cmbStartpoint.Height = 30
$cmbStartpoint.AutoSize = $true
$cmbStartpoint.DropDownStyle = 2
$cmbStartpoint.AutoCompleteMode = 0
$cmbStartpoint.location = New-Object System.Drawing.Point(100, 70)
For ($i = 0; $i -lt $Script:Startpoints.count; $i++) {
    [void]$cmbStartpoint.items.Add($Script:Startpoints[$i])
    If ($Script:Startpoints[$i] -eq $Script:startpoint) { $Script:StartpointIndex = $i }
}
$cmbStartpoint.SelectedIndex = $Script:StartpointIndex

$lblFinishpoint = New-Object System.Windows.Forms.Label
$lblFinishpoint.AutoSize = $true
$lblFinishpoint.width = 70
$lblFinishpoint.height = 30
$lblFinishpoint.TextAlign = 16 #MiddleLeft
$lblFinishpoint.location = New-Object System.Drawing.Point(10, 100)
$lblFinishpoint.Text = 'Finish Point'

$cmbFinishpoint = New-Object System.Windows.Forms.ComboBox
$cmbFinishpoint.Width = 125
$cmbFinishpoint.Height = 30
$cmbFinishpoint.AutoSize = $true
$cmbFinishpoint.DropDownStyle = 2
$cmbFinishpoint.AutoCompleteMode = 0
$cmbFinishpoint.location = New-Object System.Drawing.Point(100, 100)
For ($i = 0; $i -lt $Script:Finishpoints.count; $i++) {
    [void]$cmbFinishpoint.items.Add($Script:Finishpoints[$i])
    If ($Script:Finishpoints[$i] -eq $Script:Finishpoint) { $Script:FinishpointIndex = $i }
}
$cmbFinishpoint.SelectedIndex = $Script:FinishpointIndex

$sldWidth = New-Object System.Windows.Forms.Trackbar
$sldwidth.AutoSize = $true
$sldwidth.Text = 'Width'
$sldWidth.width = 200
$sldWidth.Height = 30
$sldWidth.location = New-Object System.Drawing.Point(10, 145)
$sldwidth.Maximum = 200
$sldWidth.Minimum = 5
$sldwidth.AutoSize = $True
$sldwidth.TickStyle = 2
$sldwidth.TickFrequency = 10
$sldWidth.Orientation = 0

$sldwidthNum = New-Object System.Windows.Forms.NumericUpDown
$sldwidthNum.width = 45
$sldwidthNum.Height = 30
$sldwidthNum.Location = New-Object System.Drawing.Point(210, 145)
$sldwidthNum.Maximum = 200
$sldwidthNum.Minimum = 5

$lblWidth = New-Object System.Windows.Forms.Label
$lblWidth.width = 50
$lblWidth.height = 30
$lblWidth.location = New-Object System.Drawing.Point(260, 145)
$lblWidth.Text = 'Width'

$sldHeight = New-Object System.Windows.Forms.Trackbar
$sldHeight.AutoSize = $true
$sldHeight.Text = 'Height'
$sldHeight.width = 200
$sldHeight.Height = 30
$sldHeight.location = New-Object System.Drawing.Point(10, 200)
$sldHeight.Maximum = 150
$sldHeight.Minimum = 5
$sldHeight.TickFrequency = 10
$sldHeight.TickStyle = 2
$sldHeight.Orientation = 0

$sldHeightNum = New-Object System.Windows.Forms.NumericUpDown
$sldHeightNum.width = 45
$sldHeightNum.Height = 25
$sldHeightNum.Location = New-Object System.Drawing.Point(210, 200)
$sldHeightNum.Maximum = 150
$sldHeightNum.Minimum = 5

$lblHeight = New-Object System.Windows.Forms.Label
$lblHeight.width = 50
$lblHeight.height = 30
$lblHeight.location = New-Object System.Drawing.Point(260, 200)
$lblHeight.Text = 'Height'

$lblRandom = New-Object System.Windows.Forms.Label
$lblRandom.width = 80
$lblRandom.height = 30
$lblRandom.location = New-Object System.Drawing.Point(10, 245)
$lblRandom.Text = 'Randomness'

$sldRandom = New-Object System.Windows.Forms.Trackbar
$sldRandom.AutoSize = $true
$sldRandom.Text = 'Randomness'
$sldRandom.width = 130
$sldRandom.Height = 30
$sldRandom.location = New-Object System.Drawing.Point(90, 245)
$sldRandom.Maximum = 100
$sldRandom.Minimum = 1
$sldRandom.TickFrequency = 10
$sldRandom.TickStyle = 2
$sldRandom.Orientation = 0

$sldRandomNum = New-Object System.Windows.Forms.NumericUpDown
$sldRandomNum.width = 45
$sldRandomNum.Height = 25
$sldRandomNum.Location = New-Object System.Drawing.Point(225, 245)
$sldRandomNum.Maximum = 100
$sldRandomNum.Minimum = 1

$chkMoreRandomness = New-Object System.Windows.Forms.Checkbox
$chkMoreRandomness.AutoSize = $true
$chkMoreRandomness.Width = 120
$chkMoreRandomness.Height = 30
$chkMoreRandomness.Text = 'More Randomness'
$chkMoreRandomness.Location = New-Object System.Drawing.Point(275, 245)

$lblBuildSpeed = New-Object System.Windows.Forms.Label
$lblBuildSpeed.width = 50
$lblBuildSpeed.height = 30
$lblBuildSpeed.location = New-Object System.Drawing.Point(10, 290)
$lblBuildSpeed.Text = 'Build Speed'

$sldBuildSpeed = New-Object System.Windows.Forms.Trackbar
$sldBuildSpeed.AutoSize = $true
$sldBuildSpeed.Text = 'Build Speed'
$sldBuildSpeed.width = 200
$sldBuildSpeed.Height = 30
$sldBuildSpeed.location = New-Object System.Drawing.Point(60, 290)
$sldBuildSpeed.Maximum = 250
$sldBuildSpeed.Minimum = 0
$sldBuildSpeed.TickFrequency = 10
$sldBuildSpeed.TickStyle = 2
$sldBuildSpeed.Orientation = 0

$sldBuildSpeedNum = New-Object System.Windows.Forms.NumericUpDown
$sldBuildSpeedNum.width = 45
$sldBuildSpeedNum.Height = 25
$sldBuildSpeedNum.Location = New-Object System.Drawing.Point(270, 290)
$sldBuildSpeedNum.Maximum = 250
$sldBuildSpeedNum.Minimum = 0

##########################
#Solve Settings controls #
##########################
$chkDrawSol = New-Object System.Windows.Forms.Checkbox
$chkDrawSol.AutoSize = $true
$chkDrawSol.Width = 25
$chkDrawSol.Height = 25
$chkDrawSol.Text = 'Draw while solving'
$chkDrawSol.Location = New-Object System.Drawing.Point(10, 10)

$lblSolveSpeed = New-Object System.Windows.Forms.Label
$lblSolveSpeed.width = 50
$lblSolveSpeed.height = 30
$lblSolveSpeed.location = New-Object System.Drawing.Point(10, 40)
$lblSolveSpeed.Text = 'Speed'

$sldSolveSpeed = New-Object System.Windows.Forms.Trackbar
$sldSolveSpeed.AutoSize = $true
$sldSolveSpeed.Text = 'Speed'
$sldSolveSpeed.width = 200
$sldSolveSpeed.Height = 30
$sldSolveSpeed.location = New-Object System.Drawing.Point(60, 40)
$sldSolveSpeed.Maximum = 250
$sldSolveSpeed.Minimum = 0
$sldSolveSpeed.TickFrequency = 10
$sldSolveSpeed.TickStyle = 2
$sldSolveSpeed.Orientation = 0

$sldSolveSpeedNum = New-Object System.Windows.Forms.NumericUpDown
$sldSolveSpeedNum.width = 45
$sldSolveSpeedNum.Height = 25
$sldSolveSpeedNum.Location = New-Object System.Drawing.Point(270, 40)
$sldSolveSpeedNum.Maximum = 250
$sldSolveSpeedNum.Minimum = 0

$lblSolveAlgoritm = New-Object System.Windows.Forms.Label
$lblSolveAlgoritm.AutoSize = $true
$lblSolveAlgoritm.width = 70
$lblSolveAlgoritm.height = 30
$lblSolveAlgoritm.TextAlign = 16 #MiddleLeft
$lblSolveAlgoritm.location = New-Object System.Drawing.Point(10, 85)
$lblSolveAlgoritm.Text = 'Solve Algoritm'

$cmbSolveAlgoritm = New-Object System.Windows.Forms.ComboBox
$cmbSolveAlgoritm.Width = 125
$cmbSolveAlgoritm.Height = 30
$cmbSolveAlgoritm.AutoSize = $true
$cmbSolveAlgoritm.DropDownStyle = 2
$cmbSolveAlgoritm.AutoCompleteMode = 0
$cmbSolveAlgoritm.location = New-Object System.Drawing.Point(95, 85)
For ($i = 0; $i -lt $Script:SolveAlgoritms.count; $i++) {
    [void]$cmbSolveAlgoritm.items.Add($Script:SolveAlgoritms[$i])
    If ($Script:SolveAlgoritms[$i] -eq $Script:SolveAlgoritm) { $Script:SolveAlgoritmIndex = $i }
}
$cmbSolveAlgoritm.SelectedIndex = $Script:SolveAlgoritmIndex

$chkDeadEndFill = New-Object System.Windows.Forms.Checkbox
$chkDeadEndFill.AutoSize = $true
$chkDeadEndFill.Checked = $Script:DeadEndFilling
$chkDeadEndFill.Width = 25
$chkDeadEndFill.Height = 25
$chkDeadEndFill.Text = 'Dead End Filling'
$chkDeadEndFill.Location = New-Object System.Drawing.Point(10, 110)

$btnOk = New-Object System.Windows.Forms.Button
$btnOk.Height = 30
$btnok.width = 100
$btnOk.AutoSize = $true
$btnOk.Location = New-Object System.Drawing.Point(10, 360)
$btnOk.Text = 'Ok'

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Width = 100
$btnApply.Height = 30
$btnApply.AutoSize = $true
$btnApply.Location = New-Object System.Drawing.Point(150, 360)
$btnApply.Text = 'Apply'

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Width = 100
$btnCancel.Height = 30
$btnCancel.AutoSize = $true
$btnCancel.Location = New-Object System.Drawing.Point(290, 360)
$btnCancel.Text = 'Cancel'

$FrmLabyrinthian.controls.AddRange(@(
        $BtnCreateLabyrinth, $BtnSolveLabyrinth, $BtnSettings, $prgCalc, $lblCalc
    ))
#Tab controls for settings page
$tabSettings = New-Object System.Windows.Forms.TabControl
$tabSettings.Location = New-Object System.Drawing.Point(0, 0)
$tabSettings.Appearance = 0
$tabSettings.BackColor = '#d3d3d3'
$tabSettings.TabPages.Add('Create')
$tabpageCreate = $tabSettings.Controls[0]
$tabSettings.TabPages.Add('Solve')
$tabpageSolve = $tabSettings.Controls[1]
$tabCreatecontrols = @(
    $chkDrawLab,
    $lblCreateAlgoritm, $cmbCreateAlgoritm,
    $lblStartpoint, $cmbStartpoint,
    $lblFinishpoint, $cmbFinishpoint,
    $sldWidth, $sldwidthNum, $lblWidth,
    $sldHeight, $sldHeightNum, $lblHeight
    $sldRandom, $sldRandomNum, $lblRandom, $chkMoreRandomness,
    $lblBuildSpeed, $sldBuildSpeed, $sldBuildSpeedNum
)
$tabSolvecontrols = @(
    $chkDrawSol,
    $sldSolveSpeed, $sldSolveSpeedNum, $lblSolveSpeed,
    $lblSolveAlgoritm, $cmbSolveAlgoritm,
    $chkDeadEndFill
)

foreach ($tabcreatecontrol in $tabcreatecontrols) { $tabpageCreate.Controls.Add($tabcreatecontrol) }
foreach ($tabSolvecontrol in $tabSolvecontrols) { $tabpageSolve.Controls.Add($tabSolvecontrol) }

$FrmLabyrinthianSettings = New-Object system.Windows.Forms.Form
$FrmLabyrinthianSettings.BackColor = '#d3d3d3'
$FrmLabyrinthianSettings.StartPosition = 'Manual'
$FrmLabyrinthianSettings.controls.AddRange(@(
        $tabSettings,
        $btnok, $btnApply, $btnCancel
    ))

Function ShowSettings() {
    $FrmLabyrinthianSettings.ClientSize = '400,400'
    $FrmLabyrinthianSettings.text = 'Labyrinth settings'
    $FrmLabyrinthianSettings.TopMost = $true
    $FrmLabyrinthianSettings.FormBorderStyle = 3 #https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.formborderstyle?view=windowsdesktop-6.0
    $FrmLabyrinthianSettings.Showintaskbar = $false
    $FrmLabyrinthianSettings.MinimizeBox = $false
    $FrmLabyrinthianSettings.ControlBox = $false
    
    $tabSettings.Width = $FrmLabyrinthianSettings.Width - 16
    $tabSettings.Height = $FrmLabyrinthianSettings.Height - 90
    
    $chkDrawSol.Checked = $Script:DrawWhileSolving
    $chkDrawLab.Checked = $Script:DrawWhileBuilding
    $chkDeadEndFill.Checked = $Script:DeadEndFilling
    $sldWidth.Value = $Script:SizeX
    $sldwidthNum.value = $Script:SizeX
    $sldHeight.Value = $Script:SizeY
    $sldHeightNum.value = $Script:SizeY
    If ($Script:isCreating -or $Script:isSolving) {
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
    $sldSolveSpeed.Value = $Script:PlayerPause
    $sldSolveSpeedNum.value = $Script:PlayerPause
    $sldBuildSpeed.Value = $Script:BuildPause
    $sldBuildSpeedNum.value = $Script:BuildPause
    $chkMoreRandomness.Checked = $Script:MoreRandomness
    If ($cmbCreateAlgoritm.SelectedItem -eq 'Depth-First') {
        $chkMoreRandomness.Enabled = $true
    } Else {
        $chkMoreRandomness.Enabled = $false
    }
    $sldRandom.Value = $Script:Randomness
    $sldRandomNum.Value = $Script:Randomness
    $cmbCreateAlgoritm.SelectedIndex = $Script:CreateAlgoritmIndex
    $cmbSolveAlgoritm.SelectedIndex = $Script:SolveAlgoritmIndex
    $cmbStartpoint.SelectedIndex = $Script:StartpointIndex
    $cmbFinishpoint.SelectedIndex = $Script:FinishpointIndex 
    $FrmLabyrinthianSettings.StartPosition = 'CenterParent'
    $FrmLabyrinthianSettings.Update()
    $FrmLabyrinthianSettings.ShowDialog()
}
Function SaveSettings {
    Param (
        [Switch]$Apply
    )
    $Script:DrawWhileBuilding = $chkDrawLab.Checked
    $Script:DrawWhileSolving = $chkDrawSol.Checked
    $Script:DeadEndFilling = $chkDeadEndFill.Checked
    $Script:PlayerPause = $sldSolveSpeed.Value
    $Script:BuildPause = $sldBuildSpeed.Value
    If ($Script:SizeX -ne $sldWidth.Value -or $Script:SizeY -ne $sldHeight.Value) {
        $Script:SizeX = $sldWidth.Value
        $Script:SizeY = $sldHeight.Value
        $Script:maxmoves = ($Script:SizeX * $Script:SizeY)
        $BtnSolveLabyrinth.Enabled = $false
    }
    $Script:MoreRandomness = $chkMoreRandomness.Checked
    If ($Script:MoreRandomness) {
        $Script:RandomFactor = $sldRandom.Value
        $Script:RandomNess = $sldRandom.Value
    } Else {
        $Script:RandomNess = $sldRandom.Value
    }
    $Script:Randomness = $sldRandom.Value
    If ($Script:SolveAlgoritm -ne $cmbSolveAlgoritm.SelectedItem) {
        $Script:SolveAlgoritm = $cmbSolveAlgoritm.SelectedItem
        $Script:SolveAlgoritmIndex = $cmbSolveAlgoritm.SelectedIndex
    }
    If ($Script:CreateAlgoritm -ne $cmbCreateAlgoritm.SelectedItem) {
        $Script:CreateAlgoritm = $cmbCreateAlgoritm.SelectedItem 
        $Script:CreateAlgoritmIndex = $cmbCreateAlgoritm.SelectedIndex 
    }
    $Script:Startpoint = $cmbStartpoint.SelectedItem
    $Script:StartpointIndex = $cmbStartpoint.SelectedIndex
    $Script:Finishpoint = $cmbFinishpoint.SelectedItem
    $Script:FinishpointIndex = $cmbFinishpoint.SelectedIndex

}
Function InitLabyrinth() {
    $BtnCreateLabyrinth.Enabled = $false
    $BtnSolveLabyrinth.Enabled = $false
    #Draw stuff prep
    $Script:Graphics = $FrmLabyrinthian.CreateGraphics()
    [System.Collections.ArrayList]$Script:labyrinth = @()
    #$Size =  $Script:SizeX *  $Script:SizeY
    For ($i = 0; $i -lt $Script:SizeX; $i++) {
        $Script:labyrinth += , (@()) 
        For ($o = 0; $o -lt $Script:SizeY; $o++) {
            $Script:labyrinth[$i] += 0
        }
    }
    $prgcalc.width = $FrmLabyrinthian.Width - 225
    ClearLabyrinth
    CreateLabyrinth
    If (-not $Script:DrawWhileBuilding) { DrawLabyrinth }
    $BtnCreateLabyrinth.Enabled = $true
    $BtnSolveLabyrinth.Enabled = $true
}
<#
# Create the Labyrinth
#>
Function CreateLabyrinth () {
    $Script:isCreating = $true
    #determine startingpoint in the maze
    Switch ($Script:Startpoint) {
        'Random' {
            $x = Get-Random -Minimum 1 -Maximum ($Script:SizeX - 1)
            $y = Get-Random -Minimum 1 -Maximum ($Script:SizeY - 1)
        }
        'Center' {
            $x = [math]::Round(($Script:SizeX - 1) / 2)
            $y = [math]::Round(($Script:SizeY - 1) / 2)
        }
        'Top-Left' {
            $x = 0
            $y = 0
        }
        'Top-Right' {
            $x = $Script:SizeX - 1
            $y = 0
        }
        'Bottom-Right' {
            $x = $Script:SizeX - 1
            $y = $Script:SizeY - 1
        }
        'Bottom-Left' {
            $x = 0
            $y = $Script:SizeY - 1
        }
        default {
            Write-Host "$Script:startpoint not in set"
        }
    }
    $Script:Start = @($x, $y)
    $Script:labyrinth[$x][$y] = 256 #start
    $pointer = 0
    $progress = 0
    $pointermax = 0
    $prgcalc.Minimum = 0
    $prgCalc.Maximum = $Script:SizeX * $Script:SizeY
    [System.Collections.ArrayList]$moved = @()
    [System.Collections.ArrayList]$Script:endpoints = @()
    $previousmove = 0
    Switch ($Script:CreateAlgoritm) {
        'Depth-First' {
            $moved.add("$x,$y")
            If ($Script:DrawWhileBuilding) { DrawExplorer -x $x -y $y }
            While ($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If (($y -gt 0) -and ($Script:labyrinth[$x][$y - 1] -eq 0)) {
                    $posDir.Add(@($Script:labyrinth[$x][$y - 1], $x, ($y - 1), 1)) #Up
                } #up
                If (($y -lt ( $Script:SizeY - 1)) -and ($Script:labyrinth[$x][$y + 1] -eq 0 )) {
                    $posDir.Add(@(($Script:labyrinth[$x][$y + 1]), $x, ($y + 1), 2)) #Down
                } #down
                If (($x -gt 0) -and ($Script:labyrinth[$x - 1][$y] -eq 0)) {
                    $posDir.Add(@(($Script:labyrinth[$x - 1][$y]), ($x - 1), $y, 4)) #left
                }  #left
                If (($x -lt ( $Script:SizeX - 1)) -and ($Script:labyrinth[$x + 1][$y] -eq 0)) {
                    $posDir.Add(@(($Script:labyrinth[$x + 1][$y]), ($x + 1), $y, 8))#right
                } #right
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) {
                    $movedetection = $posdir | Where-Object { $_[3] -eq $previousmove }
                    If ($null -eq $movedetection) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } Elseif ((Get-Random -Minimum 0 -Maximum $Script:Randomness) -eq 0) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    }
                    $previousmove = $movedetection[3]
                    $Script:labyrinth[$x][$y] += $movedetection[3] ## Build door
                    $moved.Add("$x,$y")
                    $pointer = $moved.count
                    $x = $movedetection[1]
                    $y = $movedetection[2]
                    Switch ($movedetection[3]) {
                        1 { $value = 2 }
                        2 { $value = 1 }
                        4 { $value = 8 }
                        8 { $value = 4 }
                    }                     ## Door to the other side
                    $Script:labyrinth[$x][$y] += $value
                    #Write-host "Step $pointer = Moved to $x $y"
                    $prgCalc.Value = $progress
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Script:BuildPause
                    }
                    $progress++
                } ElseIf ($pointer -gt $pointermax) {
                    $pointermax = $pointer + 1
                    $Script:endpoints.Add(@($x, $y))
                    If (($x -lt $Script:SizeX) -and ($x -gt 0) -and ($y -gt 0) -and ($y -lt $Script:SizeY) -and $Script:gaps) {
                        $Script:labyrinth[$x][$y] += $previousmove
                    }
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Script:BuildPause
                    }
                    If ($Script:MoreRandomness) {
                        $Script:Randomness = (Get-Random -Minimum 1 -Maximum ($Script:RandomFactor + 1))
                    }
                } Else {
                    $pointer--
                    $x = [int](($moved[$pointer]).Split(','))[0]
                    $y = [int](($moved[$pointer]).Split(','))[1]
                    #Write-host "Step $pointer = New scan at $x $y"
                }
            }
        }
        'Prim' {
            $moved.add("$x,$y")
            If ($Script:DrawWhileBuilding) { DrawExplorer -x $x -y $y }
            While ($pointer -ge 0) {
                [System.Collections.ArrayList]$posDir = @()
                If (($y -gt 0) -and ($Script:labyrinth[$x][$y - 1] -eq 0)) {
                    $posDir.Add(@($Script:labyrinth[$x][$y - 1], $x, ($y - 1), 1)) #Up
                } #up
                If (($y -lt ( $Script:SizeY - 1)) -and ($Script:labyrinth[$x][$y + 1] -eq 0 )) {
                    $posDir.Add(@(($Script:labyrinth[$x][$y + 1]), $x, ($y + 1), 2)) #Down
                } #down
                If (($x -gt 0) -and ($Script:labyrinth[$x - 1][$y] -eq 0)) {
                    $posDir.Add(@(($Script:labyrinth[$x - 1][$y]), ($x - 1), $y, 4)) #left
                }  #left
                If (($x -lt ( $Script:SizeX - 1)) -and ($Script:labyrinth[$x + 1][$y] -eq 0)) {
                    $posDir.Add(@(($Script:labyrinth[$x + 1][$y]), ($x + 1), $y, 8))#right
                } #right
                $numofposdir = $posdir.Count
                If ($numofposdir -ne 0) { 
                    $movedetection = $posdir | Where-Object { $_[3] -eq $previousmove }
                    If ($null -eq $movedetection) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } Elseif ((Get-Random -Minimum 0 -Maximum $Script:Randomness) -eq 0) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } ##Random direction if Randomness low
                    $previousmove = $movedetection[3]
                    $Script:labyrinth[$x][$y] += $movedetection[3]  ## Build door
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                    }
                    $x = $movedetection[1]
                    $y = $movedetection[2]
                    Switch ($movedetection[3]) {
                        1 { $value = 2 }
                        2 { $value = 1 }
                        4 { $value = 8 }
                        8 { $value = 4 }
                    }
                    $Script:labyrinth[$x][$y] += $value                     ## Door to the other side
                    $moved.add("$x,$y")
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Script:BuildPause
                    }
                    $pointer++
                    #Write-host "Step $pointer = Moved to $x $y"
                    $prgCalc.Value = $progress
                    If ($Script:Randomness -gt 1) {
                        If ((Get-Random -Minimum 0 -Maximum $Script:Randomness) -ne 0) {
                            $nextspot = $moved[($moved.count) - 1] 
                        } Else {
                            $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count) - 1))] 
                        }
                    } Else {
                        $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count) - 1))] 
                    }
                    $x = [int]($nextspot.split(',')[0])
                    $y = [int]($nextspot.split(',')[1])
                    $progress++
                } Elseif ($pointer -le 1) {
                    $pointer--
                } Else {
                    $compare = $Script:labyrinth[$x][$y] -band 15
                    If ($compare -eq 1 -or $compare -eq 2 -or $compare -eq 4 -or $compare -eq 8) {
                        $Script:endpoints.Add(@($x, $y))
                    }
                    $pointer--
                    $moved.RemoveAt($moved.indexof("$x,$y"))
                    $nextspot = $moved[(Get-Random -Minimum 0 -Maximum (($moved.count) - 1))] 
                    $x = [int]($nextspot.split(',')[0])
                    $y = [int]($nextspot.split(',')[1])
                    #Write-host "Step $pointer = New scan at $x $y"
                }
            }
        }
        'Wilson' {
            [System.Collections.ArrayList]$notmoved = @()
            For ($xx = 0; $xx -lt $Script:SizeX; $xx++) {
                For ($yy = 0; $yy -lt $Script:SizeY; $yy++) {
                    $notmoved.Add("$xx,$yy")
                }
            }
            #Add start to set Moved)
            $moved.add("$x,$y")
            $notmoved.RemoveAt($notmoved.indexof("$x,$y"))
            #get random point from all non-moved
            $index = Get-Random -Minimum 0 -Maximum $notmoved.Count
            $x = [int](($notmoved[$index]).split(',')[0])
            $y = [int](($notmoved[$index]).split(',')[1])
            $pointer++
            [System.Collections.ArrayList]$movedcache = @()
            #While ($pointer -lt $Script:maxmoves) {
            While ($notmoved.count -gt 0) {
                [System.Collections.ArrayList]$posDir = @()
                $u = $y - 1; $d = $y + 1; $l = $x - 1; $r = $x + 1
                If ($null -ne ($moved | Where-Object { $_ -eq "$x,$u" })) {
                    $posDir.Add(@($Script:labyrinth[$x][$u], $x, $u, 1)) #Up
                }
                If ($null -ne ($moved | Where-Object { $_ -eq "$x,$d" })) {
                    $posDir.Add(@($Script:labyrinth[$x][$d], $x, $d, 2)) #Down
                }
                If ($null -ne ($moved | Where-Object { $_ -eq "$l,$y" })) {
                    $posDir.Add(@($Script:labyrinth[$l][$y], $l, $y, 4)) #Left
                }
                If ($null -ne ($moved | Where-Object { $_ -eq "$r,$y" })) {
                    $posDir.Add(@($Script:labyrinth[$r][$y], $r, $y, 8)) #Right
                }
                If ($posdir.count -ge 1) {
                    $connected = $true
                } Else {
                    If (($y -gt 0) -and ($Script:labyrinth[$x][$y - 1] -eq 0)) {
                        $posDir.Add(@($Script:labyrinth[$x][$y - 1], $x, ($y - 1), 1)) #Up
                    } #up
                    If (($y -lt ( $Script:SizeY - 1)) -and ($Script:labyrinth[$x][$y + 1] -eq 0 )) {
                        $posDir.Add(@(($Script:labyrinth[$x][$y + 1]), $x, ($y + 1), 2)) #Down
                    } #down
                    If (($x -gt 0) -and ($Script:labyrinth[$x - 1][$y] -eq 0)) {
                        $posDir.Add(@(($Script:labyrinth[$x - 1][$y]), ($x - 1), $y, 4)) #left
                    }  #left
                    If (($x -lt ( $Script:SizeX - 1)) -and ($Script:labyrinth[$x + 1][$y] -eq 0)) {
                        $posDir.Add(@(($Script:labyrinth[$x + 1][$y]), ($x + 1), $y, 8))#right
                    } #right
                }
                $numofposdir = $posdir.Count
                If ($numofposdir -gt 0) {
                    $movedetection = $posdir | Where-Object { $_[3] -eq $previousmove }
                    If ($null -eq $movedetection) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    } Elseif ((Get-Random -Minimum 0 -Maximum $Script:Randomness) -eq 0) {
                        $movedetection = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
                    }
                    $previousmove = $movedetection[3]
                    $movedcache.add("$x,$y")
                    $notmoved.RemoveAt($notmoved.indexof("$x,$y"))
                    $Script:labyrinth[$x][$y] += $movedetection[3] ## Build door
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Script:BuildPause
                    }
                    $x = $movedetection[1]
                    $y = $movedetection[2]
                    Switch ($movedetection[3]) {
                        1 { $value = 2 }
                        2 { $value = 1 }
                        4 { $value = 8 }
                        8 { $value = 4 }
                    }
                    $Script:labyrinth[$x][$y] += $value                     ## Door to the other side
                    If ($connected -and ($notmoved.count -gt 0)) {
                        $pointer += $movedcache.count
                        $moved += $movedcache
                        [System.Collections.ArrayList]$movedcache = @()
                        $index = Get-Random -Minimum 0 -Maximum ($notmoved.Count)
                        $x = [int](($notmoved[$index]).split(',')[0])
                        $y = [int](($notmoved[$index]).split(',')[1])
                        $connected = $false
                    } Else {
                        #$movedcache.add("$x,$y")
                        #$notmoved.RemoveAt($notmoved.indexof("$x,$y"))
                    }
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                        Start-Sleep -Milliseconds $Script:BuildPause
                    }
                } Else {
                    $movedcache.add("$x,$y")
                    $notmoved.RemoveAt($notmoved.indexof("$x,$y"))
                    $script:Endpoints.add(@([int]($movedcache[0]).split(',')[0],[int]($movedcache[0]).split(',')[1]))
                    $pointer -= $movedcache.count
                    $notmoved += $movedcache
                    ForEach ($loc in $movedcache) {
                        $x = [int]($loc.split(',')[0])
                        $y = [int]($loc.split(',')[1])
                        $Script:labyrinth[$x][$y] = 0
                        If ($Script:DrawWhileBuilding) {
                            DrawExplorer -x $x -y $y
                        }
                    }
                    [System.Collections.ArrayList]$movedcache = @()
                    If ($Script:DrawWhileBuilding) {
                        DrawExplorer -x $x -y $y
                    }
                }
                $prgCalc.Value = ($global:maxmoves -($notmoved.count))
            }
        }
        'Eller-ip' {
            While ($Workingrow -le $Script:SizeY) {
                $WorkingRow++
            }
        }
        default {
            #Default empty labyrinth
            For ($x = 0; $x -lt $Script:SizeX; $x++) {
                For ($y = 0; $y -lt $Script:SizeY; $y++) {
                    If ($x -eq 0) { $Script:labyrinth[$x][$y] += 8 }
                    If ($x -eq ($Script:SizeX - 1)) { $Script:labyrinth[$x][$y] += 4 }
                    If ($y -eq 0) { $Script:labyrinth[$x][$y] += 2 }
                    If ($y -eq ($Script:SizeY - 1)) { $Script:labyrinth[$x][$y] += 1 }
                    $compare = $Script:labyrinth[$x][$y] -band 15
                    Switch ($compare) {
                        0 { $Script:labyrinth[$x][$y] += 15 }
                        1 { $Script:labyrinth[$x][$y] += 12 }
                        2 { $Script:labyrinth[$x][$y] += 12 }
                        4 { $Script:labyrinth[$x][$y] += 3 }
                        8 { $Script:labyrinth[$x][$y] += 3 }
                        default { $Script:endpoints.Add(@($x, $y)) }
                    }
                    If ($Script:DrawWhileBuilding) { DrawExplorer -x $x -y $y }
                }
            }
            Write-Host "$Script:CreateAlgoritm not yet implemented"
        }
    }
    #End point placing
    If ($Script:endpoints.count -gt 0) {
        Switch ($Script:Finishpoint) {
            'Endpoint Far' {
                $maxdistance = 0
                ForEach ($endpoint in $Script:endpoints) {
                    $distance = [math]::abs(($endpoint[0] + $endpoint[1]) - ($Script:start[0] + $Script:start[1]))
                    If ($distance -gt $maxdistance) {
                        $maxdistance = $distance 
                        $Script:Finish = $endpoint
                    }
                }
            }
            'Endpoint Random' {
                $endpoint = $Script:endpoints[(Get-Random -Minimum 0 -Maximum ($Script:endpoints.Count - 1))]
                $Script:Finish = @($endpoint[0], $endpoint[1])
            }
            'Endpoint Last' {
                $Script:Finish = $Script:endpoints[($Script:endpoints.Count - 1)]
            }
            'Endpoint First' {
                $Script:Finish = $Script:endpoints[0]
            }
            'Center' {
                $Script:Finish = @([math]::Round(($Script:SizeX - 1) / 2), [math]::Round(($Script:SizeY - 1) / 2))
            }
            'Random' {
                $Script:Finish = @((Get-Random -Minimum 0 -Maximum ($Script:SizeX - 1)), (Get-Random -Minimum 0 -Maximum ($Script:SizeY - 1)))
            }
            'Top-Left' { $Script:Finish = @(0, 0) }
            'Top-Right' { $Script:Finish = @(($Script:SizeX - 1), 0) }
            'Bottom-Right' { $Script:Finish = @(($Script:SizeX - 1), ($Script:SizeY - 1)) }
            'Bottom-Left' { $Script:Finish = @(0, ($Script:SizeY - 1)) }
        }
    } Else {
        $Script:Finish = $Script:Start #Create 1 pixel labyrinth
    }
    $removespot = $Script:endpoints | Where-Object { $_[0] -eq $Script:Finish[0] -and $_[1] -eq $Script:Finish[1] }
    $Script:endpoints.Remove($removespot)
    $Script:labyrinth[$Script:Finish[0]][$Script:Finish[1]] = 512 #finish
    If ($Script:DrawWhileBuilding) { DrawExplorer -x $Script:Finish[0] -y $Script:Finish[1] }
    $Script:FirstSolve = $true
    $Script:isCreating = $false
}
<#
# Solve the Labyrinth
#>
Function SolveLabyrinth {
    Param ()
    $Script:isSolving = $true
    $Script:moves = 0
    $Script:maxmoves = ($Script:SizeX * $Script:SizeY)
    #Clear breadcrumbs
    For ($i = 0; $i -lt $Script:SizeX; $i++) {
        For ($o = 0; $o -lt $Script:SizeY; $o++) {
            $breadcrumb = ($Script:labyrinth[$i][$o]) -band 240
            If ($breadcrumb -ne 0) {
                $Script:labyrinth[$i][$o] -= $breadcrumb #remove breadcrumbs
            }
        }
    }
    #ClearLabyrinth
    If ($Script:ClearLabBeforeSolving -and -not $Script:FirstSolve) { DrawLabyrinth }
    $Script:FirstSolve = $false
    #Write-host "$Script:start $Script:finish"
    If (($Script:DeadEndFilling) -and ($Script:endpoints.count -gt 0)) {
        $prgCalc.Maximum = $Script:endpoints.count
        $i = 0
        $previouslocationX = -1
        $previouslocationY = -1
        ForEach ($endpoint in $Script:endpoints) {
            [System.Collections.ArrayList]$posDir = @()
            $posdir.add($endpoint)
            Do {
                #Fill with bread crumb
                $movechoice = $posDir[0]
                $x = $movechoice[0]
                $y = $movechoice[1]
                [System.Collections.ArrayList]$posDir = @()
                If (($Script:labyrinth[$x][$y] -band 769) -eq 1 -and -not (($x -eq $previouslocationX) -and (($y - 1) -eq $previouslocationY))) { $posdir.add(@($x, ($y - 1), 32)) }
                If (($Script:labyrinth[$x][$y] -band 770) -eq 2 -and -not (($x -eq $previouslocationX) -and (($y + 1) -eq $previouslocationY))) { $posdir.add(@($x, ($y + 1), 16)) }
                If (($Script:labyrinth[$x][$y] -band 772) -eq 4 -and -not ((($x - 1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) { $posdir.add(@(($x - 1), $y, 128)) }
                If (($Script:labyrinth[$x][$y] -band 776) -eq 8 -and -not ((($x + 1) -eq $previouslocationX) -and ($y -eq $previouslocationY))) { $posdir.add(@(($x + 1), $y, 64)) }
                $numofposdir = $posdir.Count
                If ($numofposdir -eq 1) {
                    $Script:labyrinth[$x][$y] += 240
                    $previouslocationX = $x
                    $previouslocationY = $y
                    If ($Script:DrawWhileSolving) {
                        DrawExplorer -x $x -y $y
                        #Start-Sleep -Milliseconds $Script:PlayerPause
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
    $x = $Script:start[0]
    $y = $Script:start[1]
    $Progress = 1
    $progressmax = 1
    $prgCalc.Value = $Script:moves
    $prgCalc.Maximum = $Script:maxmoves
    [System.Collections.ArrayList]$moved = @()
    $moved.Add(@($x, $y))
    $previousDirection = 0 
    While (($Script:labyrinth[$x][$y] -band 512) -ne 512) {
        [System.Collections.ArrayList]$posDir = @()
        If (($Script:labyrinth[$x][$y] -band 1) -eq 1 -and (($Script:labyrinth[$x][($y - 1)] -band 240) -eq 0)) { $posdir.add(@($x, ($y - 1), 16)) }
        If (($Script:labyrinth[$x][$y] -band 2) -eq 2 -and (($Script:labyrinth[$x][($y + 1)] -band 240) -eq 0)) { $posdir.add(@($x, ($y + 1), 32)) }
        If (($Script:labyrinth[$x][$y] -band 4) -eq 4 -and (($Script:labyrinth[($x - 1)][$y] -band 240) -eq 0)) { $posdir.add(@(($x - 1), $y, 64)) }
        If (($Script:labyrinth[$x][$y] -band 8) -eq 8 -and (($Script:labyrinth[($x + 1)][$y] -band 240) -eq 0)) { $posdir.add(@(($x + 1), $y, 128)) }
        $numofposdir = $posdir.Count
        If ($Script:moves -lt $Script:maxmoves) {
            $Script:moves++
            $prgCalc.Value = $Script:moves
        }
        If ($numofposdir -ne 0) {
            #Search Algoritms
            Switch ($Script:SolveAlgoritm) {
                'Follow-Wall' {
                    Switch ($previousDirection) {
                        16 {
                            $movechoice = $posDir | Where-Object { $_[2] -eq 64 }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 16 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 128 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 32 } }
                        }
                        32 {
                            $movechoice = $posDir | Where-Object { $_[2] -eq 128 }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 32 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 64 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 16 } }
                        }
                        64 {
                            $movechoice = $posDir | Where-Object { $_[2] -eq 32 }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 64 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 16 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 128 } }
                        }
                        128 {
                            $movechoice = $posDir | Where-Object { $_[2] -eq 16 }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 128 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 32 } }
                            If ($null -eq $movechoice) { $movechoice = $posDir | Where-Object { $_[2] -eq 64 } }
                        }
                        default { $movechoice = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))] }
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
                    $difmin = $Script:maxmoves
                    For ($i = 0; $i -lt $numofposdir; $i++) {
                        $difx = [math]::abs(($posdir[$i])[0] - $Script:Finish[0])
                        $dify = [math]::abs(($posdir[$i])[1] - $Script:Finish[1])
                        $dif = [math]::Sqrt(($difx * $difx) + ($dify * $dify))
                        If ($dif -le $difmin) {
                            $difmin = $dif
                            $choice = $i
                        }
                    }
                    #Write-Host "$difx - $dify - $dif - $difmin"
                    $movechoice = $posDir[$choice]
                    $direction = $movechoice[2]
                }
                default {
                    $movechoice = $Script:Finish
                    Write-Host "$Script:SolveAlgoritm not implemented"
                }
            }
            $Script:labyrinth[$x][$y] -= ($Script:labyrinth[$x][$y] -band 240)
            $Script:labyrinth[$x][$y] += $direction
            $Previousdirection = $direction
            If ($Script:DrawWhileSolving) {
                $Script:labyrinth[$x][$y] += 1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $Script:PlayerPause
                DrawExplorer -x $x -y $y
            }
            $x = $movechoice[0]
            $y = $movechoice[1]
            $Script:labyrinth[$x][$y] += 240
            $moved.Add(@($x, $y))
            $progress = $moved.count - 1
            #Write-host "New route: " -NoNewline
        } ElseIf ($progress -gt $progressmax) {
            $progressmax = $Progress + 1
            $Script:labyrinth[$x][$y] += 240 - ($Script:labyrinth[$x][$y] -band 240)
            If ($Script:DrawWhileSolving) {
                $Script:labyrinth[$x][$y] += 1024
                DrawExplorer -x $x -y $y
                Start-Sleep -Milliseconds $Script:PlayerPause
                DrawExplorer -x $x -y $y
            }
            #Write-host "Deadend at $x $y"
        } Else {
            $Progress--
            $Script:moves--
            If (($Script:labyrinth[$x][$y] -band 240) -ne 240) {
                $Script:labyrinth[$x][$y] += 240 - ($Script:labyrinth[$x][$y] -band 240)
                If ($Script:DrawWhileSolving) {
                    $Script:labyrinth[$x][$y] += 1024
                    DrawExplorer -x $x -y $y
                    Start-Sleep -Milliseconds $Script:PlayerPause
                    DrawExplorer -x $x -y $y
                }
            }
            $x = $moved[$progress][0]
            $y = $moved[$progress][1]
            #Write-host "Backtrack: " -NoNewline
        }
        #Write-host "$x $y"
    }
    #$Script:labyrinth[$x][$y]-=64
    $prgCalc.Value = $Script:maxmoves
    If (-not $Script:DrawWhileSolving) { DrawLabyrinth }
    #Write-Log "$Script:CreateAlgoritm - $Script:SolveAlgoritm - moves: $Script:moves"
    $Script:isSolving = $false
}
Function ClearLabyrinth () {
    #$FrmLabyrinthian.Refresh()
    $Script:brushb = New-Object Drawing.SolidBrush Gray
    $Script:Graphics = $FrmLabyrinthian.CreateGraphics()
    $Script:Graphics.FillRectangle($Script:brushb, 0, 0, $FrmLabyrinthian.Width, $FrmLabyrinthian.Height)
    #$FrmLabyrinthian.Update()
}
Function DrawExplorer {
    Param (
        $x,
        $y
    )
    $offsetx = 25
    $offsety = 25
    $ScaleX = (($FrmLabyrinthian.Width - ($offsetx * 2)) / $Script:SizeX)
    $ScaleY = ((($FrmLabyrinthian.Height - 25) - ($offsety * 2)) / $Script:SizeY)
    $RoomScaleX = 0.75
    $RoomScaleY = 0.75
    $RoomSizeX = $ScaleX * $RoomScaleX
    $RoomsizeY = $Scaley * $RoomScaleY
    $RoomScaleXX = 1 - $RoomScaleX
    $RoomScaleYY = 1 - $RoomScaleY
    If ((($Script:labyrinth[$x][$y] -band 240) -ne 0) -and (($Script:labyrinth[$x][$y] -band 240) -ne 240)) {
        Switch ($Script:labyrinth[$x][$y]) {
            { (16 -band $_) -eq 16 } {
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, ((($y) - $RoomScaleYY) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (32 -band $_) -eq 32 } {
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, ((($y) + $RoomScaleYY) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (64 -band $_) -eq 64 } {
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushr, ((($x) - $RoomScaleXX) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (128 -band $_) -eq 128 } {
                $Script:Graphics.FillRectangle($Script:brushr, (($x) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushr, ((($x) + $RoomScaleXX) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            #Player
            { (1024 -band $_) -eq 1024 } {
                $Script:Graphics.FillRectangle($Script:brushPlayer, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:labyrinth[$x][$y] -= 1024
            }
        }
    } Else {
        Switch ($Script:labyrinth[$x][$y]) {
            0 {
                $Script:Graphics.FillRectangle($Script:brushb, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, $ScaleX, $scaleY)
            }
            { (1 -band $_) -eq 1 } {
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, (($y - 0.25) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (2 -band $_) -eq 2 } {
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, (($y + 0.25) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (4 -band $_) -eq 4 } {
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushw, (($x - 0.25) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            { (8 -band $_) -eq 8 } {
                $Script:Graphics.FillRectangle($Script:brushw, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
                $Script:Graphics.FillRectangle($Script:brushw, (($x + 0.25) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
        }
        Switch ($Script:labyrinth[$x][$y]) {
            #Breadcrumbs
            { (240 -band $_) -eq 240 } {
                $Script:Graphics.FillRectangle($Script:brushBC, (($x) * $scalex) + $offsetx, (($y) * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            #Start
            { (256 -band $_) -eq 256 } {
                $Script:Graphics.FillRectangle($Script:brushg, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
            #Finish
            { (512 -band $_) -eq 512 } {
                $Script:Graphics.FillRectangle($Script:brushfin, ($x * $scalex) + $offsetx, ($y * $scaleY) + $offsety, ($RoomSizeX), ($RoomsizeY))
            }
        }
    }
    $FrmLabyrinthian.Update()
    [System.Windows.Forms.Application]::DoEvents()
}
Function DrawLabyrinth {    
    Param ()
    For ($y = 0; $y -lt $Script:SizeY; $y++) { 
        For ($x = 0; $x -lt $Script:SizeX; $x++) {
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
$sldwidthNum.Add_ValueChanged({ ChangeSizeXNum })
$sldHeight.Add_Scroll({ ChangeSizeY })
$sldHeightNum.Add_ValueChanged({ ChangeSizeYNum })
$sldSolveSpeed.Add_Scroll({ ChangeSolveSpeed })
$sldSolveSpeedNum.Add_ValueChanged({ ChangeSolveSpeedNum })
$sldBuildSpeed.Add_Scroll({ ChangeBuildSpeed })
$sldBuildSpeedNum.Add_ValueChanged({ ChangeBuildSpeedNum })
$sldRandom.Add_Scroll({ ChangeRandom })
$sldRandomNum.Add_ValueChanged({ ChangeRandomNum })

$FrmLabyrinthian.Add_ResizeEnd({
        $Script:FrmSizeX = $FrmLabyrinthian.Width
        $Script:FrmSizeY = $FrmLabyrinthian.Height
        ClearLabyrinth
        DrawLabyrinth
        $prgCalc.width = $FrmLabyrinthian.width - 225 })
$FrmLabyrinthian.Add_SizeChanged({
        If ($FrmLabyrinthian.WindowState -ne 'Normal' -or $Script:PreviousState -ne 'Normal') {
            ClearLabyrinth; DrawLabyrinth; $prgCalc.width = $FrmLabyrinthian.width - 225
            $Script:PreviousState = $FrmLabyrinthian.WindowState
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
        If ($timTimer.Enabled) {
            $timTimer.Stop()
            $timTimer.Enabled = $false
        } Else {
            $timTimer.Enabled = $true
            $timTimer.Start()
            $Script:timerticks = 0
        }
    })
$cmbCreateAlgoritm.Add_SelectedIndexChanged({
        If ($cmbCreateAlgoritm.SelectedItem -eq 'Depth-First') {
            $chkMoreRandomness.Enabled = $true
        } Else {
            $chkMoreRandomness.Enabled = $false
        }
    })
$timTimer.Add_Tick({
        If ($Script:isSolving) {
            $lblCalc.ForeColor = 'Red'
            $lblCalc.Text = $Script:moves
        } Else {
            Switch ($Script:timerticks) {
                0 { $lblCalc.ForeColor = 'Black'; $lblCalc.Text = $Script:CreateAlgoritm }
                1 { $lblCalc.ForeColor = 'Black'; $lblCalc.Text = $Script:SolveAlgoritm }
                2 { $lblCalc.ForeColor = 'GreenYellow'; $lblCalc.Text = $Script:maxmoves }
                3 { $lblCalc.ForeColor = 'Red'; $lblCalc.Text = $Script:moves }
                Default { $Script:timerticks = -1 }
            }
            $Script:timerticks++
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
[void](New-Item -Path $RegKeyPath -Force)
[void](Set-Item -Path $RegKeyPath -Value 'Labyrinthian keys')
#Save settings to registry
[void](New-ItemProperty -Path $RegKeyPath -Name FRMSizeX -PropertyType Dword -Value $Script:FrmSizeX)
[void](New-ItemProperty -Path $RegKeyPath -Name FRMSizeY -PropertyType Dword -Value $Script:FrmSizeY)
[void](New-ItemProperty -Path $RegKeyPath -Name SizeX -PropertyType Dword -Value $Script:SizeX)
[void](New-ItemProperty -Path $RegKeyPath -Name SizeY -PropertyType Dword -Value $Script:SizeY)
[void](New-ItemProperty -Path $RegKeyPath -Name DrawWhileBuilding -PropertyType Dword -Value $Script:DrawWhileBuilding)
[void](New-ItemProperty -Path $RegKeyPath -Name BuildPause -PropertyType Dword -Value $Script:BuildPause)
[void](New-ItemProperty -Path $RegKeyPath -Name Randomness -PropertyType Dword -Value $Script:Randomness)
[void](New-ItemProperty -Path $RegKeyPath -Name MoreRandomness -PropertyType Dword -Value $Script:MoreRandomness)
[void](New-ItemProperty -Path $RegKeyPath -Name RandomnessFactor -PropertyType Dword -Value $Script:RandomFactor)
[void](New-ItemProperty -Path $RegKeyPath -Name CreateAlgoritmIndex -PropertyType Dword -Value $Script:CreateAlgoritmIndex)
[void](New-ItemProperty -Path $RegKeyPath -Name StartpointIndex -PropertyType Dword -Value $Script:StartpointIndex)
[void](New-ItemProperty -Path $RegKeyPath -Name FinishpointIndex -PropertyType Dword -Value $Script:FinishpointIndex)
[void](New-ItemProperty -Path $RegKeyPath -Name PlayerPause -PropertyType Dword -Value $Script:PlayerPause)
[void](New-ItemProperty -Path $RegKeyPath -Name DrawWhileSolving -PropertyType Dword -Value $Script:DrawWhileSolving)
[void](New-ItemProperty -Path $RegKeyPath -Name DeadEndFilling -PropertyType Dword -Value $Script:DeadEndFilling)
[void](New-ItemProperty -Path $RegKeyPath -Name SolveAlgoritmIndex -PropertyType Dword -Value $Script:SolveAlgoritmIndex) 
[void](New-ItemProperty -Path $RegKeyPath -Name ClearLabBeforeSolving -PropertyType Dword -Value $Script:ClearLabBeforeSolving) 
#End