Function New-TemporaryDirectory {

  $tempDir = [System.IO.Path]::GetTempFileName()
  Remove-Item $tempDir | Out-Null
  New-Item -ItemType Directory -Path $tempDir | Out-Null
  return $tempDir


}
