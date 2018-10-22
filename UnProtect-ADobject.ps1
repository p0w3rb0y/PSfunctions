function Unprotect-Adobject {
    [CmdletBinding()]
    param (
        # Name of the AD objects to un-protect Ex: objectname*
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, HelpMessage = "Please specify object names to protect, can use wildcards")]
        [string]
        $adobjects