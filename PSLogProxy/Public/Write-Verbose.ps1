function Write-Verbose {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidOverwritingBuiltInCmdlets", "")]
    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2097043', RemotingCapability = 'None')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [string]
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
            if ($PSLogProxySetting.AddStreamPrefixDateTimeString) { $FullStreamMessage += $Script:PSLogProxySetting.DateTimeStringScriptblock.Invoke() }
            if ($PSLogProxySetting.AddStreamPrefixInvocationScript) {
                if ($ThisScriptName) {
                    $FullStreamMessage += $ThisScriptName
                }
                elseif ($MyInvocation.ScriptName) {
                    $FullStreamMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", ""
                }
            }
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
                if ($FeatureSettings.AddPrefixInvocationScript) {
                    if ($ThisScriptName) {
                        $FullFeatureMessage += $ThisScriptName
                    }
                    elseif ($MyInvocation.ScriptName) {
                        $FullFeatureMessage += (Split-Path $MyInvocation.ScriptName -Leaf) -Replace "\.ps.{0,1}1", ""
                    }
                }
                $FullFeatureMessage += $Message
                $FeatureMessage = $FullFeatureMessage -join $PSLogProxySetting.PrefixDelimiter
                # Invoke Feature
                $ReplacedFeatureCommand = $ReplaceFeatureCommand.Invoke($Feature.CommandString, $MyInvocation.MyCommand.Noun, $FeatureMessage) #where args[0] = PSLogProxyFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage
                $SB = [ScriptBlock]::Create($ReplacedFeatureCommand)
                $SB.Invoke()
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Write-Verbose', [System.Management.Automation.CommandTypes]::Cmdlet)
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

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Write-Verbose
    .ForwardHelpCategory Cmdlet

    #>
}