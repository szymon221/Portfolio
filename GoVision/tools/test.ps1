$ArgsGen = "$PSScriptRoot\argsgen\main.py"
$ConfigFileLocation = Get-Content -Path "$PSScriptRoot\runConfig\config.cfg"
$ConfigContents = $ConfigFileLocation.Split([Environment]::NewLine);
$OptionsDict = New-Object System.Collections.Generic.Dictionary"[String,String]"
foreach($Option in $ConfigContents)
{
	$Keyvalue = $Option.Split(";")
	$OptionsDict.Add($Keyvalue[0],$Keyvalue[1].Replace("`"",""))
}


$OptionsDict["PROFILES"]