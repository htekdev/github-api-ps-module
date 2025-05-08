Function New-MeasureMedian {

  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [array] $Values
  )

  Process{
    $Values = $Values | Sort-Object
    $count = $Values.Count
    if($count % 2 -eq 0){
      return ($Values[$count / 2] + $Values[$count / 2 - 1]) / 2
    }
    else{
      return $Values[$count / 2]
    }
  }


}
