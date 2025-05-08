

# Global variables to cache Etags and Last-Modified headers


# Import all functions from the Functions folder
Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter *.ps1 | ForEach-Object {
    . $_.FullName

    Export-ModuleMember -Function $_.BaseName
}
