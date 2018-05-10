@echo off

cd ..\..
rd WHMRelease /s /Q
xcopy WebHostingManager WHM /s /i /Exclude:WebHostingManager\exclude.txt

cd WebHostingManager\setup
echo *****Start compiling executable installer
call iscc 'Setup.iss'

cd ..\..
rd WHMRelease /s /Q

pause