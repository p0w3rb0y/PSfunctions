<#
.Synopsis
   Changes DNS server settings on windows computers
.DESCRIPTION
   Changes DNS server settings on windows computers
.EXAMPLE
   Set-DNSClientsettings -Computers 'server@contoso.com' -DNS1 '10.80.10.81' -DNS2 '10.80.10.80'
#>
function Set-DNSClientSettings
{
    [CmdletBinding()]
    Param
    (
        # Fqdn of computers to change the settings
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Computers,

        # Primary DNS server
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $DNS1,
        # Secondary DNS server
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $DNS2
    )
    foreach ( $computer in $computers){
    New-PSSession -ComputerName $computer
    write-host "setting DNS Records to... $dns1, $dns2"
    Invoke-Command -ComputerName $computer -Scriptblock {(Get-WMIObject win32_NetworkAdapterConfiguration | Where-Object { $_.defaultipgateway}).setDNSServerSearchOrder(@($using:dns1,$using:dns2))}
    write-host "DNS set on $computer :"
    Invoke-Command -ComputerName $computer -Scriptblock {(Get-WMIObject win32_NetworkAdapterConfiguration | Where-Object { $_.defaultipgateway}).DNSServerSearchOrder}
    remove-PSSession -ComputerName $computer
    }
}
