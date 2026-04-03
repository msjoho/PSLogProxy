function Get-PSLogFeature {
    <#
    .SYNOPSIS
        Displays all LogFeatures
    .DESCRIPTION
        Gets all LogFeatures. Used to pipe with Enable- or Disable-PSLogFeature
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Get-PSLogFeature -Name WriteToFile
    #>
    param(
        [String]$Name
    )
    If($Name){
        $PSLogFeature | Where-Object Name -eq $Name
    }
    else {
        $PSLogFeature
    }
}