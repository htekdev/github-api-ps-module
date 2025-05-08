Function Get-RepoDetails {

  Param(
    [string] $Folder
  )

  $rootFolder = Get-RootFolder -Folder $Folder

  try{
    Push-Location $rootFolder

    Write-Host "Getting repository details for folder ``$Folder``..."

    $repo = $(gh repo view --json name,owner,id,nameWithOwner,description,url ) | ConvertFrom-Json

    return $repo
  }
  catch{
    throw "Command failed with exit code ``$code``"
  }
  finally{
    Pop-Location
  }


}
