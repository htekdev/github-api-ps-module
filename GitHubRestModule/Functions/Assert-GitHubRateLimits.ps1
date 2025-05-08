Function Assert-GitHubRateLimits {

  Param(
      [string] $threshold = 2
  )

  $resources = $(gh api -X GET /rate_limit | ConvertFrom-Json).resources
  $keys = $resources.psobject.Properties.Name
  foreach($key in $keys){
      $item = $resources.$key
      Write-Host "$key has $($item.remaining) remaining"
      if($item.remaining -gt $threshold){
      continue
      }

      $rateLimitReset = $item.reset
      $rateLimitResetAt = [datetime]::new(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc).AddSeconds($rateLimitReset)
      $wait = $rateLimitResetAt - [datetime]::UtcNow
      Write-Host "Waiting $($wait.TotalSeconds) seconds for rate limit to reset for $key"
      Start-Sleep -Seconds $wait.TotalSeconds
      Start-Sleep -Seconds 20
  }


}
