function Set-PSLogProxyFeatureSetting {
    <#
    .SYNOPSIS
        Sets a LogFeature Setting
    .DESCRIPTION
        Sets a Setting of a specified LogFeature
    .PARAMETER Name
        Name of the Setting
    .PARAMETER Value
        Value to be set
    .PARAMETER FeatureName
        Name of the PSLogProxyFeature
    .PARAMETER PSLogProxyFeatureObject
        Piped from a PSLogProxyFeatureObject
    .EXAMPLE
        Set-PSLogProxyFeatureSetting -FeatureName "WriteToFile" -Name "LogFile" -Value "C:\temp\PSLogProxy.log"
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding(DefaultParameterSetName = "FeatureName")]
    param(
        [Parameter(Mandatory)]
        [String]$Name,
        [Parameter(Mandatory)]
        $Value,
        [Parameter(ParameterSetName = "FeatureName", Mandatory)]
        [String]$FeatureName ,
        [Parameter(ParameterSetName = "Pipeline", Mandatory, ValueFromPipeline = $true)]
        [PSLogProxyFeature]$PSLogProxyFeatureObject
    )
    process {
        # Filter Feature
        $PSLogProxyFeatureObjectSettings = Switch ($PSCmdlet.ParameterSetName) {
            "FeatureName" { ($Script:PSLogProxyFeature | Where-Object Name -EQ $FeatureName).Settings }
            "Pipeline" { $PSLogProxyFeatureObject.Settings }
        }
        $PSLogProxyFeatureObjectSettings.$Name = $Value
    }
}