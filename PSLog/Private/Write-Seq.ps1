function Write-Seq {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")] # will be used in BodyScriptBlock
    param(
        [ValidateSet("Verbose", "Warning", "Error", "Information", "Output", "Console", "Debug")]
        [String]$Type = "Verbose",
        [Parameter(Mandatory)]
        $Message
    )
    $FeatureName = $MyInvocation.MyCommand.Noun
    $FeatureSettings = ($PSLogFeature | Where-Object Name -EQ $FeatureName).Settings

    $Body = ([ScriptBlock]::Create($FeatureSettings.BodyScriptBlock)).InvokeReturnAsIs()
    Update-TypeData -TypeName System.Collections.HashTable -MemberType ScriptMethod -MemberName ToString -Value { $hashstr = "@{"; $keys = $this.keys; foreach ($key in $keys) { $v = $this[$key]; if ($key -match "\s") { $hashstr += "`"$key`"" + "=" + "`"$v`"" + ";" }else { $hashstr += $key + "=" + "`"$v`"" + ";" } }; $hashstr += "}"; return $hashstr } -Force

    $null = Invoke-RestMethod -Uri $FeatureSettings.Uri -Method $FeatureSettings.Method -Body ($Body | ConvertTo-Json -Depth 99) -ContentType "application/json" -Verbose:$False
}
