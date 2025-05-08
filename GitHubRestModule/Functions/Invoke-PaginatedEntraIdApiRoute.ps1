Function Invoke-PaginatedEntraIdApiRoute {

  param(
      [string] $Path,
      [string] $Method = "Get",
      [string] $ContentType = "application/json",
      [string] $Body = $null,
      [int] $Limit = 0
  )

  $response = @()
  do{

    $data = Invoke-EntraIdApiRoute -Path $($Path) -Method $Method -ContentType $ContentType -Body $Body

    # $data = 
    # {
    #    "@odata.context": ".."
    #    "@odata.nextLink": "https://graph.microsoft.com/beta/..."
    #    "value": [
    #        ...
    #    ]
    # }

    if(-not $data){
      throw "No data returned from API"
      break
    }
    
    $response += @($data.value)
    $Path = $data."@odata.nextLink" -replace "https://graph.microsoft.com/beta", ''

    if($Limit -gt 0 -and $response.Count -ge $Limit){
      break
    }
    
  }while($Path)

  return $response


}
