function Set-PSLogProxySetting {
    <#
    .SYNOPSIS
        Configures PSLogProxy Feature Settings
    .DESCRIPTION
        Configures PSLogProxy Feature Settings which can be set per session
    .PARAMETER FeatureName
        Name of the Feature
    .PARAMETER Name
        Name of the Setting
    .PARAMETER DateTimeStringScriptBlock
        Define a scriptblock like {Get-Date -format "yyMMdd"} to be used in the log entries
    .EXAMPLE
        Set-PSLogProxySetting -Name DateTimeString -Value {Get-Date -Format "yyMMdd"}
    #>
    param(
        [Parameter(Mandatory,Position = 0)]
        [String]$Name,
        [Parameter(Mandatory,Position = 1)]
        [PSObject]$Value
    )
    $Script:PSLogProxySetting.$Name = $Value
}
