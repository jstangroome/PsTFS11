function Get-TFS11Identity {
    [CmdletBinding(DefaultParameterSetName='Search')]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        [Alias('Collection', 'Server', 'ConfigurationServer')]
        [Microsoft.TeamFoundation.Client.TfsConnection, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Connection,

        [Parameter(ParameterSetName='Search', Mandatory=$true, Position = 1)]
        [Alias('DisplayName', 'AccountName')]
        [string]
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
        $Options = 'None'
    )

    $IdentityManagementService = $Connection.GetService($MTF['Framework.Client.IIdentityManagementService2'])

    switch ($PSCmdlet.ParameterSetname) {
        Descriptor {
            $IdentityManagementService.ReadIdentities($Descriptor, $Membership, $Options)
        }
        default {
            $IdentityManagementService.ReadIdentity($SearchFactor, $Name, $Membership, $Options)
        }
    }
}
