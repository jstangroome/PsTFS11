function Add-TFS11GroupMember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Connection,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Group,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $Member
    )

    if ($Connection -is [string] -or $Connection -is [uri]) {
        $Connection = Get-TFS11TeamProjectCollection -CollectionUri $Connection
        # what about configuration server uris?
    }

    if ($Connection -isnot $MTF['Client.TfsConnection']) {
        throw "Invalid Connection"
    }

    if ($Group -is [string]) {
        $GroupName = $Identity
        $Group = Get-TFS11Identity -Connection $Connection -Name $GroupName -SearchFactor DisplayName -Options IncludeReadFromSource |
            Select-Object -First 1
        if (-not $Group) {
            Write-Error "Could not resolve group '$GroupName'"
            return
        }
    }
    if ($Group -is $MTF['Framework.Client.TeamFoundationIdentity']) {
        $Group = $Group.Descriptor
    }
    if (-not $Group -or $Group -isnot $MTF['Framework.Client.IdentityDescriptor']) {
        throw "Invalid group."
    }

    if ($Member -is [string]) {
        $MemberName = $Identity
        $Member = Get-TFS11Identity -Connection $Connection -Name $MemberName -SearchFactor AccountName -Options IncludeReadFromSource |
            Select-Object -First 1
        if (-not $Member) {
            Write-Error "Could not resolve member '$MemberName'"
            return
        }
    }
    if ($Member -is $MTF['Framework.Client.TeamFoundationIdentity']) {
        $Member = $Member.Descriptor
    }
    if (-not $Member -or $Member -isnot $MTF['Framework.Client.IdentityDescriptor']) {
        throw "Invalid member."
    }

    $IdentityManagementService = $Connection.GetService($MTF['Framework.Client.IIdentityManagementService'])

    try {
        $IdentityManagementService.AddMemberToApplicationGroup($Group, $Member)
    } catch [Microsoft.TeamFoundation.Framework.Client.AddMemberIdentityAlreadyMemberException, Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a] {
        Write-Verbose "Identity '$($Member.Identifier)' already a member of Group '$($Group.Identifier)'."
    }
}
