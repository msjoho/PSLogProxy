$Class = @( Get-ChildItem -Path $PSScriptRoot\Class\*.ps1 -ErrorAction SilentlyContinue )
$Data = @( Get-ChildItem -Path $PSScriptRoot\Data\*.ps1 -ErrorAction SilentlyContinue )
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

foreach ($Function in @($Class + $Data + $Public + $Private)) {
    try {
        . $Function.FullName
    }
    catch {
        Write-Error -Message "Import function ($($Function.fullname)) failed: $_"
    }
}

# Initial Verbose on Module Activation
If ($PSLogProxyFeature | Where-Object Enabled) {
    Write-Verbose -Verbose -Message "PSLogProxy Module activated on $($env:COMPUTERNAME) with $($env:USERNAME) (Enabled Feature$(if(($PSLogProxyFeature | Where-Object Enabled).Count -gt 1){"s"}): $(($PSLogProxyFeature | Where-Object Enabled).Name -join ", ""))"
}

# Disabled Functions (don't forget to disable in Tests)
$DisabledFunctions = @(
    "Write-Output_function" #test to use function instead of cmdlet in proxyfunction for issue on AA (replaced by Write-Output using $PSCmdlet.WriteObject)
)

Export-ModuleMember -Function ($Public.Basename | Where-Object { $_ -notin $DisabledFunctions })