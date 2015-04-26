@echo off
if %1 == debug (
	bin\Test-debug.exe
) else (
	bin\Test.exe
)
pause