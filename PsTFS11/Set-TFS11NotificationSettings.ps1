function Set-TFS11NotificationSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('Server')]
        $ConfigurationServer,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('EmailEnabled')]
        [bool]
        $EnableEmail,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('FromAddress')]
        [string]
        $EmailNotificationFromAddress,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        $SmtpServer,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('Port')]
        [UInt16]
        $SmtpPort,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('User')]
        [string]
        $SmtpUser,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        [Alias('Password')]
        $SmtpPassword, # TODO support SecureString and/or PSCredential

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('Thumbprint')]
        [string]
        $SmtpCertThumbprint,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias('SmtpEnableSsl')]
        [bool]
        $EnableSSL
    )

    process {
        if ($ConfigurationServer -is [string] -or $ConfigurationServer -is [Uri]) {
            $ConfigurationServer = Get-TFS11ConfigurationServer -Uri $ConfigurationServer
        }
        if ($ConfigurationServer -isnot $MTF['Client.TfsConfigurationServer']) {
            throw 'Invalid configuration server.'
        }

        $RegistryService = $ConfigurationServer.GetService($MTF['Framework.Client.ITeamFoundationRegistry'])
        $Prefix = "/Service/Integration/Settings"

        $HasSetValue = $false
        if ($PSBoundParameters.ContainsKey('EnableEmail')) {
            $RegistryService.SetValue("$prefix/EmailEnabled", $EnableEmail)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('EmailNotificationFromAddress')) {
            if ($EmailNotificationFromAddress -and $EmailNotificationFromAddress -notmatch'.@[A-Z0-9]') {
                throw 'EmailNotificationFromAddress is not a valid email address format.'
            }
            $RegistryService.SetValue("$prefix/EmailNotificationFromAddress", $EmailNotificationFromAddress)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('SmtpServer')) {
            $RegistryService.SetValue("$prefix/SmtpServer", $SmtpServer)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('SmtpPort')) {
            $RegistryService.SetValue("$prefix/SmtpPort", $SmtpPort)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('SmtpUser')) {
            $RegistryService.SetValue("$prefix/SmtpUser", $SmtpUser)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('SmtpPassword')) {
            $RegistryService.SetValue("$prefix/SmtpPassword", $SmtpPassword)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('SmtpCertThumbprint')) {
            $RegistryService.SetValue("$prefix/SmtpCertThumbprint", $SmtpCertThumbprint)
            $HasSetValue = $true
        }
        if ($PSBoundParameters.ContainsKey('EnableSsl')) {
            $RegistryService.SetValue("$prefix/SmtpEnableSsl", $EnableSsl)
            $HasSetValue = $true
        }

        if ($HasSetValue) {
            Write-Verbose 'Notification settings applied.'

            Get-TFS11NotificationSettings -ConfigurationServer $ConfigurationServer

        } else {
            Write-Warning 'No settings were specified.'
        }
    }
}
