function Remove-TFS11EventSubscription {
    [CmdletBinding(DefaultParameterSetName='ID', SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        $Collection,

        [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true, ParameterSetName='ID')]
        [int[]]
        $ID,

        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ParameterSetName='Subscription')]
        [Microsoft.TeamFoundation.Framework.Client.Subscription[], Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Subscription
    )

    process {
        if ($Collection -is [string] -or $Collection -is [Uri]) {
            $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
        }

        $EventService = $Collection.GetService($MTF['Framework.Client.IEventService'])

        if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
            foreach ($SingleSubscription in $Subscription) {
                $SingleID = $SingleSubscription.ID
                if ($PSCmdlet.ShouldProcess($SingleID, 'Unsubscribe event')) {
                    Write-Verbose "Unsubscribing event '$SingleID'"
                    $EventService.UnsubscribeEvent($SingleID)
                }
            }
        } else {
            foreach ($SingleID in $ID) {
                if ($PSCmdlet.ShouldProcess($SingleID, 'Unsubscribe event')) {
                    Write-Verbose "Unsubscribing event '$SingleID'"
                    $EventService.UnsubscribeEvent($SingleID)
                }
            }
        }
    }
}
