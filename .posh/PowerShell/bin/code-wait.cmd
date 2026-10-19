@echo off
rem Wrapper for PSReadLine ViEditVisually: $env:EDITOR must be a single
rem application (no arguments), so "code --wait" cannot be set directly.
call code --wait %*
