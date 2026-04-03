# Proxy function that wraps the original command
function Write-Error {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    # Additional functionality before calling the original command

    # ...
    # Add Stream Prefix
    $FullStreamMessage = @()
    if ($PSLogSetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogSetting.DateTimeStringScriptblock.Invoke() }
    if ($PSLogSetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
    $FullStreamMessage += $Message
    $PSBoundParameters.Message = $FullStreamMessage -join $PSLogSetting.PrefixDelimiter

    # Run PSLogFeature commands
    Foreach ($Feature in ($Script:PSLogFeature | Where-Object Enabled -eq $true)) {
        # Add Feature Prefix
        $FeatureSettings = ($PSLogFeature | Where-Object Name -EQ $Feature.Name).Settings
        if ($FeatureSettings.ExcludeMessageRegex.Count -gt 0 -and $Message -match ($FeatureSettings.ExcludeMessageRegex -join '|')) { continue }
        $FullFeatureMessage = @()
        if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogSetting.DateTimeStringScriptblock.Invoke() }
        if ($FeatureSettings.AddPrefixStream) { $FullFeatureMessage += $MyInvocation.MyCommand.Noun }
        if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
        $FullFeatureMessage += $Message
        $FeatureMessage = $FullFeatureMessage -join $PSLogSetting.PrefixDelimiter
        # Invoke Feature
        $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($Feature.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
        $SB = [ScriptBlock]::Create($ReplacedFeatureCommand)
        $SB.Invoke()
    }

    # Call the original command with modified parameters if needed
    # Write-InternError -Message $Message
    # Original command code
    $PSCmdlet.WriteError((New-Object System.Management.Automation.ErrorRecord(
        ([System.Exception]::new($Message)),
                'CustomErrorID',
                'WriteError',
                $null
            )))

    # Additional functionality after calling the original command
    # ...
}
