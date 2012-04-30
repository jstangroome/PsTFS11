Set-StrictMode -Version Latest
$script:ErrorActionPreference = 'Stop'

if ($PSVersionTable.CLRVersion.Major -ge 4) {
    Add-Type -AssemblyName 'Microsoft.TeamFoundation.Build.Workflow, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
}

# create an index of public Microsoft.TeamFoundation.* types from the version 11 API only
# so this module can be side-by-side loaded with the TFS 2010 API.
$script:MTF = @{}
[AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.FullName -like 'Microsoft.TeamFoundation*, Version=11.*' } |
    ForEach-Object { 
        try {
            $_.GetTypes() |
                Where-Object { $_.IsPublic } |
                ForEach-Object {
                    $Key = $_.FullName -replace '^Microsoft\.TeamFoundation\.', ''
                    $script:MTF.Add($Key, $_)
                }
        } catch [System.Reflection.ReflectionTypeLoadException] {
            Write-Debug -Message ($_.Exception.LoaderExceptions | Format-List -Property * -Force | Out-String)
        }
    }

Add-Type -Path $PSScriptRoot\BuildPermissions.cs

. $PSScriptRoot\Get-TFS11ConfigurationServer.ps1
. $PSScriptRoot\Get-TFS11TeamProjectCollection.ps1
. $PSScriptRoot\Get-TFS11TeamProject.ps1
. $PSScriptRoot\Get-TFS11Identity.ps1
. $PSScriptRoot\Get-TFS11BuildPermission.ps1
. $PSScriptRoot\Set-TFS11BuildPermission.ps1

. $PSScriptRoot\Get-TFS11LabEnvironment.ps1

. $PSScriptRoot\Get-TFS11BuildDefinition.ps1

. $PSScriptRoot\Get-TFS11BuildProcessParameters.ps1