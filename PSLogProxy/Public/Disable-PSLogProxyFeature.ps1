function Disable-PSLogProxyFeature {
    <#
    .SYNOPSIS
        Disable PSLogProxyFeatures
    .DESCRIPTION
        Disables PSLogProxyFeatures, Pipeline supported
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogProxyFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Disable-PSLogProxyFeature -WriteToFile
    .EXAMPLE
        Get-PSLogProxyFeature -Name WriteToFile | Disable-PSLogProxyFeature
    #>
    [CmdletBinding(DefaultParameterSetName = "Name")]
    param(
        [Parameter(ParameterSetName="Name",Position = 0)]
        [String]$Name,
        [Parameter(ParameterSetName="Pipeline", ValueFromPipeline)]
        [PSLogProxyFeature]$LogFeatureObject
    )
    begin{}
    process{
        switch($PSCmdlet.ParameterSetName){
            "Pipeline" {
                $Feature = $LogFeatureObject
                $Name = $Feature.Name
            }
            "Name" { $Feature = $Script:PSLogProxyFeature | Where-Object Name -eq $Name }
        }
        If($Feature){
            $Feature.Enabled = $false
        }else{
            Write-Warning "$Name Feature not found"
        }
    }
    end{}
}