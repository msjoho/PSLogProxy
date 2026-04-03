$Script:PSLogProxyFeature = @(
    (
        [PSLogProxyFeature]@{
            Name          = 'LogFile'
            Enabled       = $false
            CommandString = 'Write-LogFile -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                LogFile                   = "C:\temp\PSLogProxy.log"
                AddPrefixDateTimeString   = $true
                AddPrefixStream           = $true
                AddPrefixInvocationScript = $true
            }
        },
        [PSLogProxyFeature]@{
            Name          = 'Seq'
            Enabled       = $false
            CommandString = 'Write-Seq -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                Uri                       = '' # needs to be set with Set-PSLogProxyFeatureSetting
                Method                    = 'POST'
                BodyScriptBlock           = '$FeatureSettings.Properties.text=$Message;@{"Events"=@(@{"Timestamp"="$([System.DateTimeOffset]::Now.ToString("o"))";"Level"="$($Type)";"Exception"="null";"MessageTemplate"=("{text}" | ConvertTo-Json);"Properties"=$($FeatureSettings.Properties)})}'
                AddPrefixDateTimeString   = $false
                AddPrefixInvocationScript = $true
                Properties                = @{text = '' }
                ExcludeMessageRegex       = @()
            }
        },
        [PSLogProxyFeature]@{
            Name          = 'Api'
            Enabled       = $false
            CommandString = 'Write-Api -Type {{Stream}} -Message "{{Message}}"'
            Settings      = @{
                Uri                       = '' # needs to be set with Set-PSLogProxyFeatureSetting
                Method                    = 'POST'
                BodyScriptBlock           = '@{"level"=$Type; "message"=$Message}'
                AddPrefixDateTimeString   = $false
                AddPrefixInvocationScript = $true
            }
        }
    )
)
