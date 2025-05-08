Function Get-CommentParameters {

  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Content
  )

  try{
    # Pull out all the parameters in the form of #[<Parameter Name>]\n<Parameter Value>
    $regex = [regex]("# *\[(?<ParameterName>.*)\][\n\r]+#(?<ParameterValue>.*)[\n\r]*")
    $_matches = $regex.Matches($Content)
    Write-Host "$($_matches.Count) parameters found in comment"
    $Parameters = @($_matches | ForEach-Object {
        @{
            Name = $_.Groups["ParameterName"].Value
            Value = ($_.Groups["ParameterValue"].Value -replace "[\n\r]+", '').Trim()
        }
    })
    return @(@($Parameters) | Sort-Object -Property Name)
  }
  catch{
    Write-Host "$($_.Exception.Message)"
    Write-Error "No repository found with name ``$Repository``"
  }








}
