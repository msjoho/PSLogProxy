BeforeAll {
    if (-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))) { $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module .\PSLogProxy -Force
    Get-PSLogProxyFeature | Disable-PSLogProxyFeature
}

Describe 'PSLogProxy Management Cmdlets' {

    Context 'Get-PSLogProxyFeature' {
        It 'returns all features' {
            $Features = Get-PSLogProxyFeature
            $Features | Should -Not -BeNullOrEmpty
            $Features.Name | Should -Contain 'LogFile'
            $Features.Name | Should -Contain 'Seq'
            $Features.Name | Should -Contain 'Api'
        }

        It 'returns a single feature by name' {
            $Feature = Get-PSLogProxyFeature -Name 'LogFile'
            $Feature | Should -Not -BeNullOrEmpty
            $Feature.Name | Should -Be 'LogFile'
        }

        It 'returned object has Name, Enabled, CommandString and Settings properties' {
            $Feature = Get-PSLogProxyFeature -Name 'LogFile'
            $Feature.PSObject.Properties.Name | Should -Contain 'Name'
            $Feature.PSObject.Properties.Name | Should -Contain 'Enabled'
            $Feature.PSObject.Properties.Name | Should -Contain 'CommandString'
            $Feature.PSObject.Properties.Name | Should -Contain 'Settings'
        }

        It 'features are disabled by default' {
            (Get-PSLogProxyFeature).Enabled | Should -Not -Contain $true
        }
    }

    Context 'Enable-PSLogProxyFeature' {
        AfterEach {
            Get-PSLogProxyFeature | Disable-PSLogProxyFeature
        }

        It 'enables a feature by name' {
            Enable-PSLogProxyFeature -Name 'LogFile'
            (Get-PSLogProxyFeature -Name 'LogFile').Enabled | Should -Be $true
        }

        It 'does not enable other features when enabling by name' {
            Enable-PSLogProxyFeature -Name 'LogFile'
            (Get-PSLogProxyFeature -Name 'Seq').Enabled | Should -Be $false
            (Get-PSLogProxyFeature -Name 'Api').Enabled | Should -Be $false
        }

        It 'enables a feature by pipeline' {
            Get-PSLogProxyFeature -Name 'Seq' | Enable-PSLogProxyFeature
            (Get-PSLogProxyFeature -Name 'Seq').Enabled | Should -Be $true
        }

        It 'enables all features via pipeline' {
            Get-PSLogProxyFeature | Enable-PSLogProxyFeature
            (Get-PSLogProxyFeature).Enabled | Should -Not -Contain $false
        }

        It 'writes a warning for an unknown feature name' {
            $Output = Enable-PSLogProxyFeature -Name 'NonExistentFeature' 3>&1
            $Output | Should -Match 'NonExistentFeature'
        }
    }

    Context 'Disable-PSLogProxyFeature' {
        BeforeEach {
            Get-PSLogProxyFeature | Enable-PSLogProxyFeature
        }

        AfterEach {
            Get-PSLogProxyFeature | Disable-PSLogProxyFeature
        }

        It 'disables a feature by name' {
            Disable-PSLogProxyFeature -Name 'LogFile'
            (Get-PSLogProxyFeature -Name 'LogFile').Enabled | Should -Be $false
        }

        It 'does not disable other features when disabling by name' {
            Disable-PSLogProxyFeature -Name 'LogFile'
            (Get-PSLogProxyFeature -Name 'Seq').Enabled | Should -Be $true
        }

        It 'disables a feature by pipeline' {
            Get-PSLogProxyFeature -Name 'Seq' | Disable-PSLogProxyFeature
            (Get-PSLogProxyFeature -Name 'Seq').Enabled | Should -Be $false
        }

        It 'disables all features via pipeline' {
            Get-PSLogProxyFeature | Disable-PSLogProxyFeature
            (Get-PSLogProxyFeature).Enabled | Should -Not -Contain $true
        }
    }

    Context 'Get-PSLogProxyFeatureSetting' {
        It 'returns settings hashtable by FeatureName' {
            $Settings = Get-PSLogProxyFeatureSetting -FeatureName 'LogFile'
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.LogFile | Should -Not -BeNullOrEmpty
        }

        It 'returns settings hashtable by pipeline' {
            $Settings = Get-PSLogProxyFeature -Name 'LogFile' | Get-PSLogProxyFeatureSetting
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.LogFile | Should -Not -BeNullOrEmpty
        }

        It 'LogFile settings contain expected keys' {
            $Settings = Get-PSLogProxyFeatureSetting -FeatureName 'LogFile'
            $Settings.Keys | Should -Contain 'LogFile'
            $Settings.Keys | Should -Contain 'AddPrefixDateTimeString'
            $Settings.Keys | Should -Contain 'AddPrefixStream'
            $Settings.Keys | Should -Contain 'AddPrefixInvocationScript'
        }

        It 'Seq settings contain expected keys' {
            $Settings = Get-PSLogProxyFeatureSetting -FeatureName 'Seq'
            $Settings.Keys | Should -Contain 'Uri'
            $Settings.Keys | Should -Contain 'Method'
            $Settings.Keys | Should -Contain 'ExcludeMessageRegex'
        }
    }

    Context 'Set-PSLogProxyFeatureSetting' {
        BeforeAll {
            $OriginalLogFile = (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').LogFile
        }

        AfterEach {
            Set-PSLogProxyFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value $OriginalLogFile
        }

        It 'sets a setting by FeatureName' {
            Set-PSLogProxyFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value 'C:\temp\Test.log'
            (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Test.log'
        }

        It 'sets a setting by pipeline' {
            Get-PSLogProxyFeature -Name 'LogFile' | Set-PSLogProxyFeatureSetting -Name 'LogFile' -Value 'C:\temp\PipeTest.log'
            (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\PipeTest.log'
        }

        It 'persists setting across subsequent calls' {
            Set-PSLogProxyFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value 'C:\temp\Persist.log'
            (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Persist.log'
            (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Persist.log'
        }

        It 'can set boolean prefix settings' {
            Set-PSLogProxyFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $false
            (Get-PSLogProxyFeatureSetting -FeatureName 'LogFile').AddPrefixDateTimeString | Should -Be $false
            Set-PSLogProxyFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
        }
    }

    Context 'Get-PSLogProxySetting / Set-PSLogProxySetting' {
        BeforeAll {
            $OriginalDelimiter    = (Get-PSLogProxySetting).PrefixDelimiter
            $OriginalDateTimeSB   = (Get-PSLogProxySetting).DateTimeStringScriptblock
            $OriginalAddDateTime  = (Get-PSLogProxySetting).AddStreamPrefixDateTimeString
            $OriginalAddScript    = (Get-PSLogProxySetting).AddStreamPrefixInvocationScript
        }

        AfterEach {
            Set-PSLogProxySetting -Name PrefixDelimiter -Value $OriginalDelimiter
            Set-PSLogProxySetting -Name DateTimeStringScriptblock -Value $OriginalDateTimeSB
            Set-PSLogProxySetting -Name AddStreamPrefixDateTimeString -Value $OriginalAddDateTime
            Set-PSLogProxySetting -Name AddStreamPrefixInvocationScript -Value $OriginalAddScript
        }

        It 'returns a settings object with required keys' {
            $Settings = Get-PSLogProxySetting
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.PrefixDelimiter | Should -Not -BeNullOrEmpty
            $Settings.DateTimeStringScriptblock | Should -Not -BeNullOrEmpty
        }

        It 'sets PrefixDelimiter' {
            Set-PSLogProxySetting -Name PrefixDelimiter -Value ' :: '
            (Get-PSLogProxySetting).PrefixDelimiter | Should -Be ' :: '
        }

        It 'sets DateTimeStringScriptblock as a scriptblock' {
            Set-PSLogProxySetting -Name DateTimeStringScriptblock -Value { 'FIXED_DATE' }
            (Get-PSLogProxySetting).DateTimeStringScriptblock.Invoke() | Should -Be 'FIXED_DATE'
        }

        It 'sets AddStreamPrefixDateTimeString' {
            Set-PSLogProxySetting -Name AddStreamPrefixDateTimeString -Value $true
            (Get-PSLogProxySetting).AddStreamPrefixDateTimeString | Should -Be $true
        }

        It 'sets AddStreamPrefixInvocationScript' {
            Set-PSLogProxySetting -Name AddStreamPrefixInvocationScript -Value $false
            (Get-PSLogProxySetting).AddStreamPrefixInvocationScript | Should -Be $false
        }
    }
}
