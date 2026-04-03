Function Write-Debug {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "")]
    [CmdletBinding(
        HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113427',
        RemotingCapability = 'None'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [AllowNull()]
        [String]
        ${Message}
    )

    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            # Add Stream Prefix
            $FullStreamMessage = @()
            if ($PSLogSetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogSetting.DateTimeStringScriptblock.Invoke() }
            if ($PSLogSetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
            $FullStreamMessage += $Message
            $PSBoundParameters.Message = $FullStreamMessage -join $PSLogSetting.PrefixDelimiter

            # Run PSLogFeature commands
            Foreach ($Feature in ($Script:PSLogFeature | Where-Object Enabled -eq $true)) {
                # Add Feature Prefix
                $FeatureSettings = ($PSLogFeature | Where-Object Name -eq $Feature.Name).Settings
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

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                'Microsoft.PowerShell.Utility\Write-Debug',
                [System.Management.Automation.CommandTypes]::Cmdlet
            )
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
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Debug
    .ForwardHelpCategory Cmdlet

    #>
}