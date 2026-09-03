function Write-Information {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "")]
    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=2097040', RemotingCapability = 'None')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Alias('Msg', 'Message')]
        [AllowNull()]
        [System.Object]
        ${MessageData},

        [Parameter(Position = 1)]
        [string[]]
        ${Tags})

    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            # Add Stream Prefix
            $FullStreamMessage = @()
            if ($PSLogProxySetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
            if ($PSLogProxySetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
            $FullStreamMessage += $MessageData
            $PSBoundParameters.MessageData = $FullStreamMessage -join $PSLogProxySetting.PrefixDelimiter

            # Run PSLogProxyFeature commands
            Foreach ($Feature in ($Script:PSLogProxyFeature | Where-Object Enabled -eq $true)) {
                # Add Feature Prefix
                $FeatureSettings = ($PSLogProxyFeature | Where-Object Name -EQ $Feature.Name).Settings
                if ($FeatureSettings.ExcludeMessageRegex.Count -gt 0 -and $MessageData -match ($FeatureSettings.ExcludeMessageRegex -join '|')) { continue }
                $FullFeatureMessage = @()
                if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
                if ($FeatureSettings.AddPrefixStream) { $FullFeatureMessage += $MyInvocation.MyCommand.Noun }
                if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
                $FullFeatureMessage += $MessageData
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

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Information', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }

    # clean # does not work with PS 5.1
    # {
    #     if ($null -ne $steppablePipeline) {
    #         $steppablePipeline.Clean()
    #     }
    # }
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Information
    .ForwardHelpCategory Cmdlet

    #>
}