BeforeAll {
    if(-not $env:PSModulePath.Contains($(Split-Path $PSScriptRoot))){ $env:PSModulePath += ";$(Split-Path $PSScriptRoot)" }
    Import-Module PSLogProxy -Force
    Get-PSLogProxyFeature | Disable-PSLogProxyFeature
    Enable-PSLogProxyFeature -Name LogFile
}

Describe -tag 'Skip' 'WriteToFile Feature' {
    Context 'Verbose' {
        It 'should display Verbose message'{
            $Message = "VerbosePesterTestMessage"
            Write-Verbose $Message -Verbose 4>&1
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
    Context 'Warning' {
        It 'should display Warning message'{
            $Message = "WarningPesterTestMessage"
            Write-Warning $Message 3>&1
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
    Context 'Output' {
        It 'should display Output message' {
            $Message = "OutputPesterTestMessage"
            Write-Output $Message
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
    Context 'Information' {
        It 'should display Information message'{
            $Message = "InformationPesterTestMessage"
            Write-Information $Message 6>&1
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
    Context 'Error' {
        It 'should display Error message'{
            $Message = "ErrorPesterTestMessage"
            Write-Error $Message 2>&1
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
    Context 'Debug' {
        It 'should display Debug message'{
            $Message = "DebugPesterTestMessage"
            Write-Debug $Message
            $LastLogEntry = Get-Content C:\temp\PSLogProxy.log -tail 1
            $LastLogEntry | Should -Match "$($Message)$"
        }
    }
}