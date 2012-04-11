function Set-TFS11BuildPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        $Collection,

        [Parameter(Mandatory=$true, Position = 1)]
        [Alias('ProjectName')]
        $Project,

        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $BuildDefinition,

        [Parameter(Mandatory=$true)]
        $Identity,

        [PsTFS11.BuildPermissions]
        $Allow = 'None',

        [PsTFS11.BuildPermissions]
        $Deny = 'None',

        [switch]
        $Replace
    )
    
    if ($Collection -is [string] -or $Collection -is [Uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Project -is [string]) {
        $Project = Get-TFS11TeamProject -Collection $Collection -ProjectName $Project
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
    $BuildSecurityNamespace = $SecurityService.GetSecurityNamespace($MTF['Build.Common.BuildSecurity']::BuildNamespaceId)

    $SecurityToken = $MTF['LinkingUtilities']::DecodeUri($Project.Uri).ToolSpecificId

    if ($BuildDefinition) {
        $SecurityToken += $MTF['Build.Common.BuildSecurity']::NamespaceSeparator +
            $MTF['LinkingUtilities']::DecodeUri($BuildDefinition.Uri).ToolSpecificId
    }

    $Merge = -not [bool]$Replace
    $BuildSecurityNamespace.SetPermissions($SecurityToken, $Identity, $Allow, $Deny, $Merge) | Out-Null
}
