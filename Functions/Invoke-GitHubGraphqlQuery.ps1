Function Invoke-GitHubGraphqlQuery {

  Param(
    [string] $Query,
    [string] $ItemsProperty,
    [string] $Token = "$(gh auth token)",
    [scriptblock] $StopCondition
  )

  # Ensure Query has %LAST_CURSOR%
  if($Query -notmatch "%LAST_CURSOR%"){
    throw "Query must contain %LAST_CURSOR%"
  }

  # Ensure Query has pageInfo
  if($Query -notmatch "pageInfo"){
    throw "Query must contain pageInfo"
  }
  
  $items = @()
  $cursor = "null"
  do{
    $new_query = $query -replace "%LAST_CURSOR%", $cursor
    $result= $(Invoke-GitHubGraphql -Path "graphql" -Query $new_query )
    $items += "@(`$result.data.$($ItemsProperty).nodes)" | Invoke-Expression
    $cursor = "`"```"`$(`$result.data.$($ItemsProperty).pageInfo.endCursor)```"`"" | Invoke-Expression

    if($StopCondition){
      if(&$StopCondition -Items $items -Result $result){
        break
      }
    }
  }while("`$result.data.$($ItemsProperty).pageInfo.hasNextPage" | Invoke-Expression)

  return $items



}
