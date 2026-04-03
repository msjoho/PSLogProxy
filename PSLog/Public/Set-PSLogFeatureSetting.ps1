function Set-PSLogFeatureSetting {
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
        Name of the PSLogFeature
    .PARAMETER PSLogFeatureObject
        Piped from a PSLogFeatureObject
    .EXAMPLE
        Set-PSLogFeatureSetting -FeatureName "WriteToFile" -Name "LogFile" -Value "C:\temp\PSLog.log"
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
        [PSLogFeature]$PSLogFeatureObject
    )
    process {
        # Filter Feature
        $PSLogFeatureObjectSettings = Switch ($PSCmdlet.ParameterSetName) {
            "FeatureName" { ($Script:PSLogFeature | Where-Object Name -EQ $FeatureName).Settings }
            "Pipeline" { $PSLogFeatureObject.Settings }
        }
        $PSLogFeatureObjectSettings.$Name = $Value
    }
}