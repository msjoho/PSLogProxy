function Enable-PSLogFeature {
    <#
    .SYNOPSIS
        Enable PSLogFeatures
    .DESCRIPTION
        Enables PSLogFeatures, Pipeline supported
    .PARAMETER LogFeature
        LogFeature Object from Pipeline (Get-PSLogFeature)
    .PARAMETER Name
        Name of the LogFeature
    .EXAMPLE
        Enable-PSLogFeature -Name WriteToFile
    .EXAMPLE
        Get-PSLogFeature -Name WriteToFile | Enable-PSLogFeature
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
            $Feature.Enabled = $true
        }else{
            Write-Warning "$Name Feature not found"
        }
    }
    end{}
}
