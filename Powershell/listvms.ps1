$Array = @()
$ESC = [char]27

#It's easier to seperatly parse the names from the short output
#This can be optimised
#And state from the long output
$VmList = vboxmanage list vms --long
$VmNames = vboxmanage list vms

$VmState = $VmList | Select-String -Pattern "State:" | ForEach-Object {$_ -replace " ", ""} | ForEach-Object {$_ -replace "State:", ""}

if ($VmNames.Length -ne $VmState.Length){
  #Debugging
  Write-Host "Something has gone wrong. Good luck"
  Write-Host = $VmNames.Length
  Write-Host = $VmState.Length
  #Write-Host $VmNames
  Write-Host $VmState
  Exit

}

$StateOff = [Regex]::new('(poweredoff)')
$StateOn = [Regex]::new('(running)')
$StatePaused = [Regex]::new('(paused)')
$StateSaved = [Regex]::new('(saved)')

$NamePattern = [Regex]::new('(?<=")(.*)(?=")')

For($i =0; $i -lt $VmState.Length;$i++){
  $Row = "" | Select ID,Name,State

  $Row.ID = $i + 1
  $Row.Name = $NamePattern.Match($VmNames[$i]).Value

  $Temp ="Unknown"
  #This is kind of ugly also but meh. It works
  $State1 = $StateOn.Match($VmState[$i])
  $State2 = $StateOff.Match($VmState[$i])
  $State3 = $StatePaused.Match($VmState[$i])
  $State4 = $StateSaved.Match($VmState[$i])

  if($State1.Success){
    #ON Green
    $Temp = "$ESC[32mRunning$ESC[0m"
  }

  if($State2.Success){
    #OFF Red
    $Temp = "$ESC[31mPowered Off$ESC[0m"
  }

  if($State3.Success){
    #Paused Blue
    $Temp = "$ESC[34mPaused$ESC[0m"
  }

  if($State4.Success){
    #Saved Magneta
    $Temp = "$ESC[95mSaved$ESC[0m"
  }

  $Row.State = $Temp
  $Array += $Row
}

$Array
