function Get-TFS11BuildDefinition {
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDefinition, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    param (
        $Project = '*',
        $Collection,
        $Name = '*'
    )

    if ($Project -is $MTF['Server.ProjectInfo']) {
        if ($Project.Collection) { 
            $Collection = $Project.Collection
        }
        $Project = $Project.Name
    }

    if ($Collection -is [string] -or $Collection -is [Uri]) {
        $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
    }

    if (-not $Collection) {
        throw "Collection required"
    }

    $BuildServer = $Collection.GetService($MTF['Build.Client.IBuildServer'])
    $Spec = $BuildServer.CreateBuildDefinitionSpec($Project) 
    $Spec.Options = 'All'
    $Spec.Name = $Name

    Write-Output $BuildServer.QueryBuildDefinitions($Spec).Definitions 
}
