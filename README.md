# PSLogProxy

Proxy functions that overwrite the following built-in `Write-*` cmdlets and add additional logging (features):

- `Write-Verbose`
- `Write-Warning`
- `Write-Information`
- `Write-Output` (uses `$PSCmdlet.WriteObject()` instead of steppable pipeline — avoids deadlock on Azure Automation)
- `Write-Error` (not a steppable proxy; uses `$PSCmdlet.WriteError()` with a synthetic `ErrorRecord`)
- `Write-Debug`
- ~~`Write-Host`~~ (avoid using Write-Host)

Define features (e.g. LogFile, see `Data\PSLogProxy.Features.ps1`) which will be called on every `Write-*` invocation using private functions (e.g. `Write-LogFile`, see `Private\Write-LogFile.ps1`).

# PSLogProxy Functions

- `Get-PSLogProxyFeature`
- `Enable-PSLogProxyFeature`
- `Disable-PSLogProxyFeature`
- `Get-PSLogProxyFeatureSetting`
- `Set-PSLogProxyFeatureSetting`
- `Get-PSLogProxySetting`
- `Set-PSLogProxySetting`

See [Usage](#usage) for examples.

# Log Features

## Api

Additionally makes an API call on every enabled log function invocation.

Disabled by default.

### Feature Settings

#### Uri

The full URI, e.g. `'https://sb-api-mock.azurewebsites.net/log'`

#### Method

HTTP method, e.g. `'POST'`

#### BodyScriptBlock

ScriptBlock string evaluated at runtime. Variables `$Type` and `$Message` are available.
e.g. `'@{"level"=$Type; "message"=$Message}'`

#### AddPrefixDateTimeString (available on all features)

If `$true`, adds the DateTimeString (ScriptBlock defined in Settings) to the feature message.

#### AddPrefixStream (available on all features)

If `$true`, adds the stream noun (e.g. `Warning`) to the feature message. Defaults to `$true` on LogFile only.

#### AddPrefixInvocationScript (available on all features)

If `$true`, adds the calling script leaf name (`$MyInvocation.ScriptName`) as a prefix to the feature message.

#### ExcludeMessageRegex (available on all features that define it)

Array of regex patterns. If any match the message, the feature is skipped for that invocation. Defined on Seq by default (empty array).

## LogFile

Additionally logs all messages to a logfile (UNC path) with a universal sortable datetime stamp.

Cannot be used on Azure Automation workers.

Disabled by default.

### Feature Settings

#### LogFile

UNC path to the logfile, default: `"C:\temp\PSLogProxy.log"`

## Seq

Sends log events to a Seq log server via HTTP.

Disabled by default.

### Feature Settings

#### Uri

The full URI of the Seq ingest endpoint. Must be set via `Set-PSLogProxyFeatureSetting`.

#### Method

HTTP method, default: `'POST'`

#### BodyScriptBlock

ScriptBlock string evaluated at runtime to produce the request body. Has access to `$Type`, `$Message`, and `$FeatureSettings`.

#### Properties

Hashtable of additional properties sent with each event, e.g. `@{text=''}`. Can be extended at runtime via `Set-PSLogProxyFeatureSetting`.

## Implement New Feature

Add a new `[PSLogProxyFeature]` object to the `$Script:PSLogProxyFeature` array in `Data\PSLogProxy.Features.ps1` with `Name`, `Enabled`, and `CommandString`.

When a feature is enabled, its `CommandString` is called for every `Write-*` invocation. Before execution, the following placeholders are replaced:

- `{{Stream}}` — noun of the proxy function (e.g. `Verbose` in `Write-Verbose`)
- `{{Message}}` — the message passed to the proxy function

Add a matching private function in `Private\` for use in `CommandString`.

# Settings

## DateTimeStringScriptblock

ScriptBlock invoked during `Write-*` calls to produce the datetime prefix string, default: `{get-date -format u}`

## AddStreamPrefixDateTimeString

Boolean. If `$true`, adds the DateTimeString to the PowerShell stream message. Default: `$false`

## AddStreamPrefixInvocationScript

Boolean. If `$true`, adds the calling script leaf name (`$MyInvocation.ScriptName`) as a prefix to the stream message. Default: `$true`

## PrefixDelimiter

String used to join prefixes, default: `' | '`

# Usage

**Import the module** to overwrite the built-in functions. If any feature is enabled, a verbose message is written on import (even if `$VerbosePreference` is `SilentlyContinue`):

```
2023-02-14 10:57:28Z | Verbose | PSLogProxy Module activated on Computer1 with UserName1 (Enabled Feature: LogFile)
```

Once loaded, use the proxy functions normally — enabled features are invoked automatically.

## Configuration

### Enable/Disable Features

```powershell
# Enable LogFile feature
Enable-PSLogProxyFeature -Name LogFile
# Disable LogFile feature
Disable-PSLogProxyFeature -Name LogFile
```

### Change Feature Settings

```powershell
# Change the log file path for the LogFile feature
Get-PSLogProxyFeature -Name "LogFile" | Set-PSLogProxyFeatureSetting -Name "LogFile" -Value "C:\temp\PSLogProxy.log"
```

### Change Log Settings

```powershell
# Change DateTimeString to Swiss format
Set-PSLogProxySetting -DateTimeString {Get-Date -Format "dd.MM.yyyy HH:mm:ss"}
```

# Known Issues

## Write-Debug

- Additional `"Setting WindowTitle: log [main] - PowerShell 7.3 (xxx)"` debug output may appear in some PS7 hosts.

## Write-Output

- Does not work on Azure Automation (PS5.1).
