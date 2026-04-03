function Get-PSLogProxyFeature {
    <#
    .SYNOPSIS
        Displays all LogFeatures
    .DESCRIPTION
        Gets all LogFeatures. Used to pipe with Enable- or Disable-PSLogProxyFeature
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogProxyFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Get-PSLogProxyFeature -Name WriteToFile
    #>
    param(
        [String]$Name
    )
    If($Name){
        $PSLogProxyFeature | Where-Object Name -eq $Name
    }
    else {
        $PSLogProxyFeature
    }
}