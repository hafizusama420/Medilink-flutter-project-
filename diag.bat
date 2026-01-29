@echo off
set SRC=C:\Users\usama\.gemini\antigravity\brain\0969e728-36d4-457d-bec8-9b51818f6e00\medilink_app_icon_1766485646446.png
set DEST=d:\flutter\semesterprojectgetx\assets\images\app_icon.png
echo Looking for %SRC% > debug.txt
if exist "%SRC%" (
    echo Source exists >> debug.txt
    copy "%SRC%" "%DEST%" /Y >> debug.txt 2>&1
    if exist "%DEST%" (
        echo Copy verified >> debug.txt
    ) else (
        echo Copy failed - destination missing >> debug.txt
    )
) else (
    echo Source MISSING >> debug.txt
)
dir d:\flutter\semesterprojectgetx\assets\images >> debug.txt
