Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

$Global:FrmSizeX =500
$Global:FrmSizeY =500
$global:SizeX = 30
$global:SizeY= 50

Clear-Host
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = "$Global:FrmSizeX,$Global:FrmSizeY"
$FrmLabyrinthian.text                       = "Labyrinth"
$FrmLabyrinthian.TopMost                    = $true
$FrmLabyrinthian.BackColor                  = "#000000"
$FrmLabyrinthian.StartPosition = 'Manual'
$FrmLabyrinthian.Location                    = New-Object System.Drawing.Point(0,0)
$FrmLabyrinthian.TransparencyKey = "#888888"

$BtnCreateLabyrinth                         = New-Object system.Windows.Forms.Button
$BtnCreateLabyrinth.text                    = "Create Labyrinth"
$BtnCreateLabyrinth.width                   = 150
$BtnCreateLabyrinth.height                  = 25
$BtnCreateLabyrinth.location                = New-Object System.Drawing.Point(0,0)
$BtnCreateLabyrinth.Font                    = 'Microsoft Sans Serif,10'
$BtnCreateLabyrinth.BackColor               = "#999999"

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
#$sldWidth.BackColor = "000000"

$sldwidthNum = New-Object System.Windows.Forms.NumericUpDown
$sldwidthNum.width = 45
$sldwidthNum.Height = 25
$sldwidthNum.value= $global:SizeY
$sldwidthNum.Location = New-Object System.Drawing.Point(260,0)
$sldwidthNum.Maximum =150
$sldwidthNum.Minimum =5

$sldHeight = New-Object System.Windows.Forms.Trackbar
$sldHeight.width = 100
$sldHeight.Height = 5
$sldHeight.location = New-Object System.Drawing.Point(310,0)
$sldHeight.Maximum = 150
$sldHeight.Minimum = 5
$sldHeight.Value = $global:SizeX
$sldHeight.AutoSize = $True
$sldHeight.TickStyle = 0
$sldHeight.Orientation = 0
$sldHeight.Margin =0
$sldHeight.Padding =0
#$slHeighth.BackColor = "000000"

$sldHeightNum = New-Object System.Windows.Forms.NumericUpDown
$sldHeightNum.width = 45
$sldHeightNum.Height = 25
$sldHeightNum.value= $global:SizeY
$sldHeightNum.Location = New-Object System.Drawing.Point(415,0)
$sldHeightNum.Maximum =150
$sldHeightNum.Minimum =5

$FrmLabyrinthian.controls.AddRange(@($BtnCreateLabyrinth,$sldWidth,$sldwidthNum,$sldHeight,$sldHeightNum))

Function CreateLabyrinth () {
    #Fill labyrinth matrix array
    Clear-Host
    #Draw stuff prep
    [System.Collections.ArrayList]$global:labyrinth =@()
    #$Size =  $global:SizeX *  $global:SizeY
    For($i=0;$i -lt  $global:SizeX;$i++) {
        $global:labyrinth += ,(@()) 
        For ($o=0;$o -lt  $global:SizeY;$o++) {
            #$global:labyrinth[$i] += Get-Random -Minimum 0 -Maximum 3
            $global:labyrinth[$i] += 0 #Black Block
        }
    }
    DrawLabyrinth
    #CreateLabyrinth
    $global:labyrinth[0][0] = 0 #start
    $global:labyrinth[ $global:SizeX-1][ $global:SizeY-1] = 16 #finish
    $x = 0
    $y = 0
    $pointer=0
#    $moved = New-Object System.Collections.Generic.List[System.Object]
    [System.Collections.ArrayList]$moved = @()
    While($global:labyrinth[$x][$y] -lt 16 -and $pointer -ge 0) {
    #While($pointer -ge 0) {
            [System.Collections.ArrayList]$posDir = @()
        If ($y -gt 0) {
            If ($global:labyrinth[$x][$y-1] -eq 0 -or $global:labyrinth[$x][$y-1] -ge 16){
                $posDir.Add(@($global:labyrinth[$x][$y-1],$x,($y-1),'u')) #Up
            }
        } #up
        If ($y -lt ( $global:SizeY-1)) {
            If ($global:labyrinth[$x][$y+1] -eq 0 -or $global:labyrinth[$x][$y+1] -ge 16) {
                $posDir.Add(@(($global:labyrinth[$x][$y+1]),$x,($y+1),'d')) #Down
            }
        } #down
        If ($x -gt 0) {
            If ($global:labyrinth[$x-1][$y] -eq 0 -or $global:labyrinth[$x-1][$y] -ge 16) {
                $posDir.Add(@(($global:labyrinth[$x-1][$y]),($x-1),$y,'l')) #left
            }
        }  #left
        If ($x -lt ( $global:SizeX-1)) {
            If($global:labyrinth[$x+1][$y] -eq 0 -or $global:labyrinth[$x+1][$y] -ge 16) {
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
        } Else {
            $pointer--
            $x = $moved[$pointer][0]
            $y = $moved[$pointer][1]
            #Write-host "Step $pointer = Niewe scan op punt $x $y"
        }
    }
    #Draw labyrinth
    DrawLabyrinth
}
Function DrawLabyrinth(){    
    $brushw = New-Object Drawing.SolidBrush White
    $brushb = New-Object Drawing.SolidBrush Black
    $brushg = New-Object Drawing.SolidBrush Green
    $brushf = New-Object Drawing.SolidBrush Firebrick
    
    #$pen = New-object Drawing.pen Black
    $graphics = $FrmLabyrinthian.CreateGraphics()
    #Test for drawing
    $offsetx = 20
    $offsety = 25
    $Global:FrmSizeX = $FrmLabyrinthian.Width
    $Global:FrmSizeY = $FrmLabyrinthian.Height - 30
    $ScaleX = (($Global:FrmSizeX-($offsetx*2))/ $global:SizeX)
    $ScaleY= (($Global:FrmSizeY-($offsety*2))/ $global:SizeY)
    $RoomSizeX = $ScaleX * 0.75
    $RoomsizeY = $Scaley * 0.75
    
    For($y=0;$y -lt  $global:SizeY;$y++) { 
        For($x=0;$x -lt  $global:SizeX;$x++) {
            Switch($global:labyrinth[$x][$y]) {
                0 {
                    $graphics.FillRectangle($brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                }
                {(1 -band $_) -eq 1} {
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,(($y-0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(2 -band $_) -eq 2} {
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,(($y+0.25)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))

                }
                {(4 -band $_) -eq 4} {
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $graphics.FillRectangle($brushw,(($x-0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                }
                {(8 -band $_) -eq 8} {
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))
                    $graphics.FillRectangle($brushw,(($x+0.25)*$scalex)+$offsetx,(($y)*$scaleY)+$offsety,($RoomSizeX),($RoomsizeY))

                }
                16 {
                    $graphics.FillRectangle($brushg,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                }
                #default {
                #    $graphics.FillRectangle($brushf,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                #}
                    
            }
        }

    }   
    $FrmLabyrinthian.Update()
}

function ChangeSizeX () {
    $sldwidthNum.Value = $sldWidth.Value
    $global:SizeX = $sldWidth.Value
}
function ChangeSizeY () {
    $sldHeightNum.Value = $sldHeight.Value
    $global:SizeY = $sldHeight.Value
}

$BtnCreateLabyrinth.Add_Click({ CreateLabyrinth })

$sldWidth.Add_Scroll({ ChangeSizeX })
$sldHeight.Add_Scroll({ ChangeSizeY })

[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)