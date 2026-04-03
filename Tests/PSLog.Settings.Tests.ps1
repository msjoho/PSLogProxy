BeforeAll {
    if (-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))) { $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module .\PSLog -Force
    Get-PSLogFeature | Disable-PSLogFeature
}

Describe 'PSLog Management Cmdlets' {

    Context 'Get-PSLogFeature' {
        It 'returns all features' {
            $Features = Get-PSLogFeature
            $Features | Should -Not -BeNullOrEmpty
            $Features.Name | Should -Contain 'LogFile'
            $Features.Name | Should -Contain 'Seq'
            $Features.Name | Should -Contain 'Api'
        }

        It 'returns a single feature by name' {
            $Feature = Get-PSLogFeature -Name 'LogFile'
            $Feature | Should -Not -BeNullOrEmpty
            $Feature.Name | Should -Be 'LogFile'
        }

        It 'returned object has Name, Enabled, CommandString and Settings properties' {
            $Feature = Get-PSLogFeature -Name 'LogFile'
            $Feature.PSObject.Properties.Name | Should -Contain 'Name'
            $Feature.PSObject.Properties.Name | Should -Contain 'Enabled'
            $Feature.PSObject.Properties.Name | Should -Contain 'CommandString'
            $Feature.PSObject.Properties.Name | Should -Contain 'Settings'
        }

        It 'features are disabled by default' {
            (Get-PSLogFeature).Enabled | Should -Not -Contain $true
        }
    }

    Context 'Enable-PSLogFeature' {
        AfterEach {
            Get-PSLogFeature | Disable-PSLogFeature
        }

        It 'enables a feature by name' {
            Enable-PSLogFeature -Name 'LogFile'
            (Get-PSLogFeature -Name 'LogFile').Enabled | Should -Be $true
        }

        It 'does not enable other features when enabling by name' {
            Enable-PSLogFeature -Name 'LogFile'
            (Get-PSLogFeature -Name 'Seq').Enabled | Should -Be $false
            (Get-PSLogFeature -Name 'Api').Enabled | Should -Be $false
        }

        It 'enables a feature by pipeline' {
            Get-PSLogFeature -Name 'Seq' | Enable-PSLogFeature
            (Get-PSLogFeature -Name 'Seq').Enabled | Should -Be $true
        }

        It 'enables all features via pipeline' {
            Get-PSLogFeature | Enable-PSLogFeature
            (Get-PSLogFeature).Enabled | Should -Not -Contain $false
        }

        It 'writes a warning for an unknown feature name' {
            $Output = Enable-PSLogFeature -Name 'NonExistentFeature' 3>&1
            $Output | Should -Match 'NonExistentFeature'
        }
    }

    Context 'Disable-PSLogFeature' {
        BeforeEach {
            Get-PSLogFeature | Enable-PSLogFeature
        }

        AfterEach {
            Get-PSLogFeature | Disable-PSLogFeature
        }

        It 'disables a feature by name' {
            Disable-PSLogFeature -Name 'LogFile'
            (Get-PSLogFeature -Name 'LogFile').Enabled | Should -Be $false
        }

        It 'does not disable other features when disabling by name' {
            Disable-PSLogFeature -Name 'LogFile'
            (Get-PSLogFeature -Name 'Seq').Enabled | Should -Be $true
        }

        It 'disables a feature by pipeline' {
            Get-PSLogFeature -Name 'Seq' | Disable-PSLogFeature
            (Get-PSLogFeature -Name 'Seq').Enabled | Should -Be $false
        }

        It 'disables all features via pipeline' {
            Get-PSLogFeature | Disable-PSLogFeature
            (Get-PSLogFeature).Enabled | Should -Not -Contain $true
        }
    }

    Context 'Get-PSLogFeatureSetting' {
        It 'returns settings hashtable by FeatureName' {
            $Settings = Get-PSLogFeatureSetting -FeatureName 'LogFile'
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.LogFile | Should -Not -BeNullOrEmpty
        }

        It 'returns settings hashtable by pipeline' {
            $Settings = Get-PSLogFeature -Name 'LogFile' | Get-PSLogFeatureSetting
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.LogFile | Should -Not -BeNullOrEmpty
        }

        It 'LogFile settings contain expected keys' {
            $Settings = Get-PSLogFeatureSetting -FeatureName 'LogFile'
            $Settings.Keys | Should -Contain 'LogFile'
            $Settings.Keys | Should -Contain 'AddPrefixDateTimeString'
            $Settings.Keys | Should -Contain 'AddPrefixStream'
            $Settings.Keys | Should -Contain 'AddPrefixInvocationScript'
        }

        It 'Seq settings contain expected keys' {
            $Settings = Get-PSLogFeatureSetting -FeatureName 'Seq'
            $Settings.Keys | Should -Contain 'Uri'
            $Settings.Keys | Should -Contain 'Method'
            $Settings.Keys | Should -Contain 'ExcludeMessageRegex'
        }
    }

    Context 'Set-PSLogFeatureSetting' {
        BeforeAll {
            $OriginalLogFile = (Get-PSLogFeatureSetting -FeatureName 'LogFile').LogFile
        }

        AfterEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value $OriginalLogFile
        }

        It 'sets a setting by FeatureName' {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value 'C:\temp\Test.log'
            (Get-PSLogFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Test.log'
        }

        It 'sets a setting by pipeline' {
            Get-PSLogFeature -Name 'LogFile' | Set-PSLogFeatureSetting -Name 'LogFile' -Value 'C:\temp\PipeTest.log'
            (Get-PSLogFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\PipeTest.log'
        }

        It 'persists setting across subsequent calls' {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'LogFile' -Value 'C:\temp\Persist.log'
            (Get-PSLogFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Persist.log'
            (Get-PSLogFeatureSetting -FeatureName 'LogFile').LogFile | Should -Be 'C:\temp\Persist.log'
        }

        It 'can set boolean prefix settings' {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $false
            (Get-PSLogFeatureSetting -FeatureName 'LogFile').AddPrefixDateTimeString | Should -Be $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
        }
    }

    Context 'Get-PSLogSetting / Set-PSLogSetting' {
        BeforeAll {
            $OriginalDelimiter    = (Get-PSLogSetting).PrefixDelimiter
            $OriginalDateTimeSB   = (Get-PSLogSetting).DateTimeStringScriptblock
            $OriginalAddDateTime  = (Get-PSLogSetting).AddStreamPrefixDateTimeString
            $OriginalAddScript    = (Get-PSLogSetting).AddStreamPrefixInvocationScript
        }

        AfterEach {
            Set-PSLogSetting -Name PrefixDelimiter -Value $OriginalDelimiter
            Set-PSLogSetting -Name DateTimeStringScriptblock -Value $OriginalDateTimeSB
            Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $OriginalAddDateTime
            Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $OriginalAddScript
        }

        It 'returns a settings object with required keys' {
            $Settings = Get-PSLogSetting
            $Settings | Should -Not -BeNullOrEmpty
            $Settings.PrefixDelimiter | Should -Not -BeNullOrEmpty
            $Settings.DateTimeStringScriptblock | Should -Not -BeNullOrEmpty
        }

        It 'sets PrefixDelimiter' {
            Set-PSLogSetting -Name PrefixDelimiter -Value ' :: '
            (Get-PSLogSetting).PrefixDelimiter | Should -Be ' :: '
        }

        It 'sets DateTimeStringScriptblock as a scriptblock' {
            Set-PSLogSetting -Name DateTimeStringScriptblock -Value { 'FIXED_DATE' }
            (Get-PSLogSetting).DateTimeStringScriptblock.Invoke() | Should -Be 'FIXED_DATE'
        }

        It 'sets AddStreamPrefixDateTimeString' {
            Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $true
            (Get-PSLogSetting).AddStreamPrefixDateTimeString | Should -Be $true
        }

        It 'sets AddStreamPrefixInvocationScript' {
            Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $false
            (Get-PSLogSetting).AddStreamPrefixInvocationScript | Should -Be $false
        }
    }
}
