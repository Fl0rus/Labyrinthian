Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

$Global:FrmSizeX =300
$Global:FrmSizeY =500

Clear-Host
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = "$Global:FrmSizeX,$Global:FrmSizeY"
$FrmLabyrinthian.text                       = "Labyrinth"
$FrmLabyrinthian.TopMost                    = $true
$FrmLabyrinthian.BackColor                  = "#FFFFFF"
$FrmLabyrinthian.StartPosition = 'Manual'
$FrmLabyrinthian.Location                    = New-Object System.Drawing.Point(0,0)

$BtnCreateLabyrinth                         = New-Object system.Windows.Forms.Button
$BtnCreateLabyrinth.text                    = "Create Labyrinth"
$BtnCreateLabyrinth.width                   = 100
$BtnCreateLabyrinth.height                  = 50
$BtnCreateLabyrinth.location                = New-Object System.Drawing.Point(100,450)
$BtnCreateLabyrinth.Font                    = 'Microsoft Sans Serif,10'
$BtnCreateLabyrinth.BackColor               = "#888888"

Function CreateLabyrinth () {
    #Fill labyrinth matrix array
    #Read labyrinth array
    #Draw labyrinth

    #Draw stuff prep
    [System.Collections.ArrayList]$global:labyrinth =@()
    $sizex = 15
    $sizey = 30
    $Size = $sizex * $sizey
    For($i=0;$i -lt $sizex;$i++) {
        $global:labyrinth += ,(@()) 
        For ($o=0;$o -lt $sizey;$o++) {
            #$global:labyrinth[$i] += Get-Random -Minimum 0 -Maximum 3
            $global:labyrinth[$i] += 1
        }
    }

    #CreateLabyrinth
    $global:labyrinth[0][0] = 0 #start
    $global:labyrinth[$sizex-1][$sizey-1] = 99 #finish
    $x = 0
    $y = 0
    $Dir = New-Object System.Collections.Generic.List[System.Object]
    $runcount = 0
    While($global:labyrinth[$x][$y] -lt 99) {
        $global:labyrinth[$x][$y] = 0
        If ($y -gt 0) {
            If ($global:labyrinth[$x][$y-1] -gt 0){
                $Dir.Add(@($global:labyrinth[$x][$y-1],$x,($y-1),'u'))
            }
        } #up
        If ($y -lt ($sizey-1)) {
            If ($global:labyrinth[$x][$y+1] -gt 0) {
                $Dir.Add(@(($global:labyrinth[$x][$y+1]),$x,($y+1),'d'))
            }
        } #down
        If ($x -gt 0) {
            If ($global:labyrinth[$x-1][$y] -gt 0) {
                $Dir.Add(@(($global:labyrinth[$x-1][$y]),($x-1),$y,'l'))
            }
        }  #left
        If ($x -lt ($sizex-1)) {
            If($global:labyrinth[$x+1][$y] -gt 0) {
                $Dir.Add(@(($global:labyrinth[$x+1][$y]),($x+1),$y,'r'))
            }
        } #right
        #Nu nog random
        $numofdir = $dir.Count
        If ($numofdir -eq $runcount) {
            $direction = @(0)
            while ($direction[0] -eq 0) {
                $direction = $dir[$dirchoice]
                $dirchoice = Get-Random -Minimum 0 -Maximum $numofdir
            }
            #Write-host "Afslag genomen op punt $dirchoice"
        } Else {
            $dirchoice = Get-Random -Minimum $runcount -Maximum ($numofdir)
        }
        $direction = $dir[$dirchoice]
        $x=$direction[1]
        $y=$direction[2]
        $value = $direction[0]
        #Store memory
        $runcount=$numofdir
        #Write-Host "Beweging $x $y $value"
        DrawLabyrinth
        #$Dir=$null
    }

}
Function DrawLabyrinth(){    
    $brushw = New-Object Drawing.SolidBrush White
    $brushb = New-Object Drawing.SolidBrush Black
    $brushg = New-Object Drawing.SolidBrush Green
    $brushf = New-Object Drawing.SolidBrush Firebrick
    
    $pen = New-object Drawing.pen Black
    $graphics = $FrmLabyrinthian.CreateGraphics()
    #Test for drawing
    $offsetx = 10
    $offsety=10
    $ScaleX = ($Global:FrmSizeX-($offsetx*2))/$sizex
    $ScaleY= ($Global:FrmSizeY-($offsety*2))/$sizey
    For($y=0;$y -lt $sizey;$y++) { 
        For($x=0;$x -lt $sizex;$x++) {
            Switch($global:labyrinth[$x][$y]) {
                0 {
                    $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,($ScaleX-1),($scaleY-1))
                }
                1 {
                    $graphics.FillRectangle($brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                }
                default {
                    $graphics.FillRectangle($brushf,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
                }
                    
            }
        }

    }   
}

$BtnCreateLabyrinth.Add_Click({ CreateLabyrinth })

$FrmLabyrinthian.controls.AddRange(@($BtnCreateLabyrinth))
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)