Function Update-GitHubToken {

  Param(
    [string] $Certificate = $($env:GH_APP_CERTIFICATE),
    [string] $AppId = $($env:GH_APP_ID),
    [string] $Organization,
    [string] $Repository
  )

  if([String]::IsNullOrEmpty($Certificate) -and -not [String]::IsNullOrEmpty($env:GH_APP_CERTIFICATE_FILE_PATH)){
    $Certificate = Get-Content -Path $env:GH_APP_CERTIFICATE_FILE_PATH
  }

  if([String]::IsNullOrEmpty($AppId) -or [String]::IsNullOrEmpty($Certificate)){
    Write-Warning "AppId and Certificate are required to update the token"
    return
  }

  $jwt = New-GitHubJWT -Certificate $Certificate -AppId $AppId
  $headers = @{}
  $headers.Add("Accept", "application/vnd.github+json")
  $headers.Add("Authorization", "Bearer $jwt")

  if(-not [String]::IsNullOrEmpty($Repository)){
    $path = "repos/$($Repository)/installation"
  }
  elseif(-not [String]::IsNullOrEmpty($Organization)){
    $path = "orgs/$($Organization)/installation"
  }
  else{
    # get first installation
    $path = "app/installations"
  }

  $response = @(Invoke-PaginatedGitHubApiRoute -Path $path -Method GET -Headers $headers -Token $jwt)
  $access_tokens_url = @($response.access_tokens_url)[0]
  $response = Invoke-RateLimitedEndpoint -Uri $access_tokens_url -Method POST  -Headers $headers -Token $jwt

  $token = $response.token

  $env:GH_TOKEN = $token
  $env:GH_AUTH_REPO = $Repository
  $env:GH_AUTH_ORG = $Organization


}
