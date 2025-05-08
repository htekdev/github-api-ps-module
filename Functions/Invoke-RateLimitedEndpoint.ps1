Function Invoke-RateLimitedEndpoint {

  Param(
    [string] $Uri,
    [string] $Method,
    [string] $Body,
    [hashtable] $Headers,
    [ref] $ResponseHeaders,
    [ref] $StatusCode,

    [switch] $Raw,
    [switch] $SkipHttpErrorCheck,
    [string] $SearchText,
    [string] $OutFile
  )

  $_responseHeaders = [hashtable]::new()
  $_statusCode = [int]::new()

  # Ensure Headers has Content-Type
  if(-not $Headers){
    $Headers = [hashtable]::new()
  }
  if(-not $Headers["Content-Type"]){
    $Headers.Add("Content-Type", "application/json")
  }

  # Add User-Agent
  if(-not $Headers["User-Agent"]){
    $Headers.Add("User-Agent", "PowerShell")
  }

  if(-not $Method){
    $Method = "GET"
  }

  $Headers.Remove("Content-Type")
  # Write-Host $($Headers | ConvertTo-Json -Depth 10)
  
  Write-Host "$($Method) $Uri"


  # Add Etag and Last-Modified headers if the URI is a GitHub API
  $lastCachedEtag = $null
  $lastCachedLastModified = $null
  $lastEtag = $null
  $lastModified = $null
  if($Uri -match "https://api.github.com/" -and $Method -eq "GET"){
    $lastEtag = $Global:CachedEtags[$Uri].Value
    $lastModified = $Global:CachedLastModified[$Uri].Value
    $lastCachedEtag = $Global:CachedEtags[$Uri].Cached
    $lastCachedLastModified = $Global:CachedLastModified[$Uri].Cached
    if($lastEtag){
      Write-Host "Using Etag: $lastEtag"
      $Headers["If-None-Match"] = "$($lastEtag)"
    }
    if($lastModified){
      Write-Host "Using Last-Modified: $lastModified"
      $Headers["If-Modified-Since"] = "$($lastModified)"
    }
  }


  
  # Wait for 1 second if not a GET request
  if($Method -ine "GET"){
    $newLastNonGetRequest = [datetime]::UtcNow
    $timeSinceLastNonGetRequest = $newLastNonGetRequest - $Global:LastNonGetRequest
    if($timeSinceLastNonGetRequest.TotalSeconds -lt 1){
      Write-Host "Waiting for 1 second to avoid rate limiting"
      Start-Sleep -Seconds 1
    }
    $Global:LastNonGetRequest = $newLastNonGetRequest
  }

  $extraParameters = @{}
  # If Powershell 5.1 add TimeoutSec
  if($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1){
    $extraParameters.Add("TimeoutSec", 60)
  }

  # If Powershell 7.0 add OperationTimeoutSeconds
  if($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -eq 0){
    $extraParameters.Add("OperationTimeoutSeconds", 60)
    $extraParameters.Add("ConnectionTimeoutSeconds", 60)
  }

 
  $httpClient = New-Object System.Net.Http.HttpClient
  $httpRequestMessage = New-Object System.Net.Http.HttpRequestMessage
  $httpRequestMessage.Method = [System.Net.Http.HttpMethod]::$Method
  $httpRequestMessage.RequestUri = [Uri]$Uri

  foreach ($key in $Headers.Keys) {
      $httpRequestMessage.Headers.Add($key, $Headers[$key])
  }

  if ($Body) {
      $httpRequestMessage.Content = [System.Net.Http.StringContent]::new($Body, [System.Text.Encoding]::UTF8, "application/json")
  }

  $httpResponse = $httpClient.SendAsync($httpRequestMessage, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

  $stream = $httpResponse.Content.ReadAsStreamAsync().Result
  $reader = [System.IO.StreamReader]::new($stream)
  if($OutFile){
    # Pipe the stream to outfile
    $writer = [System.IO.StreamWriter]::new($OutFile)
    $reader.BaseStream.CopyTo($writer.BaseStream)
    $writer.Close()
    $reader.Close()
  }
  $found = $false
  $content = ""

  try {
    while ($true -and -not $OutFile) {
        $buffer = $reader.ReadLine()
        if ($buffer -eq $null) { break }
        if($OutFile){
          Add-Content -Path $OutFile -Value $buffer
        }
        $content += $buffer + "`n"
        if (-not [String]::IsNullOrEmpty($SearchText) -and $content -match $SearchText) {
            $found = $true
            break
        }
    }
  } finally {
    $reader.Close()
    $stream.Close()
    $httpClient.Dispose()
  }
  

  # Write-Host "Response: $content"
  
  $data = if($Raw -or $OutFile){ $content } else { $content | ConvertFrom-Json }
  $_statusCode = $httpResponse.StatusCode
  $_responseHeaders = [hashtable]::new()

  foreach($head in $httpResponse.Headers){
    $_responseHeaders.Add($head.Key, $head.Value)
  }
  

  

  # Response Headers
  # Write-Host $($_responseHeaders | ConvertTo-Json)


  # Cache Etag and Last-Modified headers
  if($Uri -match "https://api.github.com/"){

    if($_statusCode -eq 304){
      Write-Host "Using cached data"
      
      if($lastCachedEtag){
        $data = $lastCachedEtag
      }
      if($lastCachedLastModified){
        $data =$lastCachedLastModified
      }
      $_statusCode = 200
    }
    else{
      if($_responseHeaders["ETag"]){
        $Global:CachedEtags[$Uri] = @{
          Value = $_responseHeaders["ETag"]
          Cached = $data
        }
          
      }
      if($_responseHeaders["Last-Modified"]){
        $Global:CachedLastModified[$Uri] = {
          Value = $_responseHeaders["Last-Modified"]
          Cached = $data
        }
  
      }
    }
  }

  # Clear Cached Etags and Last-Modified headers
  $Global:CachedEtags = @{}
  $Global:CachedLastModified = @{}

  # Retry if 401 after updating token
  if($_statusCode -eq 401) {
    Update-GitHubToken -Organization $env:GH_AUTH_ORG -Repository $env:GH_AUTH_REPO
    $Headers["Authorization"] = "Bearer $(gh auth token)"
    Write-Host "Retrying after 5 seconds..."
    Start-Sleep -Seconds 5

    # Clear Cached Etags and Last-Modified headers
    $Global:CachedEtags = @{}
    $Global:CachedLastModified = @{}
    $Global:RateLimitRetryCount += 1
    try{ return Invoke-RateLimitedEndpoint -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ResponseHeaders $ResponseHeaders -StatusCode $StatusCode -Raw:$Raw -SkipHttpErrorCheck:$SkipHttpErrorCheck -SearchText $SearchText }
    catch{ throw $_ }
    finally {
      $Global:RateLimitRetryCount -= 1
    }
  }

  # Retry if 202
  if($_responseHeaders["Retry-After"]){
    $wait = [int]::Parse($_responseHeaders["Retry-After"])

    # Exponential backoff
    $waitTotalSeconds =  [Math]::Pow($wait.TotalSeconds, [Math]::Pow(2, $Global:RateLimitRetryCount))
    Write-Host "Waiting for $waitTotalSeconds seconds due to Retry-After header `n  (Wait Time $($wait.TotalSeconds) seconds, Retry Count $($Global:RateLimitRetryCount), Total Wait Time $($waitTotalSeconds) seconds)"
    
    Start-Sleep -Seconds $waitTotalSeconds
    
    # Clear Cached Etags and Last-Modified headers
    $Global:CachedEtags = @{}
    $Global:CachedLastModified = @{}
    $Global:RateLimitRetryCount += 1
    try{ return Invoke-RateLimitedEndpoint -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ResponseHeaders $ResponseHeaders -StatusCode $StatusCode -Raw:$Raw -SkipHttpErrorCheck:$SkipHttpErrorCheck -SearchText $SearchText }
    catch{ throw $_ }
    finally {
      $Global:RateLimitRetryCount -= 1
    }
    
  }

  # Check rate limit
  if($_responseHeaders["X-RateLimit-Limit"]){
    $rateLimitRemaining = [int]::Parse($_responseHeaders["X-RateLimit-Remaining"])
    $rateLimitReset = [int]::Parse($_responseHeaders["X-RateLimit-Reset"])
    $rateLimitResetAt = [datetime]::new(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc).AddSeconds($rateLimitReset)
    # Write-Host "Rate Limit: $rateLimitRemaining of $rateLimit remaining"
    # Write-Host "Rate Limit Reset: $rateLimitResetAt"
    # Write-Host "Rate Limit Cost: $rateLimitCost"
    # Write-Host "Rate Limit Reset: $rateLimitResetAt"
  
    # Wait for the rate limit to reset
    if($rateLimitRemaining -eq 0){
      $wait = $rateLimitResetAt - [datetime]::UtcNow

      # Exponential backoff
      $waitTotalSeconds =  [Math]::Pow($wait.TotalSeconds, [Math]::Pow(2, $Global:RateLimitRetryCount))
      Write-Host "Waiting for $waitTotalSeconds seconds due to rate limit `n  (Wait Time $($wait.TotalSeconds) seconds, Retry Count $($Global:RateLimitRetryCount), Total Wait Time $($waitTotalSeconds) seconds)"
      
      $waitTotalSeconds += 20
      Start-Sleep -Seconds $waitTotalSeconds
      
      if(-not $ResponseHeaders){
        $ResponseHeaders = ([ref]([hashtable]::new()))
      }
      if(-not $StatusCode){
        $StatusCode = ([ref]([int]::new()))
      }
      
      # Clear Cached Etags and Last-Modified headers
      $Global:CachedEtags = @{}
      $Global:CachedLastModified = @{}
      
      # Retry the request
      $Global:RateLimitRetryCount += 1
      try{ return Invoke-RateLimitedEndpoint -Uri $Uri -Method $Method -Body $Body -Headers $Headers -ResponseHeaders $ResponseHeaders -StatusCode $StatusCode -Raw:$Raw -SkipHttpErrorCheck:$SkipHttpErrorCheck }
      catch{ throw $_ }
      finally {
        $Global:RateLimitRetryCount -= 1
      }
    }
  }

  
  # Check if the status code is an error
  if(-not $SkipHttpErrorCheck -and ($_statusCode -lt 200 -or $_statusCode -gt 299)) {
    throw "HTTP Error: $($_statusCode), `n$data"
  }


  if($ResponseHeaders) {
    $ResponseHeaders.Value = $_responseHeaders
  }
  if($StatusCode) {
    $StatusCode.Value = $_statusCode
  }

  


  return $data


}
