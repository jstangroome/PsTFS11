function Get-TFS11TeamProject {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        $Collection,

        [Parameter(Position=1)]
        [Alias('Name')]
        [string]
        $ProjectName = '*',

        [switch]
        $All
    )

    process {
        if ($Collection -is [string] -or $Collection -is [Uri]) {
            $Collection = Get-TFS11TeamProjectCollection -CollectionUri $Collection
        }

        # TODO $StructureService = $Collection.GetService($MTF['Server.ICommonStructureService4'])
        $StructureService = $Collection.GetService($MTF['Server.ICommonStructureService3'])
        if ($All) {
            $Projects = $StructureService.ListAllProjects()
        } else {
            $Projects = $StructureService.ListProjects()
        }

        $Projects |
            Where-Object { $_.Name -like $ProjectName } |
            Add-Member -MemberType NoteProperty -Name Collection -Value $Collection -PassThru
    }
}