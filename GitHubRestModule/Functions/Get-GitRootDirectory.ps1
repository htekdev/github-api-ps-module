Function Get-GitRootDirectory {

  $root = Get-Location
  while (!(Test-Path -Path "$root/.git")){
      $root = Split-Path -Path $root -Parent
  }
  return $root


}
