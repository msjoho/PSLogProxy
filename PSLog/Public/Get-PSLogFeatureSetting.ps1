function Get-PSLogFeatureSetting {
    <#
    .SYNOPSIS
        Displays all Settings of a specified LogFeature
    .DESCRIPTION
        Gets all Settings from one or several LogFeatures. Can be piped from a PSLogFeature Object
    .PARAMETER Name
        Name of the Setting
    .PARAMETER FeatureName
        Name of the PSLogFeature
    .PARAMETER PSLogFeatureObject
        Piped from a PSLogFeatureObject
    .EXAMPLE
        Get-PSLogFeature -Name "WriteToFile" | Get-PSLogFeatureSetting
    .EXAMPLE
        Get-PSLogFeatureSetting
    .EXAMPLE
        Get-PSLogFeatureSetting -FeatureName "WriteToFile"
    #>
    [CmdletBinding(DefaultParameterSetName = "FeatureName")]
    param(
        [Parameter(ParameterSetName="FeatureName", Mandatory, Position = 0)]
        [String]$FeatureName,
        [Parameter(ParameterSetName="Pipeline", Mandatory, ValueFromPipeline = $true)]
        [PSLogFeature]$PSLogFeatureObject
    )
    Begin{}
    Process{
        # Filter Feature
        $PSLogFeatureObject = Switch ($PSCmdlet.ParameterSetName){
            "FeatureName" {$PSLogFeature | Where-Object Name -like $FeatureName}
            "Pipeline" {$PSLogFeatureObject}
            # Default {$PSLogFeature}
        }
        $Result = $PSLogFeatureObject.Settings
    }
    End{
        return $Result
    }
}