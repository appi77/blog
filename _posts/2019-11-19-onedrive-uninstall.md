---
title: "윈도우10 OneDrive 삭제 방법"
date: 2019-11-19 21:19:29
categories: ["PC환경 수정"]
author: "박경원"
layout: post
---

set x86="%SYSTEMROOT%\System32\OneDriveSetup.exe"
set x64="%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe"
echo Closing the OneDrive process.
echo.
taskkill /f /im OneDrive.exe > NUL 2>&1
ping 127.0.0.1 -n 5 > NUL 2>&1
echo Uninstalling OneDrive…
echo.
if exist %x64% ( %x64% /uninstall )
...
