function Get-TFS11Identity {
    [OutputType([Microsoft.TeamFoundation.Framework.Client.TeamFoundationIdentity, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    [CmdletBinding(DefaultParameterSetName='Search')]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        [Alias('Collection', 'Server', 'ConfigurationServer')]
        $Connection,

        [Parameter(ParameterSetName='Search', Mandatory=$true, Position = 1)]
        [Alias('DisplayName', 'AccountName')]
        [string[]]
        $Name,

        [Parameter(ParameterSetName='Search')]
        [Microsoft.TeamFoundation.Framework.Common.IdentitySearchFactor, Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $SearchFactor = 'DisplayName',

        [Parameter(ParameterSetName='Descriptor', Mandatory=$true)]
        [Microsoft.TeamFoundation.Framework.Client.IdentityDescriptor[], Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Descriptor,

        [Microsoft.TeamFoundation.Framework.Common.MembershipQuery, Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Membership = 'None',

        [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions, Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Options = 'None',

        [switch]
        $IncludeInactive
    )

    if ($Connection -is [string] -or $Connection -is [uri]) {
        $Connection = Get-TFS11TeamProjectCollection -CollectionUri $Connection
        # what about configuration server uris?
    }

    if ($Connection -isnot $MTF['Client.TfsConnection']) {
        throw "Invalid Connection"
    }

    $IdentityManagementService = $Connection.GetService($MTF['Framework.Client.IIdentityManagementService2'])

    switch ($PSCmdlet.ParameterSetName) {
        Descriptor {
            $Result = $IdentityManagementService.ReadIdentities($Descriptor, $Membership, $Options)
        }
        default {
            $ResultSet = $IdentityManagementService.ReadIdentities($SearchFactor, $Name, $Membership, $Options)
            $Result = $ResultSet | % { $_ } # unroll
        }
    }

    $Result | Where-Object { $IncludeInactive -or $_.IsActive }
}
