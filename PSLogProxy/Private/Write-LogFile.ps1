function Write-LogFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param(
        [ValidateSet("Verbose", "Warning", "Error", "Information", "Output", "Console", "Debug")]
        [String]$Type = "Verbose",
        [Parameter(Mandatory)]
        $Message
    )
    $FeatureName = $MyInvocation.MyCommand.Noun
    $FeatureSettings = ($PSLogProxyFeature | Where-Object Name -EQ $FeatureName).Settings
    Add-Content -Path $FeatureSettings.LogFile -Value $Message
}