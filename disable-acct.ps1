# Import Active Directory module
Import-Module ActiveDirectory

# Function to offboard user
function Offboard-Employee {
    param (
        [Parameter(Mandatory = $true)]
        [string]$username
    )

    try {
        # Disable AD account
        Disable-ADAccount -Identity $username -ErrorAction Stop
        Write-Output "AD account '$username' disabled successfully."

        # Reset user password
        Set-ADAccountPassword -Identity $username -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "NewPasswordHere" -Force) -ErrorAction Stop
        Write-Output "Password reset for '$username'."

        # Remove user from distribution groups
        Get-ADUser $username | Get-ADPrincipalGroupMembership | Where-Object { $_.GroupCategory -eq "Distribution" } | ForEach-Object {
            Remove-ADGroupMember -Identity $_.Name -Members $username -Confirm:$false -ErrorAction Stop
            Write-Output "Removed from group: $($_.Name)"
        }

        # Disable Exchange mailbox (if applicable)
        try {
            Disable-Mailbox -Identity $username -Confirm:$false -ErrorAction Stop
            Write-Output "Mailbox disabled for '$username'."
        } catch {
            Write-Warning "Failed to disable mailbox: $_"
        }

        # Additional cleanup or notifications can be added here

    } catch {
        Write-Error "Failed to offboard employee '$username': $_"
    }
}

# Prompt for username
$username = Read-Host "Enter username of the employee to offboard"

# Call function to offboard employee
Offboard-Employee -username $username
