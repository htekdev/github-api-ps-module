Function Update-EntraIdToken {

  Write-Host "Updating EntraId Token..."
  $TenantId = $env:IAM_APP_TENANT_ID
  $TokenEndpoint = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token"
  $Scope = "https://graph.microsoft.com/.default"
  $ClientId = $env:IAM_APP_CLIENT_ID
  $ClientSecret = $env:IAM_APP_CLIENT_SECRET
  $body = $(@(
        @{name="client_id"; value=$ClientId;},
        @{name="client_secret"; value=$ClientSecret;},
        @{name="grant_type"; value="client_credentials";},
        @{name="scope"; value=$Scope;}
      ) | Foreach-Object {
        "{0}={1}" -f $_.name, [System.Web.HttpUtility]::UrlEncode($_.value)
      }) -join "&"

  $results = Invoke-RestMethod -Uri $TokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded" -Method POST
  $accessTokenStr = $results.access_token
  $env:ENTRA_ID_ACCESS_TOKEN = $accessTokenStr


}
