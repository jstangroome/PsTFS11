function Get-TFS11ConfigurationServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $Uri
    )

    process {
        return $MTF['Client.TfsConfigurationServerFactory']::GetConfigurationServer($Uri)
    }

}
