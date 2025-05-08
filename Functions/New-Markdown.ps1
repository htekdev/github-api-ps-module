Function New-Markdown {

    param (
        [string]$Product,
        [string]$ProductUrl,
        [string]$ProductDescription,
        [array]$Changes
    )

    $markdown += "# $Product **[🌐]($ProductUrl)**"
    $markdown += ""
    $markdown += "$ProductDescription"
    $markdown += ""
    $markdown += "| Release Title | Content |"
    $markdown += "| ------------- | ------- |"

    

    foreach ($change in $Changes) {
        $content =  Invoke-GitHubApiRoute -Path "markdown" -Method POST -Body $(@{
          text = $change.Description
          context = $($env:GITHUB_REPOSITORY)
        } | ConvertTo-Json) -Raw

        $content = $content -replace "`n", ""

        $markdown += "| <h3>$($change.Title)</h3> * $($change.PubDate.ToString('yyyy-MM-dd'))* **[ Link]($($change.Link))** | $($content) |"
    }
    $markdown += ""

    return $markdown | Out-String


}
