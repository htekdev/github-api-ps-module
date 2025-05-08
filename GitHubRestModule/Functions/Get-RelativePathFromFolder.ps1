Function Get-RelativePathFromFolder {

  Param(
    [string] $Path,
    [string] $From = $PSScriptRoot
  )

  $From = $From -replace "[\/\\]", '/'
  $Path = $Path -replace "[\/\\]", '/'
  $Path = $Path -replace "$From/", ''
  return $Path


}
