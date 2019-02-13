function Protect-Adobject {
    [CmdletBinding()]
    param (
        # Name of the AD objects to protect Ex: objectname*
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, HelpMessage = "Please specify object names to protect, can use wildcards")]
        [string]
        $adobjects
    )
        Get-ADObject -Filter {name -like $adobjects} | Set-ADObject -ProtectedFromAccidentalDeletion:$true -Verbose
}
