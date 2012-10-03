function Get-TFS11TeamProjectPermission {
    [CmdletBinding()]
    [OutputType([PsTFS11.AuthorizationProjectPermissions])]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        [Alias('ProjectName')]
        $Project,

        $Collection,

        [Parameter(Mandatory=$true)]
        [Alias('IdentityDescriptor')]
        $Identity
    )

    if ($Project -is $MTF['Server.ProjectInfo'] -and $Project.Collection) { 
        $Collection = $Project.Collection
    }

    if ($Collection -is [string] -or $Collection -is [uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Collection -isnot $MTF['Client.TfsTeamProjectCollection']) {
        throw "Invalid Collection"
    }

    if ($Project -is [string]) {
        $Project = Get-TFS11TeamProject -Collection $Collection -ProjectName $Project
    }

    if ($Project -isnot $MTF['Server.ProjectInfo']) {
        throw "Invalid project"
    }

    if ($Identity -is [string]) {
        $Identity = Get-TFS11Identity -Connection $Collection -Name $Identity
    }

    if ($Identity -is $MTF['Framework.Client.TeamFoundationIdentity']) {
        $Identity = $Identity.Descriptor
    }
    
    if ($Identity -isnot $MTF['Framework.Client.IdentityDescriptor']) {
        throw "Invalid identity"
    }
    
    $SecurityService = $Collection.GetService($MTF['Framework.Client.ISecurityService'])
    $ProjectSecurityNamespace = $SecurityService.GetSecurityNamespace($MTF['Server.AuthorizationSecurityConstants']::ProjectSecurityGuid)

    $SecurityToken = $MTF['Server.AuthorizationSecurityConstants']::ProjectSecurityPrefix + $Project.Uri

    [PsTFS11.AuthorizationProjectPermissions]$ProjectSecurityNamespace.QueryEffectivePermissions($SecurityToken, $Identity)
}
