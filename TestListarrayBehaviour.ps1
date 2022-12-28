[System.Collections.ArrayList]$x = @()

[void]$x.Add(@(1,2))
[void]$x.Add(@(2,3))
[void]$x.Add(@(3,4))
[void]$x.Add(@(5,2))
[void]$x.Add(@(3,4))
[void]$x.Add(@(0,1))

Write-host $x.count

$i=$x | Where-Object {$_[0] -eq 2 -and $_[1] -eq 3}
$x.Remove($i)
Write-host $i

$i=$x | Where-Object {$_[0] -eq 2 -and $_[1] -eq 3}
Write-host $i
$x.Remove($i)

Write-host $x.count
