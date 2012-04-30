function Get-TFS11EventSubscription {
    [CmdletBinding(DefaultParameterSetName='User')]
    [OutputType([Microsoft.TeamFoundation.Framework.Client.Subscription, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    param (
        [Parameter(Mandatory=$true)]
        $Collection,

        [Parameter(ParameterSetName='User')]
        $User = '',

        [Parameter(ParameterSetName='All')]
        [switch]
        $AllUsers,

        [Microsoft.TeamFoundation.Framework.Client.DeliveryType[], Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $DeliveryType,

        [string]
        $EventType = '*'
    )

    if ($Collection -is [string] -or $Collection -is [Uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    $EventService = $Collection.GetService($MTF['Framework.Client.IEventService'])

    if ($PSCmdlet.ParameterSetName -eq 'All' -and $AllUsers) {
        $Events = $EventService.GetAllEventSubscriptions()
    } else {
        if ($PSCmdlet.ParameterSetName -ne 'User' -or -not $User) {
            $User = $Collection.AuthorizedIdentity.Descriptor
        }
        $Events = $EventService.GetEventSubscriptions($User)
    }

    $Events |
        Where-Object {
            $_.EventType -like $EventType -and
            (
                -not $PSBoundParameters.ContainsKey('DeliveryType') -or
                $DeliveryType -contains $_.DeliveryPreference.Type
            )
        }
}
