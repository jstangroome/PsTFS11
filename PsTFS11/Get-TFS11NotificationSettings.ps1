function Get-TFS11NotificationSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('Server')]
        $ConfigurationServer
    )

    process {

        if ($ConfigurationServer -is [string] -or $ConfigurationServer -is [Uri]) {
            $ConfigurationServer = Get-TFS11ConfigurationServer -Uri $ConfigurationServer
        }
        if ($ConfigurationServer -isnot $MTF['Client.TfsConfigurationServer']) {
            throw 'Invalid configuration server.'
        }

        $RegistryService = $ConfigurationServer.GetService($MTF['Framework.Client.ITeamFoundationRegistry'])
        $Entries = $RegistryService.ReadEntries('/Service/Integration/Settings/*')
        Write-Debug "Entries.Count = $($Entries.Count)"

        if ($Entries.Count -eq 0) {
            Write-Error 'Could not access notification settings.'
            return
        }

        New-Object -TypeName PSObject -Property @{
            ConfigurationServer = $ConfigurationServer
            EmailEnabled = $Entries['EmailEnabled'].GetValue([bool]$false)
            EmailNotificationFromAddress = $Entries['EmailNotificationFromAddress'].Value
            SmtpServer = $Entries['SmtpServer'].Value
            SmtpPort = $Entries['SmtpPort'].GetValue([int]25)
            SmtpUser = $Entries['SmtpUser'].Value
            SmtpPassword = $Entries['SmtpPassword'].Value
            SmtpCertThumbprint = $Entries['SmtpCertThumbprint'].Value
            SmtpEnableSsl = $Entries['SmtpEnableSsl'].GetValue([bool]$false)
        }

    }

}
