# Script Variables
$Script:PSLogProxySetting = @{
    DateTimeStringScriptblock = {get-date -format u}
    AddStreamPrefixDateTimeString = $false
    AddStreamPrefixInvocationScript = $true
    PrefixDelimiter = ' | '
}
$Script:ReplaceFeatureCommand = {$args[0].Replace("{{Stream}}",$args[1]).Replace("{{Message}}",$args[2].Replace('"','""'))} #where args[0] = PSLogProxyFeature Command (see above) / $args[1] = Stream / $args[2] = LogMessage