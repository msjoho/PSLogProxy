# try to test on AA to use Function instead of Cmdlet in proxy function
# --> will be suspended after timeout ???

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

    begin {
        # Add Stream Prefix
        $FullStreamMessage = @()
        if ($PSLogProxySetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
        if ($PSLogProxySetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
        $FullStreamMessage += $InputObject
        $PSBoundParameters.InputObject = $FullStreamMessage -join $PSLogProxySetting.PrefixDelimiter

        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Output', [System.Management.Automation.CommandTypes]::Function)
            $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }

    process {
        # Run PSLogProxyFeature commands
        $Script:PSLogProxyFeature | Where-Object Enabled -EQ $true | ForEach-Object {
            # Add Feature Prefix
            $FeatureSettings = ($PSLogProxyFeature | Where-Object Name -EQ $_.Name).Settings
            $FullFeatureMessage = @()
            if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
            if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
            $FullFeatureMessage += $InputObject
            $FeatureMessage = $FullFeatureMessage -join $PSLogProxySetting.PrefixDelimiter
            # Invoke Feature
            try {
                $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($_.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogProxyFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
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
    <#

        .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Output
        .ForwardHelpCategory Cmdlet

    #>
}
