Function Convert-ToNormalPath {

  Param(
    # Allo pipe
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Path,

    [string] $From = $PSScriptRoot
  )

  Process{
    $From = $From -replace "[\/\\]", '/'
    

    $Path = $Path -replace "[\/\\]", '/'
    $Path = $Path -replace "$From/", ''
    return $Path
  }


}
