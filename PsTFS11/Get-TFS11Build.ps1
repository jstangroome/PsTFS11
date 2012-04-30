function Get-TFS11Build {
    [CmdletBinding(DefaultParameterSetName='Query')]
    [OutputType([Microsoft.TeamFoundation.Build.Client.IBuildDetail, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    param (
        [Parameter(ParameterSetName='Uri', Mandatory=$true, Position=0)]
        [Uri]
        $BuildUri,

        [Parameter(ParameterSetName='Uri', Mandatory=$true)]
        [Parameter(ParameterSetName='Query')]
        $Collection,

        [Parameter(ParameterSetName='Query')]
        $Project = '*',
        [Parameter(ParameterSetName='Query')]
        $Definition, # TODO consider IBuildDefinition, names, and a mixed array from different Collections
        [Parameter(ParameterSetName='Query')]
        [string]
        $BuildNumber,
        [Parameter(ParameterSetName='Query')]
        [string]
        $Quality,
        [Parameter(ParameterSetName='Query')]
        [Microsoft.TeamFoundation.Build.Client.BuildStatus, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Status = 'All',
        [Parameter(ParameterSetName='Query')]
        [Microsoft.TeamFoundation.Build.Client.BuildReason, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Reason = 'All',
        
        [Parameter(ParameterSetName='Query')]
        [int]
        $MaxBuildsPerDefinition,

        [Parameter(ParameterSetName='Query')]
        [Microsoft.TeamFoundation.Build.Client.BuildQueryOrder, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $QueryOrder = 'StartTimeDescending',

        [Parameter(ParameterSetName='Query')]
        [DateTime]
        $FinishedAfter
    )

    if ($PSCmdlet.ParameterSetName -eq 'Uri') {
        if ($Collection -is [string] -or $Collection -is [Uri]) {
            $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
        }
        $BuildServer = $Collection.GetService($MTF['Build.Client.IBuildServer'])

        return $BuildServer.GetBuild($BuildUri)
    }

    if ($Definition -is $MTF['Build.Client.IBuildDefinition']) {
        $Collection = $Definition.BuildServer.TeamProjectCollection
    }

    $BuildServer = $Collection.GetService($MTF['Build.Client.IBuildServer'])

    if ($Definition -is $MTF['Build.Client.IBuildDefinition']) {
        [Uri[]]$DefUris = @($Definition.Uri)
        $Spec = $BuildServer.CreateBuildDetailSpec($DefUris)
    } else {
        $DefSpec = $BuildServer.CreateBuildDefinitionSpec($Project) 
        if ($Definition) {
            $DefSpec.Name = $Definition
        }
        $Spec = $BuildServer.CreateBuildDetailSpec($DefSpec)
    }
    if ($BuildNumber) {
        $Spec.BuildNumber = $BuildNumber
    }
    if ($Quality) {
        $Spec.Quality = $Quality
    }
    if ($MaxBuildsPerDefinition -gt 0) {
        $Spec.MaxBuildsPerDefinition = $MaxBuildsPerDefinition
    }
    $Spec.Status = $Status
    $Spec.Reason = $Reason
    $Spec.QueryOrder = $QueryOrder
    if ($PSBoundParameters.ContainsKey('FinishedAfter')) {
        $Spec.MinFinishTime = $FinishedAfter
    }

    Write-Output $BuildServer.QueryBuilds($Spec).Builds
}