Function New-GitHubJWT {

  Param(
    [string] $Certificate = $($env:GH_APP_CERTIFICATE),
    [string] $AppId = $($env:GH_APP_ID)
  )

  if([String]::IsNullOrEmpty($Certificate) -and -not [String]::IsNullOrEmpty($env:GH_APP_CERTIFICATE_FILE_PATH)){
    $Certificate = Get-Content -Path $env:GH_APP_CERTIFICATE_FILE_PATH
  }

  $encryption = [jwtTypes+encryption]::SHA256
  $algorithm = [jwtTypes+algorithm]::RSA
  $alg = [jwtTypes+cryptographyType]::new($algorithm, $encryption)

  # 
  $payload = @{
    iss = $AppId
    exp = ([System.DateTimeOffset]::Now.AddMinutes(9)).ToUnixTimeSeconds()
    iat = ([System.DateTimeOffset]::Now).ToUnixTimeSeconds()
  }

  #  
  $keyContent  = $Certificate
  return New-JWT -Payload $payload -Algorithm $alg -Secret $keyContent


}
