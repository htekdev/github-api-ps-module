Function Add-IndexAndTotal {

  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [array] $Items
  )

  $_ = $Items | ForEach-Object -Begin { $i = 0 } -Process { 
    $_ | Add-Member -MemberType NoteProperty -Name Index -Value $i -PassThru 
    $_ | Add-Member -MemberType NoteProperty -Name Total -Value $($Items.Count) -PassThru 
    $i++
  } -End { $i++ }

  return $Items


}
