function Get-TFS11BuildProcessParameters {
    [CmdletBinding(DefaultParameterSetName='ProcessParameters')]
    param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='ProcessParameters')]
        [string]
        $ProcessParameters,

        [Parameter(Mandatory=$true, ParameterSetName='BuildDefinition')]
        [Microsoft.TeamFoundation.Build.Client.IBuildDefinition, Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $BuildDefinition
    )

    begin {
        if ($PSVersionTable.CLRVersion.Major -lt 4) {
            throw ".NET 4 is required for this feature"
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'BuildDefinition') {
            $ProcessParameters = $BuildDefinition.ProcessParameters
        }
        $MTF['Build.Workflow.WorkflowHelpers']::DeserializeProcessParameters($ProcessParameters)
    }

}
