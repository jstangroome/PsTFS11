function Get-TFS11TeamProjectCollection {
    [CmdletBinding(DefaultParameterSetName='Collection')]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Collection')]
        [ValidatePattern('^https?://')]
        [Alias('Uri')]
        [string]
        $CollectionUri,

        [Parameter(Mandatory=$true, ParameterSetName='Server')]
        [Alias('Server')]
        $ConfigurationServer,
        
        [Parameter(ParameterSetName='Server')]
        [Alias('Name')]
        [string]
        $CollectionName = '*'
    )
    begin {
        $CollectionFactoryType = $MTF['Client.TfsTeamProjectCollectionFactory']
        $ResourceTypes = $MTF['Framework.Common.CatalogResourceTypes']
        [Guid[]]$CollectionFilter = @($ResourceTypes::ProjectCollection)
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            Server {
                if ($ConfigurationServer -is [string] -or $ConfigurationServer -is [Uri]) {
                    $ConfigurationServer = Get-TFS11ConfigurationServer -Uri $ConfigurationServer
                }
                $LocationService = $ConfigurationServer.GetService($MTF['Framework.Client.ILocationService'])
                $ConfigurationServer.CatalogNode.QueryChildren($CollectionFilter, $false, 'None') |
                    Where-Object { $_.Resource.DisplayName -like $CollectionName } |
                    ForEach-Object {
                        $CollectionFactoryType::GetTeamProjectCollection(
                            $LocationService.LocationForCurrentConnection(
                                $_.Resource.ServiceReferences['Location']            
                            )
                        )
                    }
            }
            Collection {
                $CollectionFactoryType::GetTeamProjectCollection($CollectionUri)
            }
        }
    }
}
