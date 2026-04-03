function Enable-PSLogProxyFeature {
    <#
    .SYNOPSIS
        Enable PSLogProxyFeatures
    .DESCRIPTION
        Enables PSLogProxyFeatures, Pipeline supported
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogProxyFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Enable-PSLogProxyFeature -Name WriteToFile
    .EXAMPLE
        Get-PSLogProxyFeature -Name WriteToFile | Enable-PSLogProxyFeature
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
            $Feature.Enabled = $true
        }else{
            Write-Warning "$Name Feature not found"
        }
    }
    end{}
}
