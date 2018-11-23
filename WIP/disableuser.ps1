function reset-password {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$username
    )

    BEGIN {}
    PROCESS {
        $Password = [system.web.security.membership]::GeneratePassword(128, 30)
        $Password
        Set-ADAccountPassword $username -NewPassword $Password -Reset -PassThru | lock-ADAccount
    }
    END {}
}
function remove-groupmember {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$username
    )

    BEGIN {}
    PROCESS {
        (Get-ADUser $username -Properties memberof).memberof | % {Remove-ADGroupMember -Identity $_ -Members $username -Confirm:$false}
    }
    END {}
}

Read-Host -Prompt "User Samaccount:" $user
$user
remove-groupmember $user
reset-password $user
