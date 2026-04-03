Function Write-Output {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "")]
    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113427',
        RemotingCapability = 'None'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromRemainingArguments = $true
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [psobject]
        ${InputObject},

        [switch]
        ${NoEnumerate})

    process {
        # Add Stream Prefix
        $FullStreamMessage = @()
        if ($PSLogProxySetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
        if ($PSLogProxySetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
        $FullStreamMessage += $InputObject
        $FormattedOutput = $FullStreamMessage -join $PSLogProxySetting.PrefixDelimiter

        # Run PSLogProxyFeature commands
        Foreach ($Feature in ($Script:PSLogProxyFeature | Where-Object Enabled -eq $true)) {
            # Add Feature Prefix
            $FeatureSettings = ($PSLogProxyFeature | Where-Object Name -EQ $Feature.Name).Settings
            if ($FeatureSettings.ExcludeMessageRegex.Count -gt 0 -and $InputObject -match ($FeatureSettings.ExcludeMessageRegex -join '|')) { continue }
            $FullFeatureMessage = @()
            if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
            if ($FeatureSettings.AddPrefixStream) { $FullFeatureMessage += $MyInvocation.MyCommand.Noun }
            if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
            $FullFeatureMessage += $InputObject
            $FeatureMessage = $FullFeatureMessage -join $PSLogProxySetting.PrefixDelimiter
            # Invoke Feature
            $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($Feature.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogProxyFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
            $SB = [ScriptBlock]::Create($ReplacedFeatureCommand)
            $SB.Invoke()
        }

        $PSCmdlet.WriteObject($FormattedOutput, -not $NoEnumerate.IsPresent)
    }
    <#

        .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Output
        .ForwardHelpCategory Cmdlet

    #>
}