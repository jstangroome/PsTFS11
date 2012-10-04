function Add-Tfs11BackwardCompatibilityAlias {
    Get-Command -Module $MyInvocation.MyCommand.ModuleName -CommandType Function |
        Where-Object { $_.Noun -match '^TFS11' } |
        ForEach-Object { 
            $NewName = '{0}-{1}' -f $_.Verb, ($_.Noun -replace '^TFS11','TFS')
            New-Alias -Name $NewName -Value $_.Name -Scope Global
        }
}