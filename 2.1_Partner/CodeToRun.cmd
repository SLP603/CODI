@echo off
set /p rLocation=<R_Location.txt
"%rLocation%/Rscript.exe" --vanilla CodeToRun.r
pause
exit