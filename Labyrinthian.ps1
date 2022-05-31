Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

$Global:FrmSizeX =500
$Global:FrmSizeY =500
$global:SizeX = 50
$global:SizeY= 25

Clear-Host
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = "$Global:FrmSizeX,$Global:FrmSizeY"
$FrmLabyrinthian.text                       = "Labyrinth"
$FrmLabyrinthian.TopMost                    = $true
$FrmLabyrinthian.BackColor                  = "#888888"
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

$sldWidth = New-Object System.Windows.Forms.Trackbar
$sldWidth.width = 100
$sldWidth.Height = 5
$sldWidth.location = New-Object System.Drawing.Point(155,0)
$sldwidth.Maximum = 150
$sldWidth.Minimum = 5
$sldWidth.Value = $global:SizeX
$sldwidth.AutoSize = $True
$sldwidth.TickStyle = 0
$sldWidth.Orientation = 0
$sldWidth.Margin =0
$sldwidth.Padding =0
$sldWidth.BackColor = "#888888"

$sldwidthNum = New-Object System.Windows.Forms.NumericUpDown
$sldwidthNum.width = 45
$sldwidthNum.Height = 25
$sldwidthNum.Location = New-Object System.Drawing.Point(260,0)
$sldwidthNum.Maximum = 150
$sldwidthNum.Minimum = 5
$sldwidthNum.value= $global:SizeX

$sldHeight = New-Object System.Windows.Forms.Trackbar
$sldHeight.width = 100
$sldHeight.Height = 5
$sldHeight.location = New-Object System.Drawing.Point(310,0)
$sldHeight.Maximum = 150
$sldHeight.Minimum = 5
$sldHeight.Value = $global:SizeY
$sldHeight.TickStyle = 0
$sldHeight.Orientation = 0
$sldHeight.BackColor ='#888888'

$sldHeightNum = New-Object System.Windows.Forms.NumericUpDown
$sldHeightNum.width = 45
$sldHeightNum.Height = 25
$sldHeightNum.Location = New-Object System.Drawing.Point(415,0)
$sldHeightNum.Maximum = 150
$sldHeightNum.Minimum =5
$sldHeightNum.value = $global:SizeY

$prgCalc = New-object System.Windows.Forms.ProgressBar
$prgCalc.Width = 40
$prgCalc.Height = 20
$prgcalc.value = 0
$prgcalc.Location = New-Object System.Drawing.Point(460,0)

