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

## Main Usage Scenarios

### How to Sign In
To authenticate with the GitHub API, ensure your environment variables are properly set up (e.g., `GITHUB_TOKEN` for personal access token authentication). Then, call the `Update-GitHubToken` cmdlet:

```powershell
Update-GitHubToken
```

This will authenticate your session and allow you to interact with the GitHub API.

### Invoke Simple GitHub API Endpoint
Use the `Invoke-GitHubApiRoute` cmdlet to perform simple API actions. For example:

```powershell
# Get repository details
Invoke-GitHubApiRoute -Method GET -Route "/repos/my-org/my-repo"

# Create a new issue
Invoke-GitHubApiRoute -Method POST -Route "/repos/my-org/my-repo/issues" -Body @{ title = "New Issue"; body = "Issue description" }
```

### Perform Pagination
Leverage the `Invoke-PaginatedGitHubApiRoute` cmdlet to handle paginated API responses automatically:

```powershell
# List all repositories in an organization
Invoke-PaginatedGitHubApiRoute -Method GET -Route "/orgs/my-org/repos"
```

### Perform a GraphQL Query
Use the `Invoke-GitHubGraphql` cmdlet to execute GraphQL queries:

```powershell
# Example GraphQL query
$query = @"
{
  repository(owner: \"my-org\", name: \"my-repo\") {
    issues(last: 5) {
      edges {
        node {
          title
          url
        }
      }
    }
  }
}
"@
Invoke-GitHubGraphql -Query $query
```

### Perform Pagination with GraphQL Queries
For paginated GraphQL queries, use the `Invoke-GitHubGraphqlQuery` cmdlet:

```powershell
# Example paginated GraphQL query
$query = @"
{
  repository(owner: \"my-org\", name: \"my-repo\") {
    issues(first: 5, after: $cursor) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          title
          url
        }
      }
    }
  }
}
"@
Invoke-GitHubGraphqlQuery -Query $query
```

### Handling 202 Responses for Data Loading
When an API endpoint returns a 202 status code due to data loading, use the `Invoke-GitHubApiRouteRetryOn202` cmdlet to handle retries automatically:

```powershell
Invoke-GitHubApiRouteRetryOn202 -Method GET -Route "/repos/my-org/my-repo/insights"
```

### Rate Limits and Throttling
This module automatically handles rate limits and throttling. To explicitly check rate limits, use the `Assert-GitHubRateLimits` cmdlet:

```powershell
Assert-GitHubRateLimits
```

If you prefer using the GitHub CLI (`gh`), this module integrates seamlessly and provides rate limit protection out of the box.


## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## Support
If you encounter any issues or have questions, feel free to open an issue in this repository.