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
    if ($PSLogProxySetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
    if ($PSLogProxySetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
    $FullStreamMessage += $Message
    $PSBoundParameters.Message = $FullStreamMessage -join $PSLogProxySetting.PrefixDelimiter

    # Run PSLogProxyFeature commands
    Foreach ($Feature in ($Script:PSLogProxyFeature | Where-Object Enabled -eq $true)) {
        # Add Feature Prefix
        $FeatureSettings = ($PSLogProxyFeature | Where-Object Name -EQ $Feature.Name).Settings
        if ($FeatureSettings.ExcludeMessageRegex.Count -gt 0 -and $Message -match ($FeatureSettings.ExcludeMessageRegex -join '|')) { continue }
        $FullFeatureMessage = @()
        if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
        if ($FeatureSettings.AddPrefixStream) { $FullFeatureMessage += $MyInvocation.MyCommand.Noun }
        if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
        $FullFeatureMessage += $Message
        $FeatureMessage = $FullFeatureMessage -join $PSLogProxySetting.PrefixDelimiter
        # Invoke Feature
        try {
            $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($Feature.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogProxyFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
            $SB = [ScriptBlock]::Create($ReplacedFeatureCommand)
            $SB.Invoke()
        }
        catch {
            # A logging feature must never throw out of a Write-* proxy: it would replace the
            # message (and error record) being logged with the feature's own failure. Seen in
            # production: a Seq outage and an unparsable message each surfaced as the job's
            # "error" while the real error was lost. Best effort note; the original stream
            # write below still runs.
            Microsoft.PowerShell.Utility\Write-Verbose "PSLogProxy feature '$($Feature.Name)' failed: $($_.Exception.Message)"
        }
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
