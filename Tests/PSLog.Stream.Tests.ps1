BeforeAll {
    if(-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))){ $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module .\PSLog -Force
    Set-PSLogSetting -Name AddStreamPrefixDateTimeString -Value $false
    Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $false
    Get-PSLogFeature | Disable-PSLogFeature
}

AfterAll {
    Set-PSLogSetting -Name AddStreamPrefixInvocationScript -Value $true
}

Describe 'Write-* Functions' {
    Context 'Verbose' {
        It 'should display Verbose message' {
            $Message = "VerbosePesterTestMessage1"
            $Output = (Write-Verbose $Message -Verbose) 4>&1
            $Output.toString() | Should -Be $Message
        }

        It 'should display Verbose message the second time' {
            $Message = "VerbosePesterTestMessage2"
            $Output = (Write-Verbose $Message -Verbose) 4>&1
            $Output.toString() | Should -Be $Message
        }

        It 'does not output when VerbosePreference is SilentlyContinue' {
            $VerbosePreference = 'SilentlyContinue'
            $Output = (Write-Verbose 'SilentMsg') 4>&1
            $Output | Should -BeNullOrEmpty
        }
    }

    Context 'Warning' {
        It 'should display Warning message' {
            $Message = "WarningPesterTestMessage1"
            $Output = (Write-Warning $Message) 3>&1
            $Output.toString() | Should -Be $Message
        }

        It 'should display Warning message the second time' {
            $Message = "WarningPesterTestMessage2"
            $Output = (Write-Warning $Message) 3>&1
            $Output.toString() | Should -Be $Message
        }

        It 'output is a WarningRecord object' {
            $Output = (Write-Warning 'WarningRecordMsg') 3>&1
            $Output | Should -BeOfType System.Management.Automation.WarningRecord
        }
    }

    Context 'Output' {
        It 'should display Output message' {
            $Message = "OutputPesterTestMessage1"
            $Output = (Write-Output $Message)
            $Output.toString() | Should -Be $Message
        }

        It 'should display Output message the second time' {
            $Message = "OutputPesterTestMessage2"
            $Output = (Write-Output $Message)
            $Output.toString() | Should -Be $Message
        }

        It 'accepts pipeline input' {
            $Output = ('OutputPipeMsg' | Write-Output)
            $Output.toString() | Should -Be 'OutputPipeMsg'
        }

        It 'each piped item is passed through individually' {
            # Pipe items one-by-one; the proxy processes each in its own invocation
            $Output = @('Alpha', 'Beta', 'Gamma' | Write-Output)
            $Output.Count | Should -Be 3
            $Output | Should -Contain 'Alpha'
            $Output | Should -Contain 'Gamma'
        }

        It '-NoEnumerate is accepted and passes single value through' {
            $Output = Write-Output 'SingleValue' -NoEnumerate
            $Output | Should -Be 'SingleValue'
        }
    }

    Context 'Information' {
        It 'should display Information message' {
            $Message = "InformationPesterTestMessage1"
            $Output = (Write-Information $Message) 6>&1
            $Output.toString() | Should -Be $Message
        }

        It 'should display Information message the second time' {
            $Message = "InformationPesterTestMessage2"
            $Output = (Write-Information $Message) 6>&1
            $Output.toString() | Should -Be $Message
        }

        It 'output is an InformationRecord object' {
            $Output = (Write-Information 'InfoRecordMsg') 6>&1
            $Output | Should -BeOfType System.Management.Automation.InformationRecord
        }

        It 'preserves Tags on InformationRecord' {
            $Output = (Write-Information 'TaggedMsg' -Tags 'PesterTag') 6>&1
            $Output.Tags | Should -Contain 'PesterTag'
        }

        It 'preserves multiple Tags on InformationRecord' {
            $Output = (Write-Information 'MultiTagMsg' -Tags 'TagA', 'TagB') 6>&1
            $Output.Tags | Should -Contain 'TagA'
            $Output.Tags | Should -Contain 'TagB'
        }
    }

    Context 'Error' {
        It 'should display Error message' {
            $Message = "ErrorPesterTestMessage1"
            $Output = (Write-Error $Message) 2>&1
            $Output.toString() | Should -Match $Message
        }

        It 'should display Error message the second time' {
            $Message = "ErrorPesterTestMessage2"
            $Output = (Write-Error $Message) 2>&1
            $Output.toString() | Should -Match $Message
        }

        It 'output is an ErrorRecord object' {
            $Output = (Write-Error 'ErrorRecordMsg') 2>&1
            $Output | Should -BeOfType System.Management.Automation.ErrorRecord
        }

        It 'ErrorRecord contains the message' {
            $Output = (Write-Error 'ErrorContainsMsg') 2>&1
            $Output.Exception.Message | Should -Be 'ErrorContainsMsg'
        }
    }

    Context 'Debug' {
        It 'should display Debug message' {
            $Message = "DebugPesterTestMessage1"
            $Output = (Write-Debug $Message -Debug) 5>&1
            $Output.toString() | Should -Match $Message
        }

        It 'should display Debug message the second time' {
            $Message = "DebugPesterTestMessage2"
            $Output = (Write-Debug $Message -Debug) 5>&1
            $Output.toString() | Should -Match $Message
        }

        It 'does not output when DebugPreference is SilentlyContinue' {
            $DebugPreference = 'SilentlyContinue'
            $Output = (Write-Debug 'SilentDebugMsg') 5>&1
            $Output | Should -BeNullOrEmpty
        }
    }
}
