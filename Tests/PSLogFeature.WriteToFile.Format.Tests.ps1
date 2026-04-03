BeforeAll {
    if (-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))) { $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module PSLog -Force
    Get-PSLogFeature | Disable-PSLogFeature
    Enable-PSLogFeature -Name LogFile
    Set-PSLogSetting -Name DateTimeStringScriptblock -Value { 'TEST_DT' }
    Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $false
    Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $false
}

AfterAll {
    Set-PSLogSetting -Name DateTimeStringScriptblock -Value { Get-Date -Format u }
    Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $true
    Get-PSLogFeature | Disable-PSLogFeature
    Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
    Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $true
    Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $true
    Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'ExcludeMessageRegex' -Value @()
}

Describe -tag 'Skip' 'WriteToFile Feature Log Entry Format' {

    Context 'DateTime prefix only' {
        BeforeEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $false
        }

        It 'Verbose: log entry is datetime | message' {
            Write-Verbose 'VerboseLogMsg' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | VerboseLogMsg'
        }

        It 'Warning: log entry is datetime | message' {
            Write-Warning 'WarningLogMsg' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | WarningLogMsg'
        }

        It 'Information: log entry is datetime | message' {
            Write-Information 'InfoLogMsg' 6>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | InfoLogMsg'
        }

        It 'Output: log entry is datetime | message' {
            Write-Output 'OutputLogMsg'
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | OutputLogMsg'
        }
    }

    Context 'Stream prefix only' {
        BeforeEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $false
        }

        It 'Verbose: log entry is Verbose | message' {
            Write-Verbose 'VerboseStreamMsg' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'Verbose | VerboseStreamMsg'
        }

        It 'Warning: log entry is Warning | message' {
            Write-Warning 'WarningStreamMsg' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'Warning | WarningStreamMsg'
        }

        It 'Information: log entry is Information | message' {
            Write-Information 'InfoStreamMsg' 6>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'Information | InfoStreamMsg'
        }

        It 'Output: log entry is Output | message' {
            Write-Output 'OutputStreamMsg'
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'Output | OutputStreamMsg'
        }
    }

    Context 'DateTime and Stream prefix' {
        BeforeEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $false
        }

        It 'Verbose: log entry is datetime | Verbose | message' {
            Write-Verbose 'VerboseFmtMsg' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | Verbose | VerboseFmtMsg'
        }

        It 'Warning: log entry is datetime | Warning | message' {
            Write-Warning 'WarningFmtMsg' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | Warning | WarningFmtMsg'
        }

        It 'Information: log entry is datetime | Information | message' {
            Write-Information 'InfoFmtMsg' 6>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | Information | InfoFmtMsg'
        }

        It 'Output: log entry is datetime | Output | message' {
            Write-Output 'OutputFmtMsg'
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'TEST_DT | Output | OutputFmtMsg'
        }
    }

    Context 'Full format (DateTime + Stream + InvocationScript)' {
        BeforeEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $true
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $true
        }

        It 'Verbose: log entry matches datetime | Verbose | script | message' {
            Write-Verbose 'VerboseFullMsg' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Match '^TEST_DT \| Verbose \| .+ \| VerboseFullMsg$'
        }

        It 'Warning: log entry matches datetime | Warning | script | message' {
            Write-Warning 'WarningFullMsg' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Match '^TEST_DT \| Warning \| .+ \| WarningFullMsg$'
        }

        It 'Information: log entry matches datetime | Information | script | message' {
            Write-Information 'InfoFullMsg' 6>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Match '^TEST_DT \| Information \| .+ \| InfoFullMsg$'
        }
    }

    Context 'ExcludeMessageRegex' {
        BeforeEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixDateTimeString' -Value $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixStream' -Value $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'AddPrefixInvocationScript' -Value $false
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'ExcludeMessageRegex' -Value @('EXCLUDEME')
        }

        AfterEach {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'ExcludeMessageRegex' -Value @()
        }

        It 'excluded message is not written to log' {
            Write-Verbose 'AnchorMessage' -Verbose 4>&1
            Write-Verbose 'EXCLUDEME this message' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'AnchorMessage'
        }

        It 'non-excluded message is written to log' {
            Write-Warning 'AllowedMessage' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'AllowedMessage'
        }

        It 'regex matches anywhere in the message' {
            Write-Verbose 'AnchorMessage' -Verbose 4>&1
            Write-Verbose 'This contains EXCLUDEME in the middle' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'AnchorMessage'
        }

        It 'multiple regex patterns: any match excludes the message' {
            Set-PSLogFeatureSetting -FeatureName 'LogFile' -Name 'ExcludeMessageRegex' -Value @('PATTERN_A', 'PATTERN_B')
            Write-Verbose 'AnchorMessage' -Verbose 4>&1
            Write-Verbose 'Contains PATTERN_B here' -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'AnchorMessage'
        }

        It 'applies to Warning stream as well' {
            Write-Warning 'AnchorMessage' 3>&1
            Write-Warning 'EXCLUDEME warning' 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLog.log -Tail 1
            $LastLogEntry | Should -Be 'AnchorMessage'
        }
    }
}
