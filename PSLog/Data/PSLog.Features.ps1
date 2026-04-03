$Script:PSLogFeature = @(
    (
        [PSLogFeature]@{
            Name          = 'LogFile'
            Enabled       = $false
            CommandString = 'Write-LogFile -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                LogFile                   = "C:\temp\PSLog.log"
                AddPrefixDateTimeString   = $true
                AddPrefixStream           = $true
                AddPrefixInvocationScript = $true
            }
        },
        [PSLogFeature]@{
            Name          = 'Seq'
            Enabled       = $false
            CommandString = 'Write-Seq -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                Uri                       = '' # needs to be set with Set-PSLogFeatureSetting
                Method                    = 'POST'
                BodyScriptBlock           = '$FeatureSettings.Properties.text=$Message;@{"Events"=@(@{"Timestamp"="$([System.DateTimeOffset]::Now.ToString("o"))";"Level"="$($Type)";"Exception"="null";"MessageTemplate"=("{text}" | ConvertTo-Json);"Properties"=$($FeatureSettings.Properties)})}'
                AddPrefixDateTimeString   = $false
                AddPrefixInvocationScript = $true
                Properties                = @{text = '' }
                ExcludeMessageRegex       = @()
            }
        },
        [PSLogFeature]@{
            Name          = 'Api'
            Enabled       = $false
            CommandString = 'Write-Api -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                Uri                       = '' # needs to be set with Set-PSLogFeatureSetting
                Method                    = 'POST'
                BodyScriptBlock           = '@{"level"=$Type; "message"=$Message}'
                AddPrefixDateTimeString   = $false
                AddPrefixInvocationScript = $true
            }
        }
    )
)
