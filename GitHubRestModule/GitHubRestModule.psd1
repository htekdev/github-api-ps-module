@{
    # Module metadata
    RootModule        = 'GitHubRestModule.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'aa1d7fd8-740b-47ea-ba8a-3e72031f035f'
    Author            = 'Hector'
    CompanyName       = 'htekdev'
    Description       = 'GitHub REST API PowerShell Module'

    # Dependencies
    RequiredModules   = @('powershell-yaml', 'jwtPS')
    RequiredAssemblies = @()

    # Exported components
    FunctionsToExport = '*'
    CmdletsToExport   = '*'
    VariablesToExport = '*'
    AliasesToExport   = '*'

    # Private data
    PrivateData = @{
        PSData = @{
            Tags        = @('GitHub', 'RESTAPI', 'PowerShell')
            LicenseUri  = 'https://github.com/htekdev/github-api-ps-module/blob/master/LICENSE'
            ProjectUri  = 'https://github.com/htekdev/github-api-ps-module'
            ReleaseNotes = 'Initial release'
        }
    }
}