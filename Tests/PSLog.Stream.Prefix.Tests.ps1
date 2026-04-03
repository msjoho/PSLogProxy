BeforeAll {
    if (-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))) { $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module .\PSLog -Force
    Get-PSLogFeature | Disable-PSLogFeature
}

Describe 'Write-* Stream Prefix' {

    BeforeEach {
        Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $false
        Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $false
        Set-PSLogSetting -Name PrefixDelimiter -Value ' | '
        Set-PSLogSetting -Name DateTimeStringScriptblock -Value { 'TEST_DT' }
    }

    AfterAll {
        Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $false
        Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $true
        Set-PSLogSetting -Name PrefixDelimiter -Value ' | '
        Set-PSLogSetting -Name DateTimeStringScriptblock -Value { Get-Date -Format u }
    }

    Context 'No prefix' {
        It 'Verbose: output is raw message' {
            $Output = (Write-Verbose 'RawVerboseMsg' -Verbose) 4>&1
            $Output.toString() | Should -Be 'RawVerboseMsg'
        }

        It 'Warning: output is raw message' {
            $Output = (Write-Warning 'RawWarningMsg') 3>&1
            $Output.toString() | Should -Be 'RawWarningMsg'
        }

        It 'Information: output is raw message' {
            $Output = (Write-Information 'RawInfoMsg') 6>&1
            $Output.toString() | Should -Be 'RawInfoMsg'
        }

        It 'Output: output is raw message' {
            $Output = (Write-Output 'RawOutputMsg')
            $Output.toString() | Should -Be 'RawOutputMsg'
        }
    }

    Context 'DateTimeString prefix' {
        BeforeEach {
            Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $true
        }

        It 'Verbose: output includes datetime prefix' {
            $Output = (Write-Verbose 'VerboseMsg' -Verbose) 4>&1
            $Output.toString() | Should -Be 'TEST_DT | VerboseMsg'
        }

        It 'Warning: output includes datetime prefix' {
            $Output = (Write-Warning 'WarningMsg') 3>&1
            $Output.toString() | Should -Be 'TEST_DT | WarningMsg'
        }

        It 'Information: output includes datetime prefix' {
            $Output = (Write-Information 'InformationMsg') 6>&1
            $Output.toString() | Should -Be 'TEST_DT | InformationMsg'
        }

        It 'Output: output includes datetime prefix' {
            $Output = (Write-Output 'OutputMsg')
            $Output.toString() | Should -Be 'TEST_DT | OutputMsg'
        }

        It 'Debug: output includes datetime prefix' {
            $Output = (Write-Debug 'DebugMsg' -Debug) 5>&1
            $Output.toString() | Should -BeLike '*TEST_DT | DebugMsg*'
        }
    }

    Context 'Custom PrefixDelimiter' {
        BeforeEach {
            Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $true
            Set-PSLogSetting -Name PrefixDelimiter -Value ' -- '
        }

        It 'Verbose: output uses custom delimiter' {
            $Output = (Write-Verbose 'VerboseMsg' -Verbose) 4>&1
            $Output.toString() | Should -Be 'TEST_DT -- VerboseMsg'
        }

        It 'Warning: output uses custom delimiter' {
            $Output = (Write-Warning 'WarningMsg') 3>&1
            $Output.toString() | Should -Be 'TEST_DT -- WarningMsg'
        }

        It 'Information: output uses custom delimiter' {
            $Output = (Write-Information 'InformationMsg') 6>&1
            $Output.toString() | Should -Be 'TEST_DT -- InformationMsg'
        }
    }

    Context 'InvocationScript prefix' {
        BeforeEach {
            Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $true
        }

        It 'Verbose: output is <scriptname> | message' {
            $Output = (Write-Verbose 'VerboseMsg' -Verbose) 4>&1
            # .+ requires a non-empty script name before the separator
            $Output.toString() | Should -Match '^.+ \| VerboseMsg$'
        }

        It 'Warning: output is <scriptname> | message' {
            $Output = (Write-Warning 'WarningMsg') 3>&1
            $Output.toString() | Should -Match '^.+ \| WarningMsg$'
        }

        It 'Information: output is <scriptname> | message' {
            $Output = (Write-Information 'InformationMsg') 6>&1
            $Output.toString() | Should -Match '^.+ \| InformationMsg$'
        }

        It 'Output: output is <scriptname> | message' {
            $Output = (Write-Output 'OutputMsg')
            $Output.toString() | Should -Match '^.+ \| OutputMsg$'
        }

        It 'Verbose: output is not equal to raw message' {
            $Output = (Write-Verbose 'VerboseMsg' -Verbose) 4>&1
            $Output.toString() | Should -Not -Be 'VerboseMsg'
        }
    }

    Context 'Combined DateTimeString and InvocationScript prefix' {
        BeforeEach {
            Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $true
            Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $true
        }

        It 'Verbose: output is TEST_DT | <scriptname> | message' {
            $Output = (Write-Verbose 'VerboseMsg' -Verbose) 4>&1
            # .+ ensures the script name slot is non-empty between the two separators
            $Output.toString() | Should -Match '^TEST_DT \| .+ \| VerboseMsg$'
        }

        It 'Warning: output is TEST_DT | <scriptname> | message' {
            $Output = (Write-Warning 'WarningMsg') 3>&1
            $Output.toString() | Should -Match '^TEST_DT \| .+ \| WarningMsg$'
        }

        It 'Information: output is TEST_DT | <scriptname> | message' {
            $Output = (Write-Information 'InformationMsg') 6>&1
            $Output.toString() | Should -Match '^TEST_DT \| .+ \| InformationMsg$'
        }

        It 'Output: output is TEST_DT | <scriptname> | message' {
            $Output = (Write-Output 'OutputMsg')
            $Output.toString() | Should -Match '^TEST_DT \| .+ \| OutputMsg$'
        }
    }
}
