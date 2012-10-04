function Get-TFS11ServiceLocation {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Collection', 'Server','ConfigurationServer')]
        $Connection,

        [Parameter(Mandatory=$true, ParameterSetName='Type')]
        [Alias('Type')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServiceType,
        
        [Parameter(Mandatory=$true, ParameterSetName='Definition')]
        [Alias('Definition')]
        [Microsoft.TeamFoundation.Framework.Client.ServiceDefinition[], Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $ServiceDefinition
    )

    if ($Connection -is [string] -or $Connection -is [uri]) {
        $Connection = Get-TFS11TeamProjectCollection -CollectionUri $Connection
        # what about configuration server uris?
    }

    if ($Connection -isnot $MTF['Client.TfsConnection']) {
        throw "Invalid Connection"
    }

    $LocationService = $Connection.GetService($MTF['Framework.Client.ILocationService'])

    if ($PSCmdlet.ParameterSetName -eq 'Type') { 
        $ServiceDefinition = $LocationService.FindServiceDefinitions($ServiceType)
    }

    foreach ($SingleServiceDefinition in $ServiceDefinition) {
        $LocationService.LocationForCurrentConnection($SingleServiceDefinition)
    }

}
