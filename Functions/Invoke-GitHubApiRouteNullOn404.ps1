Function Invoke-GitHubApiRouteNullOn404 {

  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)"
  )
  $_statusCode = $null
  $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token -StatusCode ([ref]$_statusCode) -SkipHttpErrorCheck

  # Retry if 202
  if($_statusCode -eq 404) {
    return $null
  }

  return $data


}
