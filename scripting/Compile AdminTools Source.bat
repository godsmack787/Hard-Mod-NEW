@echo off
echo ::
echo This program will automaticly compile AdminTools: Source
echo and move the compiled file to "Plugins" directory.
echo ::
pause
spcomp admintoolssource
move admintoolssource.smx ..\plugins\admintoolssource.smx
echo ::
echo Completed.
echo ::
pause