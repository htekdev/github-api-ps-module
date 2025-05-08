Function Invoke-GitHubGraphql {

  Param(
    [string] $Query,
    [hashtable] $Variables = @{},
    [string] $Token = "$(gh auth token)"
  )

  $headers = @{
    Authorization = "Bearer $($Token)"
  }

  $VariableNames = @($Variables.GetEnumerator() | ForEach-Object { $_.Key })
  if($VariableNames.Count -gt 0){
    $Query = "$Query `nvariables {"
    $Query += @($VariableNames | ForEach-Object { "  `"$($_)`": $($_)" }) -join "`n"
    $Query += "`n}"
  }


  $data = Invoke-GitHubApiRoute -Path "graphql" -Method POST -Body $(@{query = $Query} | ConvertTo-Json) -Token $Token

  if($data.errors){
    Write-Host "Error: $($data.errors[0].message)"
    throw "Error: $($data.errors[0].message)"
  }

  return $data


}
