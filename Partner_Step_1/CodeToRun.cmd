@echo off
set /p rLocation=<R_Location.txt
"%rLocation%/Rscript.exe" CodeToRun.r
pause
exit