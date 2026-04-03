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
        if ($PSLogSetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogSetting.DateTimeStringScriptblock.Invoke() }
        if ($PSLogSetting.AddStreamPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
        $FullStreamMessage += $InputObject
        $PSBoundParameters.InputObject = $FullStreamMessage -join $PSLogSetting.PrefixDelimiter

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
        # Run PSLogFeature commands
        $Script:PSLogFeature | Where-Object Enabled -EQ $true | ForEach-Object {
            # Add Feature Prefix
            $FeatureSettings = ($PSLogFeature | Where-Object Name -EQ $_.Name).Settings
            $FullFeatureMessage = @()
            if ($FeatureSettings.AddPrefixDateTimeString) { $FullFeatureMessage += $Script:PSLogSetting.DateTimeStringScriptblock.Invoke() }
            if ($FeatureSettings.AddPrefixInvocationScript) { if ($MyInvocation.ScriptName) { $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", "" } }
            $FullFeatureMessage += $InputObject
            $FeatureMessage = $FullFeatureMessage -join $PSLogSetting.PrefixDelimiter
            # Invoke Feature
            $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($_.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
            $SB = [ScriptBlock]::Create($ReplacedFeatureCommand)
            $SB.Invoke()
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
