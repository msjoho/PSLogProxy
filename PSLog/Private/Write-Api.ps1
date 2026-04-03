function Write-Api {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")] # will be used in BodyScriptBlock
    param(
        [ValidateSet("Verbose", "Warning", "Error", "Information", "Output", "Console", "Debug")]
        [String]$Type = "Verbose",
        [Parameter(Mandatory)]
        $Message
    )
    $FeatureName = $MyInvocation.MyCommand.Noun
    $FeatureSettings = ($PSLogFeature | Where-Object Name -eq $FeatureName).Settings

    $Body = ([ScriptBlock]::Create($FeatureSettings.BodyScriptBlock)).InvokeReturnAsIs()
    $null = Invoke-RestMethod -Uri $FeatureSettings.Uri -Method $FeatureSettings.Method -Body $Body -Verbose:$False
}
