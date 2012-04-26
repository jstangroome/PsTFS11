function Get-TFS11LabEnvironment {
    [CmdletBinding()]
    [OutputType([Microsoft.TeamFoundation.Lab.Client.LabEnvironment, Microsoft.TeamFoundation.Lab.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object[]]
        $Project,
        $Collection,
        [Microsoft.TeamFoundation.Lab.Client.LabEnvironmentDisposition, Microsoft.TeamFoundation.Lab.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a]
        $Disposition
    )

    process {
        
        if ($Collection -is [string] -or $Collection -is [Uri]) {
            $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
        }

        foreach ($SingleProject in $Project) {
            if ($SingleProject -is $MTF['Server.ProjectInfo']) {
                if ($SingleProject.Collection) { 
                    $Collection = $SingleProject.Collection
                }
                $SingleProject = $SingleProject.Name
            }

            $LabService = $Collection.GetService([Microsoft.TeamFoundation.Lab.Client.LabService])

            $Spec = New-Object -TypeName $MTF['Lab.Client.LabEnvironmentQuerySpec']
            $Spec.Project = $SingleProject
            if ($PSBoundParameters.ContainsKey('Disposition')) {
                $Spec.Disposition = $Disposition
            }

            Write-Verbose "Querying for lab environments in project '$($Spec.Project)'"
            Write-Output $LabService.QueryLabEnvironments($Spec)

        }
    }
}