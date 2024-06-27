# Offboard-Employee Script

## Overview

This PowerShell script automates the offboarding process for employees by performing several key tasks in Active Directory (AD). It disables the user's AD account, resets their password, removes them from distribution groups, and disables their Exchange mailbox (if applicable).

## Prerequisites

- PowerShell must be running with administrative privileges.
- The Active Directory module must be installed.
- Exchange Online module should be available if you want to disable Exchange mailboxes.

## Usage

1. **Import the Active Directory module:**
   The script begins by importing the Active Directory module to enable the necessary cmdlets.

   ```powershell
   Import-Module ActiveDirectory
   ```

2. **Function to offboard the employee:**
   The script defines a function `Offboard-Employee` that takes a username as a parameter and performs the following actions:
   - Disables the AD account.
   - Resets the user's password.
   - Removes the user from all distribution groups.
   - Attempts to disable the user's Exchange mailbox.

   ```powershell
   function Offboard-Employee {
       param (
           [Parameter(Mandatory = $true)]
           [string]$username
       )

       try {
           Disable-ADAccount -Identity $username -ErrorAction Stop
           Write-Output "AD account '$username' disabled successfully."

           Set-ADAccountPassword -Identity $username -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "NewPasswordHere" -Force) -ErrorAction Stop
           Write-Output "Password reset for '$username'."

           Get-ADUser $username | Get-ADPrincipalGroupMembership | Where-Object { $_.GroupCategory -eq "Distribution" } | ForEach-Object {
               Remove-ADGroupMember -Identity $_.Name -Members $username -Confirm:$false -ErrorAction Stop
               Write-Output "Removed from group: $($_.Name)"
           }

           try {
               Disable-Mailbox -Identity $username -Confirm:$false -ErrorAction Stop
               Write-Output "Mailbox disabled for '$username'."
           } catch {
               Write-Warning "Failed to disable mailbox: $_"
           }

       } catch {
           Write-Error "Failed to offboard employee '$username': $_"
       }
   }
   ```

3. **Prompt for the username:**
   The script prompts the user to enter the username of the employee to be offboarded.

   ```powershell
   $username = Read-Host "Enter username of the employee to offboard"
   ```

4. **Call the offboarding function:**
   The script then calls the `Offboard-Employee` function with the provided username.

   ```powershell
   Offboard-Employee -username $username
   ```

## Example Run

To run the script, simply execute it in a PowerShell session. You will be prompted to enter the username of the employee you wish to offboard.

```powershell
Enter username of the employee to offboard: johndoe
```

The script will then proceed to disable the AD account, reset the password, remove the user from distribution groups, and disable the Exchange mailbox (if applicable).

## Notes

- Make sure to replace `"NewPasswordHere"` with a secure password or implement a more secure password generation mechanism.
- The script includes error handling to provide feedback if any step fails.
- Additional cleanup tasks or notifications can be added to the script as needed.


