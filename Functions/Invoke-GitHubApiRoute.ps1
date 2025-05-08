<#
.SYNOPSIS
  Invokes a GitHub API route with support for authentication, retries, and custom headers.

.DESCRIPTION
  The Invoke-GitHubApiRoute function sends HTTP requests to the GitHub API, handling authentication, retries on certain HTTP errors, and custom headers. 
  It supports GET, POST, and other HTTP methods, and can return raw responses or save output to a file. 
  The function also manages GitHub authentication tokens and can update them if authentication errors occur.

.PARAMETER Path
  The API route path (relative to https://api.github.com/) to invoke.

.PARAMETER Query
  A hashtable of query parameters to append to the request URI.

.PARAMETER Method
  The HTTP method to use for the request (default is "GET").

.PARAMETER Body
  The request body to send (for POST, PUT, PATCH, etc.).

.PARAMETER Token
  The GitHub authentication token to use. Defaults to the output of 'gh auth token'.

.PARAMETER ResponseHeaders
  A reference variable to receive the response headers.

.PARAMETER StatusCode
  A reference variable to receive the HTTP status code.

.PARAMETER Raw
  If specified, returns the raw response instead of parsing as JSON.

.PARAMETER SkipHttpErrorCheck
  If specified, skips HTTP error checking.

.PARAMETER SearchText
  Optional text to search for in the response.

.PARAMETER OutFile
  If specified, saves the response content to the given file path.

.PARAMETER ExtraHeaders
  A hashtable of additional headers to include in the request.

.EXAMPLE
  Invoke-GitHubApiRoute -Path "repos/owner/repo/issues" -Method "GET"

.EXAMPLE
  Invoke-GitHubApiRoute -Path "user/repos" -Method "POST" -Body $jsonBody -Token $myToken

.NOTES
  - Handles 401 and 403 errors by attempting to refresh the authentication token and retrying.
  - Retries up to 5 times on 500 and 502 errors, waiting 60 seconds between attempts.
  - Rate limiting is handled by the Invoke-RateLimitedEndpoint function.
#>
function Invoke-GitHubApiRoute {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string] $Path,

    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)",
    [ref] $ResponseHeaders,
    [ref] $StatusCode,
    [switch] $Raw,
    [switch] $SkipHttpErrorCheck,
    [string] $SearchText,
    [string] $OutFile,
    [hashtable] $ExtraHeaders = @{}
  )

  # Setup Headers
  $Headers = @{
    Authorization           = "Bearer $Token"
    "X-GitHub-Api-Version"  = "2022-11-28"
  }
  if ($ExtraHeaders) {
    foreach ($key in $ExtraHeaders.Keys) {
      $Headers[$key] = $ExtraHeaders[$key]
    }
  }

  $RetryCount = 0
  $AuthError  = $false

  do {
    try {
      # Build URI
      $uri = "https://api.github.com/$Path"
      if ($Query.Count -gt 0) {
        $queryString = ($Query.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        $uri += "?$queryString"
      }

      Write-Host "$Method $uri"

      if (-not $ResponseHeaders) {
        $ResponseHeaders = ([ref]([hashtable]::new()))
      }
      if (-not $StatusCode) {
        $StatusCode = ([ref]([int]::new()))
      }

      # Invoke the API
      $data = Invoke-RateLimitedEndpoint `
        -Method $Method `
        -Uri $uri `
        -Headers $Headers `
        -Body $Body `
        -ResponseHeaders $ResponseHeaders `
        -StatusCode $StatusCode `
        -SkipHttpErrorCheck:$SkipHttpErrorCheck `
        -Raw:$Raw `
        -SearchText $SearchText `
        -OutFile $OutFile

      return $data
    }
    catch {
      Write-Host "Error: $($_.Exception.Message)"

      if ($_.Exception.Message -match "401|403") {
        # Clear Cached Etags and Last-Modified headers
        $Global:CachedEtags        = @{}
        $Global:CachedLastModified = @{}

        if (-not $AuthError) {
          $AuthError = $true
          Update-GitHubToken -Organization $env:GH_AUTH_ORG -Repository $env:GH_AUTH_REPO
          Write-Host "Retrying after 5 seconds..."
          Start-Sleep -Seconds 5

          $Headers["Authorization"] = "Bearer $(gh auth token)"
          continue
        }
        throw
      }

      if ($_.Exception.Message -match "500|502") {
        $RetryCount++
        if ($RetryCount -gt 5) { throw }
        Write-Host "Retrying after 60 seconds..."
        Start-Sleep -Seconds 60
        continue
      }

      throw
    }
  } while ($true)
}
