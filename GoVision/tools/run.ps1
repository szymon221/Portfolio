
$ArgsGen = "$PSScriptRoot\argsgen\main.py"

$ConfigFileLocation = Get-Content -Path "$PSScriptRoot\runConfig\config.cfg"
$ConfigContents = $ConfigFileLocation.Split([Environment]::NewLine);
$OptionsDict = New-Object System.Collections.Generic.Dictionary"[String,String]"

foreach($Option in $ConfigContents)
{
	$Keyvalue = $Option.Split(";")
	$OptionsDict.Add($Keyvalue[0],$Keyvalue[1].Replace("`"",""))
}

$ProfilePath = $OptionsDict["PROFILES"]
$SRCDSLocation =  $OptionsDict["EXEC"]

if ($args.Length -eq 0) {
    Write-Host "No argument was passed."
	exit 1;
}

$GameProfile = $args[0];

if(!(Test-Path $ProfilePath\\$GameProfile))
{
	Write-Host "Profile $GameProfile does not exits"
	exit 1;
}
$command = "$ArgsGen $GameProfile"
$result = Invoke-Expression -Command $command


$StartServerCommand = "$SRCDSLocation $result"
Write-Host $StartServerCommand
Invoke-Expression -Command $StartServerCommand
