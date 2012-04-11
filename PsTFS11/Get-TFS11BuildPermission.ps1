function Get-TFS11BuildPermission {
    [CmdletBinding()]
    [OutputType('PsTFS11.AccessControlEntry')]
    param (
        [Parameter(Mandatory=$true)]
        $Collection,

        [Parameter(Mandatory=$true)]
        $ProjectName,

        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $BuildDefinition,

        [Microsoft.TeamFoundation.Framework.Client.IdentityDescriptor[], Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Descriptor = @()
    )

    if ($Collection -is [string] -or $Collection -is [Uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    $SecurityService = $Collection.GetService($MTF['Framework.Client.ISecurityService'])
    $BuildSecurityNamespace = $SecurityService.GetSecurityNamespace($MTF['Build.Common.BuildSecurity']::BuildNamespaceId)

    $Project = Get-TFS11TeamProject -Collection $Collection -ProjectName $ProjectName
    $SecurityToken = $MTF['LinkingUtilities']::DecodeUri($Project.Uri).ToolSpecificId

    if ($BuildDefinition) {
        $SecurityToken += $MTF['Build.Common.BuildSecurity']::NamespaceSeparator +
            $MTF['LinkingUtilities']::DecodeUri($BuildDefinition.Uri).ToolSpecificId
    }

    $IncludeExtendedInfo = $false
    $ACL = $BuildSecurityNamespace.QueryAccessControlList($SecurityToken, $Descriptor, $IncludeExtendedInfo)

    $Descriptors = $ACL.AccessControlEntries | Select-Object -ExpandProperty Descriptor
    $Identities = Get-TFS11Identity -Connection $Collection -Descriptor $Descriptors

    $ACL.AccessControlEntries |
        ForEach-Object {
            $ACE = $_
            $Result = New-Object -TypeName PSObject -Property @{
                Identity = $Identities |
                    Where-Object {
                        $_.Descriptor.Identifier -eq $ACE.Descriptor.Identifier -and
                        $_.Descriptor.IdentityType -eq $ACE.Descriptor.IdentityType
                    }
                Allow = [PsTFS11.BuildPermissions]$_.Allow
                Deny = [PsTFS11.BuildPermissions]$_.Deny
            }
            $Result.PSTypeNames.Insert(0, 'PsTFS11.AccessControlEntry')
            Write-Output $Result
        }

}
