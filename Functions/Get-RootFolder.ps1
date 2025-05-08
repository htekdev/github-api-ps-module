Function Get-RootFolder {

  Param(
    [string] $Folder = $PSScriptRoot
  )

  # Get git root folder
  $rootFolder = $Folder
  while (!(Test-Path -Path "$rootFolder/.git")){
      $rootFolder = Split-Path -Path $rootFolder -Parent
  }

  return $rootFolder


}
