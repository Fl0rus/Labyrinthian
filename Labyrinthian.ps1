Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()


Clear-Host
$FrmLabyrinthian                            = New-Object system.Windows.Forms.Form
$FrmLabyrinthian.ClientSize                 = '300,500'
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
    $lab =@(0;1;1;1;0;0;0;1)
    $brush = New-Object Drawing.SolidBrush Black
    $pen = New-object Drawing.pen Black
    $graphics = $FrmLabyrinthian.CreateGraphics()
    #Test for drawing
    For($x=0;$x -le 100;$x = $x+2) {
        $graphics.FillRectangle($brush,$x,10,1,1)
    }
}   


$BtnCreateLabyrinth.Add_Click({ CreateLabyrinth })

$FrmLabyrinthian.controls.AddRange(@($BtnCreateLabyrinth))
[void][System.Windows.Forms.Application]::Run($FrmLabyrinthian)