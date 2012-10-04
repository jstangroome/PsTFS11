function Get-TFS11WorkItemType {
    [OutputType([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemType, Microsoft.TeamFoundation.WorkItemTracking.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Project,

        $Collection,

        [Alias('Name')]
        [string]
        $WorkItemTypeName = '*'
    )

    if ($Project -is $MTF['Server.ProjectInfo']) {
        if ($Project.Collection) {
            $Collection = $Project.Collection
        }
        $Project = $Project.Name
    }

    if ($Collection -is [string] -or $Collection -is [uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if ($Collection -isnot $MTF['Client.TfsTeamProjectCollection']) {
        throw 'Invalid collection.'
    }

    $Store = $Collection.GetService($MTF['WorkItemTracking.Client.WorkItemStore'])
    $Store.Projects[$Project].WorkItemTypes |
        Where-Object { $_.Name -like $WorkItemTypeName }
}
