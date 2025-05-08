Function Get-GitHubRepositories {

  Param(
    [string] $login
  )
  Update-GitHubToken -Organization $login

  Write-Host "Getting repositories for $($login)..."
  $repos = @(Invoke-PaginatedGitHubApiRoute -Path "orgs/$($login)/repos" )
  Write-Host "Found $($repos.count) repositories for $($login)"

  # Adding Index / Count to each repository
  $_ = $repos | ForEach-Object -Begin { $i = 0 } -Process { 
    $_ | Add-Member -MemberType NoteProperty -Name Index -Value $i -PassThru 
    $_ | Add-Member -MemberType NoteProperty -Name Total -Value $($repos.Count) -PassThru 
    $i++
  } -End { $i++ }

  return $repos


}
