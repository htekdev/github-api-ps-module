Function Invoke-GitHubApiRouteUsingAppJWT {

  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body
  )

  $jwt = New-GitHubJWT

  return Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $jwt


}
