function Get-PSLogProxyFeatureSetting {
    <#
    .SYNOPSIS
        Displays all Settings of a specified LogFeature
    .DESCRIPTION
        Gets all Settings from one or several LogFeatures. Can be piped from a PSLogProxyFeature Object
    .PARAMETER Name
        Name of the Setting
    .PARAMETER FeatureName
        Name of the PSLogProxyFeature
    .PARAMETER PSLogProxyFeatureObject
        Piped from a PSLogProxyFeatureObject
    .EXAMPLE
        Get-PSLogProxyFeature -Name "WriteToFile" | Get-PSLogProxyFeatureSetting
    .EXAMPLE
        Get-PSLogProxyFeatureSetting
    .EXAMPLE
        Get-PSLogProxyFeatureSetting -FeatureName "WriteToFile"
    #>
    [CmdletBinding(DefaultParameterSetName = "FeatureName")]
    param(
        [Parameter(ParameterSetName="FeatureName", Mandatory, Position = 0)]
        [String]$FeatureName,
        [Parameter(ParameterSetName="Pipeline", Mandatory, ValueFromPipeline = $true)]
        [PSLogProxyFeature]$PSLogProxyFeatureObject
    )
    Begin{}
    Process{
        # Filter Feature
        $PSLogProxyFeatureObject = Switch ($PSCmdlet.ParameterSetName){
            "FeatureName" {$PSLogProxyFeature | Where-Object Name -like $FeatureName}
            "Pipeline" {$PSLogProxyFeatureObject}
            # Default {$PSLogProxyFeature}
        }
        $Result = $PSLogProxyFeatureObject.Settings
    }
    End{
        return $Result
    }
}