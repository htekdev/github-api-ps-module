Function Get-MarkdownNoWrap {

  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Content
  )

  $Content = $Content.Trim()
  $Content = $Content -replace "-", "&#x2011;"
  $Content = $Content -replace " ", "&#x00A0;"
  
  return $Content


}
