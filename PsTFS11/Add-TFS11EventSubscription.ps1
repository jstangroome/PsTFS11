function Add-TFS11EventSubscription {
    [OutputType([Microsoft.TeamFoundation.Framework.Client.Subscription, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Collection,

        [Parameter(Mandatory=$true)]
        [string]
        $EventType,

        [Parameter(Mandatory=$true)]
        [string]
        $Condition,

        [Parameter(Mandatory=$true)]
        [Microsoft.TeamFoundation.Framework.Client.DeliveryType, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $DeliveryType,

        [Microsoft.TeamFoundation.Framework.Client.DeliverySchedule, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Schedule = 'Immediate',

        [Parameter(Mandatory=$true)]
        [string]
        $Address
    )

    if ($Collection -is [string] -or $Collection -is [uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Collection -isnot $MTF['Client.TfsTeamProjectCollection']) {
        throw 'Invalid collection.'
    }

    Write-Verbose "$($MyInvocation.MyCommand): Subscribing to event '$EventType' in collection '$($Collection.Uri)' with condition '$Condition' delivered as '$DeliveryType' on schedule '$Schedule' to address '$Address' "

    $EventService = $Collection.GetService($MTF['Framework.Client.IEventService'])

    $DeliveryPreference = New-Object -TypeName $MTF['Framework.Client.DeliveryPreference']
    $DeliveryPreference.Type = $DeliveryType
    $DeliveryPreference.Schedule= $Schedule
    $DeliveryPreference.Address = $Address

    $ID = $EventService.SubscribeEvent($EventType, $Condition, $DeliveryPreference)

    Get-TFS11EventSubscription -Collection $Collection |
        Where-Object { $_.ID -eq $ID } |
        Select-Object -First 1
}
