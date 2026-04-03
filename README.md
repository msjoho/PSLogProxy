# Table of contents

[[_TOC_]]

# Scope

Proxy functions, overwrites the following built-in Write-\* functions (as e.g. Write-Verbose) and adds additional logging (features)

- Write-Verbose
- Write-Warning
- Write-Information
- Write-Output (uses `$PSCmdlet.WriteObject()` instead of steppable pipeline — avoids deadlock on Azure Automation)
- Write-Error (not a steppable proxy; uses `$PSCmdlet.WriteError()` with a synthetic `ErrorRecord`)
- Write-Debug
- ~~Write-Host~~ (Avoid using Write-Host)

Define Features (e.g. LogFile, see Data\PSLog.Features.ps1) which wil be called on the invocation of the Write-\* function using private functions (e.g. Write-LogFile, see Private\Write-LogFile.ps1)

# PSLog function

- Get-PSLogFeature
- Enable-PSLogFeature
- Disable-PSLogFeature
- Get-PSLogFeatureSetting
- Set-PSLogFeatureSetting
- Get-PSLogSetting
- Set-PSLogSetting

Check [Usage](#usage) to see how to use...

# Log Features

## Api

Additionaly makes an API call on every enabled LogFunction invocation.

Disabled by default

### Feature Settings:

#### Uri

define the full uri, e.g. `'https://sb-api-mock.azurewebsites.net/log'`

#### Method

Api method, e.g. `'POST'`

#### BodyScriptBlock

ScriptBlock which will be invoked on the Feature function. Therefore variables will be replaced.
e.g. to define body (hashtable) with level and message `'@{"level"=$Type; "message"=$Message}'`

#### AddPrefixDateTimeString (available on all features)

If specified, adds the DateTimeString (ScriptBlock defined in Settings) to the Feature message

#### AddPrefixStream (available on all features)

If specified, adds the stream noun (e.g. `Warning`) to the Feature message. Defaults to `$true` on LogFile only.

#### AddPrefixInvocationScript (available on all features)

If specified, adds the noun of the script which has invoked the Write-\* call ($MyInvocation.ScriptName) as Prefix to the stream message

#### ExcludeMessageRegex (available on all features that define it)

Array of regex patterns. If any match the message, the feature is skipped for that invocation. Defined on Seq by default (empty array).

## LogFile

Additionaly logs the message of all the Logfunctions to a logfile (UNC Path) with a universal sortable datetime stamp

The Write-to-File feature can not be used on Azure Automation worker

Disabled by default

### Feature Settings:

#### LogFile

UNC Path to the Logfile, default: `"C:\temp\PSLog.log"`

## Seq

Sends log events to a Seq log server via HTTP.

Disabled by default

### Feature Settings:

#### Uri

The full URI of the Seq ingest endpoint. Must be set via `Set-PSLogFeatureSetting`.

#### Method

HTTP method, default: `'POST'`

#### BodyScriptBlock

ScriptBlock string evaluated at runtime to produce the request body. Has access to `$Type`, `$Message`, and `$FeatureSettings`.

#### Properties

Hashtable of additional properties sent with each event, e.g. `@{text=''}`. Properties can be extended at runtime via `Set-PSLogFeatureSetting`.

## Implement New feature

Simply add new feature [PSLogFeature] object to $Script:PSLogFeature array with Name, Enabled and CommandString.

If a PSLogFeature is enabled, its CommandString will be called for every proxy function (Write-\*)

Before the CommandString is converted and executed, the following will be replaced:

{{Stream}} --> Noun of the proxy function (e.g. Verbose in Write-Verbose)

{{Message}} --> Message of the called proxy function

Define private functions to use in CommandString

# Settings

## DateTimeStringScriptblock

ScriptBlock will be invoked during Write-\* invocation call for DateTimeString Prefix, default `{get-date -format u}`

## AddStreamPrefixDateTimeString

Boolean, if true, adds the DateTimeString (ScriptBlock defined in DateTimeStringScriptblock) to the stream message

## AddStreamPrefixInvocationScript

Boolean, if true, adds the noun of the script which has invoked the Write-\* call ($MyInvocation.ScriptName) as Prefix to the stream message, default ``$true``

## PrefixDelimiter

Used to delimit the prefixes, default `' | '`

# Usage

Simply **import the module** to overwrite the built-in functions.
A Verbose Message will be displayed on the console and in the enabled feature when Log Module is activated (even if VerbosePreference is SilentlyContinue), e.g.

```
2023-02-14 10:57:28Z | Verbose | PSLog Module activated on Computer1 with UserName1 (Enabled Feature: LogFile)
```

Once the module is loaded, simply use the listed Proxy functions (above) and additional steps (log features) will be processed:

## Configuration

### Enable/Disable Features

```powershell
# Enable LogFile Feature
Enable-PSLogFeature -Name LogFile
# Disable LogFile Feature
Disable-PSLogFeature -Name LogFile
```

### Change Feature Settings

```powershell
# Change LogFilePath for the LogFile feature
Get-PSLogFeature -Name "LogFile" | Set-PSLogFeatureSetting -Name "LogFile" -Value "C:\temp\PSLog.log"
```

### Change Log Settings

```powershell
# Change DateTimeString to swiss format
Set-PSLogSetting -DateTimeString {Get-Date -Format "dd.MM.yyyy HH:mm:ss"}
```

# Known Issues

## Write-Debug

    - additional "Setting WindowTitle: log [main] - PowerShell 7.3 (xxx)" debug output may appear in some PS7 hosts

## Write-Output

    - does not work on Azure Automation (PS5.1)

## Changelog

### 0.0.1

Initial version. Includes Write-to-File step

### 0.0.2

Store features snipplets in hashtable (script scope) / Introduce LogSettings / Added PesterTests

### 0.0.3

Implemented Write-Information, Write-Debug and use only proxy function

### 0.0.4

Changed module structure and renamed module to PSLog

### 0.0.5

Adding new Feature LogToMockJsonServer / introduce PSModule Data folder

### 0.0.6

Add WriteToMockJsonServer Pester / Separate Data file

### 0.0.7

Introduce AddInvocationScriptPrefix Setting

### 0.0.8

Fix String Injection in Message

### 0.0.9

Introduce individual Prefix in Feature (configured in FeatureSetting) & Stream (configured in Settings)

### 0.0.10

Disabled Write-Output (does not work in AA)

### 0.0.11

Added seqlog feature

### 0.0.12

Added dune relevant properties (txId, jobId, ) into seqlog call

### 0.0.13

Fixed error by using other method as proxy function

### 0.0.14

Added possibility to add properties at runtime for seq feature.

### 0.0.15

Remove custom config from features
