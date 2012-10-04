function Remove-TFS11TeamProjectCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Collection,

        [string]
        $StopMessage

        #[switch]
        #$Delete
    )

    if ($Collection -is [string] -or $Collection -is [uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Collection -isnot $MTF['Client.TfsTeamProjectCollection']) {
        throw 'Invalid collection.'
    }

    $InstanceId = $Collection.InstanceId

    $ServicingTokens = $null
    $ConnectionString = ''

    $Server = $Collection.ConfigurationServer
    $CollectionService = $Server.GetService([Microsoft.TeamFoundation.Framework.Client.ITeamProjectCollectionService])

    $Job = $CollectionService.QueueDetachCollection($InstanceId, $ServicingTokens, $StopMessage, [ref]$ConnectionString)
    $ResultCollection = $CollectionService.WaitForCollectionServicingToComplete($Job)

    return (New-Object -TypeName PSObject -Property @{
        Collection = $ResultCollection
        ConnectionString = $ConnectionString
    })

}