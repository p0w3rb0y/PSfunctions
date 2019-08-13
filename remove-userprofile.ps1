Function Remove-UserProfile {
    <#
    .SYNOPSIS
    Removes users profiles on local computers

    .DESCRIPTION
    Removes users profiles on local computers based on two parameters:
    Days old and if they exist on the domain

    .PARAMETER Days
    Defaults to 180 days, you can specify any day

    .PARAMETER RemoveDomainUser
    Optional, if you use it, it will delete the users even if they exist in the domain.
    If you don't specify this parameter it will not delete users that exist in the domain.

    .EXAMPLE
    Remove-UserProfile -Days 30 -RemoveDomainUser
    Remove-UserProfile -RemoveDomainUser -WhatIf #This will only list the profiles to delete and perform a whatif

    .NOTES
    This was created to tidy up old and stale user profiles in windows servers that use up space. It can run on a schedule task
    #>


    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
    [Parameter()]
    [ValidateNotNullorEmpty()]
    [int]$Days=180,
    [Parameter()]
    [switch]$RemoveDomainUser
    )
    if ( (Get-WMIObject win32_operatingsystem).name -like '*2003*'){
        return}
    Write-Warning "Filtering for user profiles older than $Days days" 
    $sids = Get-CimInstance win32_userprofile | 
    Where {$_.LastUseTime -lt $(Get-Date).Date.AddDays(-$days) -and
         ($_.Special -ne $true) -and
         ($_.LocalPath -notlike '*Administrator*') -and
         ($_.LocalPath -notlike '*svc*') -and
         ($_.LocalPath -notlike '*god*') -and
         ($_.LocalPath -notlike '*net*') -and
         ($_.LocalPath -notlike '*sql*') -and
         ($_.Loaded -eq $False)
         }
    #Checks if the user exists in the domain and doesn't delete if it finds the user
        foreach ($obj in $sids) {
            if (!($RemoveDomainUser)) {
                #If you select the Removedomainuser parameter it will check if the user exists in AD using LDAP
                $ad = [ADSI]"LDAP://<SID=$($Obj.SID)>"
            }
            if ($ad.distinguishedName -and !($RemoveDomainUser)){
                #If the distinguished name is true and the removedomainuser has not been selected it outputs to screen and does not remove the user
                Write-Output "The following user exists in AD, is older than $days days and will NOT be removed because you didn't specify removal of AD users $($ad.distinguishedName)"
            }
            else{
                #Deletes user
                if ($PSCmdlet.ShouldProcess($obj.LocalPath, "Remove user profile")){
                    Write-Warning "deleting $($obj.LocalPath)"
                    Remove-CimInstance -InputObject $obj -Verbose
                }
            }    
        }
}