$FrmLabyrinthian.controls.AddRange(@($BtnCreateLabyrinth,$BtnSolveLabyrinth,$sldWidth,$sldwidthNum,$sldHeight,$sldHeightNum,$prgCalc))
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
    DrawExplorer -x $x -y $y
    While($pointer -ge 0) {
        [System.Collections.ArrayList]$posDir = @()
        If ($y -gt 0) {
            If ($global:labyrinth[$x][$y-1] -eq 0){
                $posDir.Add(@($global:labyrinth[$x][$y-1],$x,($y-1),'u')) #Up
            }
        } #up
        If ($y -lt ( $global:SizeY-1)) {
            If ($global:labyrinth[$x][$y+1] -eq 0 ) {
                $posDir.Add(@(($global:labyrinth[$x][$y+1]),$x,($y+1),'d')) #Down
            }
        } #down
        If ($x -gt 0) {
            If ($global:labyrinth[$x-1][$y] -eq 0) {
                $posDir.Add(@(($global:labyrinth[$x-1][$y]),($x-1),$y,'l')) #left
            }
        }  #left
        If ($x -lt ( $global:SizeX-1)) {
            If($global:labyrinth[$x+1][$y] -eq 0) {
                $posDir.Add(@(($global:labyrinth[$x+1][$y]),($x+1),$y,'r'))#right
            }
        } #right
        #Random direction
        $numofposdir = $posdir.Count
        If ($numofposdir -ne 0) {
            $movechoice = Get-Random -Minimum 0 -Maximum ($numofposdir)
            $movedection = $posDir[$movechoice]
            $value = $global:labyrinth[$x][$y]
            #deur gevonden
            Switch($movedection[3]){
                'u' {$value+=1}
                'd' {$value+=2}
                'l' {$value+=4}
                'r' {$value+=8}
            }
            $global:labyrinth[$x][$y] = $value
            $moved.Add(@($x,$y))
            $pointer=$moved.count
            $x=$movedection[1]
            $y=$movedection[2]
            #Deur naar de andere kant!
            $value = $global:labyrinth[$x][$y]
            Switch($movedection[3]){
                'u' {$value+=2}
                'd' {$value+=1}
                'l' {$value+=8}
                'r' {$value+=4}
            }
            $global:labyrinth[$x][$y] = $value
            #Write-host "Step $pointer = Moved to $x $y"
            $prgCalc.Value = $progress
            DrawExplorer -x $x -y $y
            $progress++
        } ElseIf ($pointer -gt $pointermax) {
           $pointermax=$pointer+1
           $endpoints.Add(@($x,$y))
        } Else {
            $pointer--
            $x = $moved[$pointer][0]
            $y = $moved[$pointer][1]
            #Write-host "Step $pointer = Niewe scan op punt $x $y"
        }
    }
    $BtnSolveLabyrinth.Enabled = $true
    $endpoint=$endpoints[(Get-Random -Minimum 0 -Maximum $endpoints.Count)]
    $global:labyrinth[$endpoint[0]][$endpoint[1]] = 512 #finish
    $Global:Finish=@($endpoint[0],$endpoint[1])
    DrawExplorer -x ($endpoint[0]) -y ($endpoint[1])
    #Draw labyrinth
    #ClearLabyrinth
    #DrawLabyrinth
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
    $prgcalc.width = $FrmLabyrinthian.Width-460
}
Function ClearLabyrinth () {
    $FrmLabyrinthian.Refresh()
    $brushb = New-Object Drawing.SolidBrush Gray
    $global:Graphics = $FrmLabyrinthian.CreateGraphics()
    $global:Graphics.FillRectangle($brushb,0,0,$FrmLabyrinthian.Width,$FrmLabyrinthian.Height)
    #$FrmLabyrinthian.Update()
}
Function DrawExplorer {
    Param (
        $x,
        $y,
        [ValidateSet("Bold", "Normal", "Light")]$marker 
    )

    $brushw = New-Object Drawing.SolidBrush White
    $brushb = New-Object Drawing.SolidBrush Black
    $brushg = New-Object Drawing.SolidBrush Green
    $brushf = New-Object Drawing.SolidBrush Firebrick
    $brushb = New-Object Drawing.SolidBrush Blue
    $brushelb = New-Object Drawing.SolidBrush LightBlue
    $brushelc = New-Object Drawing.SolidBrush LightCyan

    $offsetx = 20
    $offsety = 50
    $ScaleX = (($FrmLabyrinthian.Width-($offsetx*2))/ $global:SizeX)
    $ScaleY= ((($FrmLabyrinthian.Height - 25)-($offsety*2))/ $global:SizeY)
    $RoomSizeX = $ScaleX * 0.75
    $RoomsizeY = $Scaley * 0.75
    If($marker -eq 'Bold') {
        $global:Graphics.FillRectangle($brushb,($x*$scalex)+$offsetx,($y*$scaleY+0.25)+$offsety,($RoomSizeX),($RoomsizeY))
    } ElseIf($marker -eq 'Normal') {
        $global:Graphics.FillRectangle($brushelb,($x*$scalex)+$offsetx,($y*$scaleY+0.25)+$offsety,($RoomSizeX),($RoomsizeY))
    } ElseIf($marker -eq 'Light') {
        $global:Graphics.FillRectangle($brushw,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
    }Else{
        Switch($global:labyrinth[$x][$y]) {
            0 {
                $global:Graphics.FillRectangle($brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
            }
            {(1 -band $_) -eq 1} {
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,(($y-0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(2 -band $_) -eq 2} {
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(4 -band $_) -eq 4} {
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:Graphics.FillRectangle($brushw,(($x-0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(8 -band $_) -eq 8} {
                $global:Graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                $global:Graphics.FillRectangle($brushw,(($x+0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
        }
        If ((($global:labyrinth[$x][$y] -band 240) -ne 240) -or (($global:labyrinth[$x][$y] -band 240) -eq 0)) {
            Switch($global:labyrinth[$x][$y]) {
                {(16 -band $_) -eq 16} {
                    $global:Graphics.FillRectangle($brushb,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                    $global:Graphics.FillRectangle($brushelb,(($x+0.25)*$scalex)+$offsetx,((($y+0.25)-0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                }
                {(32 -band $_) -eq 32} {
                    $global:Graphics.FillRectangle($brushb,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                    $global:Graphics.FillRectangle($brushelb,(($x+0.25)*$scalex)+$offsetx,((($y+0.25)+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                }
                {(64 -band $_) -eq 64} {
                    $global:Graphics.FillRectangle($brushb,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                    $global:Graphics.FillRectangle($brushelb,(($x-0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                }
                {(128 -band $_) -eq 128} {
                    $global:Graphics.FillRectangle($brushb,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                    $global:Graphics.FillRectangle($brushelb,((($x+0.25)+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
                }
            }
        }
        Switch($global:labyrinth[$x][$y]) {
            {(240 -band $_) -eq 240} {
                $global:Graphics.FillRectangle($brushelb,(($x+0.25)*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX/2),($RoomsizeY/2))
            }
            {(256 -band $_) -eq 256} {
                $global:Graphics.FillRectangle($brushg,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
            }
            {(512 -band $_) -eq 512} {
                $global:Graphics.FillRectangle($brushf,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
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
    For($i=0;$i -lt  $global:SizeX;$i++) {
        For ($o=0;$o -lt  $global:SizeY;$o++) {
            $breadcrumb = ($global:labyrinth[$i][$o]) -band 240
            If($breadcrumb -ne 0) {
                $global:labyrinth[$i][$o]-=$breadcrumb #remove breadcrumbs
            }
        }
    }
    #ClearLabyrinth
    #DrawLabyrinth
    #Write-host "$global:start $global:finish"
    $x =$global:start[0]
    $y =$global:start[1]
    $Progress=1
    $progressmax=1
    $moves=0
    $maxmoves=($global:SizeX*$global:SizeY)
    $prgCalc.Value =$moves
    $prgCalc.Maximum =$maxmoves
    [System.Collections.ArrayList]$moved=@()
    #DrawExplorer -x $x -y $y -marker Bold
    While (($global:labyrinth[$x][$y] -band 512) -ne 512) {
        [System.Collections.ArrayList]$posDir = @()
        If (($global:labyrinth[$x][$y] -band 1) -eq 1 -and (($global:labyrinth[$x][($y-1)] -band 240) -eq 0)) {$posdir.add(@($x,($y-1),'u'))}
        If (($global:labyrinth[$x][$y] -band 2) -eq 2 -and (($global:labyrinth[$x][($y+1)] -band 240) -eq 0)) {$posdir.add(@($x,($y+1),'d'))}
        If (($global:labyrinth[$x][$y] -band 4) -eq 4 -and (($global:labyrinth[($x-1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x-1),$y,'l'))}
        If (($global:labyrinth[$x][$y] -band 8) -eq 8 -and (($global:labyrinth[($x+1)][$y] -band 240) -eq 0)) {$posdir.add(@(($x+1),$y,'r'))}
        $numofposdir = $posdir.Count
        If($Moves -lt $maxmoves) {
            $Moves++
            $prgCalc.Value = $moves
        }
        If ($numofposdir -ne 0) {
                #Random direction
            $movechoice = $posDir[(Get-Random -Minimum 0 -Maximum ($numofposdir))]
            #Directed direction
            #$movechoice = $posDir[0]
            $direction = $movechoice[2]
            $global:labyrinth[$x][$y]-=($global:labyrinth[$x][$y] -band 240)
            Switch ($direction){
                'u' {$global:labyrinth[$x][$y]+=16}
                'd' {$global:labyrinth[$x][$y]+=32}
                'l' {$global:labyrinth[$x][$y]+=64}
                'r' {$global:labyrinth[$x][$y]+=128}
            }
            DrawExplorer -x $x -y $y
            $x = $movechoice[0]
            $y = $movechoice[1]
            $global:labyrinth[$x][$y]+=240
            $moved.Add(@($x,$y))
            $progress=$moved.count-1
            #Write-host "New route: " -NoNewline
        } ElseIf($progress -gt $progressmax) {
            $progressmax=$Progress+1
            #Write-host "Dead End: " -NoNewline
            #DrawExplorer -x $x -y $y -Marker Normal
        } Else {
            $Progress--
            $Moves--
            $x = $moved[$progress][0]
            $y = $moved[$progress][1]
            If (($global:labyrinth[$x][$y] -band 240) -ne 240) {
                $global:labyrinth[$x][$y]+= 240 - ($global:labyrinth[$x][$y] -band 240)
                DrawExplorer -x $x -y $y
            }
            #Write-host "Backtrack: " -NoNewline
            }
        #Write-host "$x $y"
    }
    #$global:labyrinth[$x][$y]-=64
    $prgCalc.Value = $maxmoves
    Write-Host "moves: $moves"
}
function ChangeSizeX () {
    $sldwidthNum.Value = $sldWidth.Value
    $global:SizeX = $sldWidth.Value
    $BtnSolveLabyrinth.Enabled=$false
}
function ChangeSizeY () {
    $sldHeightNum.Value = $sldHeight.Value
    $global:SizeY = $sldHeight.Value
    $BtnSolveLabyrinth.Enabled=$false
}
function ChangeSizeXNum () {
    $sldWidth.Value = $sldWidthNum.Value 
    $global:SizeX = $sldWidth.Value
    $BtnSolveLabyrinth.Enabled=$false
}
function ChangeSizeYNum () {
    $sldHeight.Value = $sldHeightNum.Value 
    $global:SizeY = $sldHeight.Value
    $BtnSolveLabyrinth.Enabled=$false
}

$BtnCreateLabyrinth.Add_Click({ InitLabyrinth;ClearLabyrinth;CreateLabyrinth })
$BtnSolveLabyrinth.Add_Click({ SolveLabyrinth })

$sldWidth.Add_Scroll({ ChangeSizeX })
$sldHeight.Add_Scroll({ ChangeSizeY })
$sldwidthNum.Add_ValueChanged({ChangeSizeXNum})
$sldHeightNum.Add_ValueChanged({ChangeSizeYNum})
$FrmLabyrinthian.Add_ResizeEnd({ClearLabyrinth;DrawLabyrinth;$prgCalc.width=$FrmLabyrinthian.width-460})
$FrmLabyrinthian.Add_Shown({ClearLabyrinth;DrawLabyrinth;$FrmLabyrinthian.Update()})

InitLabyrinth
#CreateLabyrinth
#SolveLabyrinth
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)