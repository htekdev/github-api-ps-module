Function Invoke-PaginatedGitHubApiRoute {

  Param(
    [string] $Path,
    [hashtable] $Query = [hashtable]::new(),
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)",
    [int] $PageSize = 50,
    [string] $ArrayProperty,
    [scriptblock] $StopCondition
  )
  $Global:CachedEtags = @{}
  $Global:CachedLastModified = @{}

  # if no page is specified, start at 1
  if(-not $Page) {
    $Page = 1
  }
  $Query["page"] = $Page
  $Query["per_page"] = $PageSize

  
  $items = @()
  do{
    # Add page and page size to query

    $responseHeaders= [hashtable]::new()

    # Invoke the API
    $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token -ResponseHeaders ([ref]$responseHeaders)

    

    if($ArrayProperty){
      $data = $data.$ArrayProperty
    }
    else{
      $data = @($data)
    }

    # Add the data to the items array
    $items += $data

    # Return if no data
    if($data.Count -lt $PageSize) {
      return $items
    }

    # Increment the page
    $Page = $Page + 1
    
    if($StopCondition){
      if(&$StopCondition -Items $data -Result $data){
        return $items
      }
    }
    
    # Link header
    $link = $responseHeaders."Link"
    # link: <https://api.github.com/repositories/1300192/issues?page=2>; rel="prev", <https://api.github.com/repositories/1300192/issues?page=4>; rel="next", <https://api.github.com/repositories/1300192/issues?page=515>; rel="last", <https://api.github.com/repositories/1300192/issues?page=1>; rel="first"
    
    # Pull out path, query for the next link
    $nextLink = @($link -split "," | Where-Object { $_ -match 'rel="next"' } | ForEach-Object {
      $_ -replace ".*<([^>]+)>.*", '$1'
    })

    if(-not $nextLink){
      return $items
    }

    $nextLink = $nextLink[0]

    # Pull out path, query for the last link
    $Path = $nextLink -replace "https://api.github.com/", ''
    $Path = $Path -replace "\?.*", ''
    
    $query_s = $nextLink -replace ".*\?(.*)$", '$1'
    $query_s -split "&" | ForEach-Object {
      $split = $_ -split "="
      @{
        key = $split[0]
        value = $split[1]
      }
    } | ForEach-Object {
      $Query[$_.key] = $_.value
    }

    Write-Host "Getting next page: $Path, Query: $($Query | ConvertTo-Json -Compress)"


  }while($true)


}
