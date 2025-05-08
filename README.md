# GitHub API PowerShell Module

## Overview

The `github-api-ps-module` is a PowerShell module designed to simplify interactions with the GitHub API. It provides a collection of cmdlets to perform various operations, such as managing repositories, organizations, and interacting with GitHub's REST and GraphQL APIs. This module is ideal for developers and administrators who want to automate GitHub workflows.

## Features
- **GitHub API Integration**: Seamlessly interact with GitHub's REST and GraphQL APIs.
- **Rate Limiting Management**: Handle GitHub API rate limits effectively.
- **JWT Authentication**: Generate and use JSON Web Tokens (JWT) for GitHub App authentication.
- **Pagination Support**: Easily handle paginated API responses.
- **Markdown Utilities**: Create and manipulate Markdown content.
- **Temporary Directories**: Manage temporary directories for intermediate operations.

## Prerequisites
- PowerShell 6 or later
- A GitHub account
- GitHub App credentials (if using JWT authentication)

## Environment Variables

### For Personal Access Token Authentication
- `GITHUB_TOKEN`: Required for authenticating with the GitHub API when not using JWT.

### For GitHub App Authentication
- `GITHUB_APP_ID`: Required for generating JWTs for GitHub App authentication.
- `GITHUB_PRIVATE_KEY`: The private key string for JWT generation (optional).
- `GITHUB_PRIVATE_KEY_PATH`: Path to the private key file for JWT generation (alternative to `GITHUB_PRIVATE_KEY`).

Ensure these variables are set in your environment before running the module.

## Installation
1. Clone this repository:
   ```powershell
   git clone https://github.com/your-repo/github-api-ps-module.git
   ```
2. Import the module:
   ```powershell
   Import-Module ./GitHubRestModule.psd1
   ```

## Usage
Below are some examples of how to use the cmdlets provided by this module:

### Get GitHub Repositories
```powershell
Get-GitHubRepositories -OrganizationName "my-org"
```

### Invoke a GitHub API Route
```powershell
Invoke-GitHubApiRoute -Method GET -Route "/repos/my-org/my-repo"
```

### Generate a GitHub JWT
```powershell
New-GitHubJWT -AppId 12345 -PrivateKeyPath "./private-key.pem"
```

### Handle Rate Limits
```powershell
Assert-GitHubRateLimits
```

## Cmdlets
Here is a list of available cmdlets:

### General Utilities
- `Add-IndexAndTotal`
- `Convert-ToNormalPath`
- `Get-CommentParameters`
- `Get-MarkdownNoWrap`
- `Get-RelativePathFromFolder`
- `Get-RootFolder`
- `New-MeasureMedian`
- `New-TemporaryDirectory`

### GitHub API
- `Get-GitHubOrganizations`
- `Get-GitHubRepositories`
- `Get-RepoDetails`
- `Invoke-GitHubApiRoute`
- `Invoke-GitHubApiRouteNullOn404`
- `Invoke-GitHubApiRouteRetryOn202`
- `Invoke-GitHubApiRouteUsingAppJWT`
- `Invoke-GitHubGraphql`
- `Invoke-GitHubGraphqlQuery`
- `Invoke-PaginatedGitHubApiRoute`
- `Invoke-RateLimitedEndpoint`
- `New-GitHubJWT`
- `Update-GitHubToken`

### Entra ID API
- `Invoke-EntraIdApiRoute`
- `Invoke-PaginatedEntraIdApiRoute`
- `Update-EntraIdToken`

### Markdown Utilities
- `New-Markdown`
- `Set-ReadmeSection`

## Additional Requirements
- **GitHub CLI (`gh`)**: This module requires the GitHub CLI to be installed and configured for certain operations. You can download it from [GitHub CLI](https://cli.github.com/).

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## Support
If you encounter any issues or have questions, feel free to open an issue in this repository.