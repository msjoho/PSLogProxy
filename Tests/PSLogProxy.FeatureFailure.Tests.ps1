BeforeAll {
    if(-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))){ $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module .\PSLogProxy -Force
    Set-PSLogProxySetting -Name AddStreamPrefixDateTimeString -Value $false
    Set-PSLogProxySetting -Name AddStreamPrefixInvocationScript -Value $false
    Get-PSLogProxyFeature | Disable-PSLogProxyFeature
    # Register a feature whose command always throws - a broken/unreachable feature must never
    # replace the message being logged (regression: Seq outage / unparsable message masked the
    # job's real error).
    & (Get-Module PSLogProxy) {
        $Script:PSLogProxyFeature += [PSLogProxyFeature]@{
            Name          = 'PesterBoom'
            Enabled       = $true
            CommandString = 'throw "feature boom"'
            Settings      = @{ AddPrefixDateTimeString = $false; AddPrefixStream = $false; AddPrefixInvocationScript = $false }
        }
    }
}

AfterAll {
    & (Get-Module PSLogProxy) {
        $Script:PSLogProxyFeature = @($Script:PSLogProxyFeature | Where-Object Name -ne 'PesterBoom')
    }
    Set-PSLogProxySetting -Name AddStreamPrefixInvocationScript -Value $true
}

Describe 'Feature failure isolation' {
    It 'Write-Verbose still writes its message when a feature throws' {
        # The guard writes its own diagnostic verbose note before the message - the MESSAGE is
        # the last verbose record.
        $Output = @((Write-Verbose 'FeatureBoomVerbose' -Verbose) 4>&1)
        $Output[-1].ToString() | Should -Be 'FeatureBoomVerbose'
        ($Output | Where-Object { "$_" -like "*PesterBoom*failed*" }) | Should -Not -BeNullOrEmpty
    }

    It 'Write-Warning still writes its message when a feature throws' {
        $Output = (Write-Warning 'FeatureBoomWarning' 3>&1)
        $Output.ToString() | Should -Be 'FeatureBoomWarning'
    }

    It 'Write-Error still writes the error record when a feature throws' {
        $Output = (Write-Error 'FeatureBoomError' 2>&1)
        $Output | Should -Not -BeNullOrEmpty
        $Output.Exception.Message | Should -Be 'FeatureBoomError'
    }

    It 'Write-Output still emits the object when a feature throws' {
        Write-Output 'FeatureBoomOutput' | Should -Be 'FeatureBoomOutput'
    }
}
