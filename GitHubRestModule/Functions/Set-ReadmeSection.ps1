Function Set-ReadmeSection {

  Param(
    [string] $ReadmeFilePath,
    [string] $SectionName,
    [string] $Content,
    [string] $HeaderLevel = "#",
    [switch] $Prepend
  )
  if([System.IO.File]::Exists($ReadmeFilePath) -eq $false){
      Set-Content $ReadmeFilePath -Value ""
  }
  $Content = @"
<!--- $($SectionName) START --->
$($Content)
<!--- $($SectionName) END --->
"@
  $readmeContent = [System.IO.File]::ReadAllText($ReadmeFilePath)

  if([String]::IsNullOrEmpty($Content)){
      Write-Host "Updating $($ReadmeFilePath) section $($SectionName) - Removing"
      $readmeContent = $readmeContent -replace "((?:`r?`n|^)#+ *$($SectionName)[^`n]*`n)([\s\S]+?)(`n#|$)", "`$3"
  }
  elseif($readmeContent -match "<!--- *$($SectionName) *START --->([\s\S]*?)<!--- *$($SectionName) *END --->"){
      $_readmeContent = $readmeContent -replace "<!--- *$($SectionName) *START --->([\s\S]*?)<!--- *$($SectionName) *END --->", $Content
      if($_readmeContent -ne $readmeContent){
          Write-Host "Updating $($ReadmeFilePath) section $($SectionName) - Changes"
          [System.IO.File]::WriteAllText($ReadmeFilePath, $_readmeContent)
      }
      else{
          Write-Host "Updating $($ReadmeFilePath) section $($SectionName) - No changes"
      }
  }
  else{
      Write-Host "Adding $($ReadmeFilePath) section $($SectionName)"
      if($Prepend){
          $readmeContent = "$(if($HeaderLevel){"$($HeaderLevel) $($SectionName)`n"})$($Content)`n$($readmeContent)"
      }
      else{
          $readmeContent = "$($readmeContent)`n$(if($HeaderLevel){"$($HeaderLevel) $($SectionName)`n"})$($Content)"
      }
      [System.IO.File]::WriteAllText($ReadmeFilePath, $readmeContent)
  }


}
