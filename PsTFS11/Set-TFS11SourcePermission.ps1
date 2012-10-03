function Set-TFS11SourcePermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        $Collection,

        [Parameter(Mandatory=$true, Position = 1)]
        [ValidatePattern('^\$/')]
        [string]
        $ServerPath,

        [Parameter(Mandatory=$true, Position = 2)]
        $Identity,

        [Parameter(Mandatory=$true, Position = 3)]
        [Microsoft.TeamFoundation.VersionControl.Common.VersionedItemPermissions, Microsoft.TeamFoundation.VersionControl.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Allow,

        [Microsoft.TeamFoundation.VersionControl.Common.VersionedItemPermissions, Microsoft.TeamFoundation.VersionControl.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Deny = 0,

        [switch]
        $Replace
    )
    
    if ($Collection -is [string] -or $Collection -is [Uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Identity -is [string]) {
        $IdentityName = $Identity
        $Identity = Get-TFS11Identity -Connection $Collection -Name $IdentityName |
            Select-Object -First 1
        if (-not $Identity) {
            Write-Error "Could not resolve identity '$IdentityName'"
            return
        }
    }
    if ($Identity -is $MTF['Framework.Client.TeamFoundationIdentity']) {
        $Identity = $Identity.Descriptor
    }

    $SecurityService = $Collection.GetService($MTF['Framework.Client.ISecurityService'])
    $RepositorySecurityNamespace = $SecurityService.GetSecurityNamespace($MTF['VersionControl.Common.SecurityConstants']::RepositorySecurityNamespaceGuid)

    $SecurityToken = $ServerPath

    $Merge = -not [bool]$Replace
    $RepositorySecurityNamespace.SetPermissions($SecurityToken, $Identity, $Allow, $Deny, $Merge) | Out-Null
}
