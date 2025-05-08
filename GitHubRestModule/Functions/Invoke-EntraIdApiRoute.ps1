Function Invoke-EntraIdApiRoute {

	param(
			[string] $Path,
			[string] $Method = "Get",
			[string] $ContentType = "application/json",
			[string] $Body = $null
	)
  Write-Host "Invoking EntraId API Route: $Path"
  if([String]::IsNullOrEmpty($env:ENTRA_ID_ACCESS_TOKEN)){
    Update-EntraIdToken
  }

  try{
    $headers = [hashtable]::new()
    $headers.Add("Content-Type",$contentType)
    $headers.Add("Cache-Control","no-cache")
    $headers.Add("Authorization", "Bearer $($env:ENTRA_ID_ACCESS_TOKEN)")
  
    $uri = "https://graph.microsoft.com/beta$($Path)"
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method $Method -Body $Body
  
    return $response
  }
	catch{
    Write-Host "Error: $($_.Exception.Message)"
    return $null
  }


}
