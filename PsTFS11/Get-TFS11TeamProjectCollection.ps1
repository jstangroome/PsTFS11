function Get-TFS11TeamProjectCollection {
    [CmdletBinding(DefaultParameterSetName='Collection')]
    [OutputType([Microsoft.TeamFoundation.Client.TfsTeamProjectCollection, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Collection')]
        [ValidatePattern('^https?://')]
        [Alias('Uri')]
        [Uri]
        $CollectionUri,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ParameterSetName='Collection')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

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
                $TfsCred = $MTF['Client.TfsClientCredentials']
                $CollectionArgs = @($CollectionUri)
                if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
                    $WindowsCred = New-Object -TypeName $MTF['Client.WindowsCredential'] -ArgumentList $Credential.GetNetworkCredential()
                    $CollectionArgs += New-Object -TypeName $MTF['Client.TfsClientCredentials'] -ArgumentList $WindowsCred
                }
                New-Object -TypeName $MTF['Client.TfsTeamProjectCollection'] -ArgumentList $CollectionArgs
            }
        }
    }
}
