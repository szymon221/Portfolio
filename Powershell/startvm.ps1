if ($args.Length -lt 1){
  Write-Host "No VM supplied"
}

if ($args.Length -gt 1 ){
  Write-Host "Too many arguments supplied"
}

vboxmanage startvm $args[0] --type headless