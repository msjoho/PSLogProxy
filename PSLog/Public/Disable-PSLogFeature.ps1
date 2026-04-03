function Disable-PSLogFeature {
    <#
    .SYNOPSIS
        Disable PSLogFeatures
    .DESCRIPTION
        Disables PSLogFeatures, Pipeline supported
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Disable-PSLogFeature -WriteToFile
    .EXAMPLE
        Get-PSLogFeature -Name WriteToFile | Disable-PSLogFeature
    #>
    [CmdletBinding(DefaultParameterSetName = "Name")]
    param(
        [Parameter(ParameterSetName="Name",Position = 0)]
        [String]$Name,
        [Parameter(ParameterSetName="Pipeline", ValueFromPipeline)]
        [PSLogFeature]$LogFeatureObject
    )
    begin{}
    process{
        switch($PSCmdlet.ParameterSetName){
            "Pipeline" {
                $Feature = $LogFeatureObject
                $Name = $Feature.Name
            }
            "Name" { $Feature = $Script:PSLogFeature | Where-Object Name -eq $Name }
        }
        If($Feature){
            $Feature.Enabled = $false
        }else{
            Write-Warning "$Name Feature not found"
        }
    }
    end{}
}