# Release Notes

## 1.0.2

* Feature invocation is guarded: a failing log feature (unreachable Seq, unparsable message) can no longer throw out of a `Write-*` proxy and replace the message or error record being logged - the original stream write always runs, the feature failure becomes a verbose note

## 1.0.1
Update Metadata

## 1.0.0

Initial version
