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
    [System.Collections.ArrayList]$lab =@()
    $sizex = 5
    $sizey = 10
    $Size =$sizex * $sizey
    For($i=0;$i -lt $sizex;$i++) {
        $lab += ,(@()) 
        For ($o=0;$o -lt $sizey;$o++) {
            $lab[$i] += Get-Random -Minimum 0 -Maximum 2
        }
    }
    $brushw = New-Object Drawing.SolidBrush White
    $brushb = New-Object Drawing.SolidBrush Black
    $pen = New-object Drawing.pen Black
    $graphics = $FrmLabyrinthian.CreateGraphics()
    #Test for drawing
    $offsetx = 10
    $offsety=10
    $ScaleX = ($Global:FrmSizeX-($offsetx*2))/$sizex
    $ScaleY= ($Global:FrmSizeY-($offsety*2))/$sizey
    For($y=0;$y -lt $sizey;$y++) { 
        For($x=0;$x -lt $sizex;$x++) {
            If($lab[$x][$y] -eq 0) {
                $graphics.FillRectangle($brushw,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
            } Else {
                $graphics.FillRectangle($brushb,($x*$scalex)+$offsetx,($y*$scaleY)+$offsety,$ScaleX,$scaleY)
            }
        }

    }   
}

$BtnCreateLabyrinth.Add_Click({ CreateLabyrinth })

$FrmLabyrinthian.controls.AddRange(@($BtnCreateLabyrinth))
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)