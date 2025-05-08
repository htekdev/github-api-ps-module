Function Invoke-GitHubApiRouteRetryOn202 {

  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)"
  )
  $_statusCode = $null
  $data = $null
  $max_attempts = 30
  do{
    $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token -StatusCode ([ref]$_statusCode) -SkipHttpErrorCheck

    
    if($_statusCode -eq 202) {
      Write-Host "Waiting for 202 to complete..."
      Start-Sleep -Seconds 5
    }

    if($_statusCode -eq 500) {
      Write-Host "Waiting for 500 to complete..."
      Start-Sleep -Seconds 5
    }
    $max_attempts = $max_attempts - 1
  }while($_statusCode -eq 202 -and $max_attempts -gt 0)

  if($max_attempts -eq 0){
    Write-Host "Max attempts reached"
    return $null
  }
  
  return $data


}
