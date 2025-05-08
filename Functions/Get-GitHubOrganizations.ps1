Function Get-GitHubOrganizations {

  # Get all organizations
  Write-Host "Getting organizations..."
  $installations = @(Invoke-GitHubApiRouteUsingAppJWT -Path "app/installations" -Method Get)
  Write-Host "Found $($installations.count) installations"

  $installations = @($installations | Where-Object { $_.target_type -eq "Organization" })
  $organizations = @($installations | Select-Object -ExpandProperty account)
  Write-Host "Found $($organizations.count) organizations"

  return @($organizations)


}
