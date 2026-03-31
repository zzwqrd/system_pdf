@echo off
chcp 65001 > nul
title بناء نظام إدارة الصالة - Windows Installer

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║        بناء تطبيق نظام إدارة الصالة لـ Windows         ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

:: ─── التحقق من Flutter ───────────────────────────────────────
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [خطأ] Flutter غير موجود في PATH.
    echo يرجى تثبيت Flutter من: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

:: ─── الذهاب لمجلد المشروع ────────────────────────────────────
cd /d "%~dp0"
echo [✓] مجلد المشروع: %CD%

:: ─── تحديث الحزم ─────────────────────────────────────────────
echo.
echo [1/5] جلب حزم Dart/Flutter...
call flutter pub get
if %errorlevel% neq 0 (
    echo [خطأ] فشل في جلب الحزم
    pause
    exit /b 1
)
echo [✓] تم جلب الحزم بنجاح

:: ─── توليد الكود ─────────────────────────────────────────────
echo.
echo [2/5] توليد الكود التلقائي (build_runner)...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo [تحذير] فشل build_runner - سنكمل بدونه
)

:: ─── بناء Windows Release ────────────────────────────────────
echo.
echo [3/5] بناء نسخة Windows Release...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo [خطأ] فشل في بناء التطبيق
    pause
    exit /b 1
)
echo [✓] تم بناء التطبيق بنجاح

:: ─── التحقق من مجلد البناء ───────────────────────────────────
set BUILD_DIR=build\windows\x64\runner\Release
if not exist "%BUILD_DIR%\gym_system.exe" (
    echo [خطأ] لم يُعثر على الملف التنفيذي في: %BUILD_DIR%
    pause
    exit /b 1
)
echo [✓] الملف التنفيذي موجود: %BUILD_DIR%\gym_system.exe

:: ─── إنشاء مجلد الـ Installer ───────────────────────────────
echo.
echo [4/5] إعداد مجلد الـ Installer...
if not exist "windows\installer\Output" mkdir "windows\installer\Output"

:: ─── بناء Installer بـ Inno Setup ──────────────────────────
echo.
echo [5/5] بناء ملف الـ Installer...

:: البحث عن Inno Setup
set INNO_PATH=
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set INNO_PATH=C:\Program Files\Inno Setup 6\ISCC.exe
) else (
    echo [تحذير] Inno Setup غير مثبت.
    echo يرجى تحميله من: https://jrsoftware.org/isdl.php
    echo.
    echo تم بناء التطبيق بنجاح في المجلد:
    echo   %BUILD_DIR%
    echo.
    echo يمكنك توزيع هذا المجلد مباشرة كـ Portable Version
    goto :BUILD_SUCCESS
)

:: تشغيل Inno Setup
"%INNO_PATH%" "windows\installer\setup.iss"
if %errorlevel% neq 0 (
    echo [خطأ] فشل في بناء ملف الـ Installer
    pause
    exit /b 1
)

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                    تم البناء بنجاح! ✓                   ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║  ملف الـ Installer:                                      ║
echo ║    windows\installer\Output\GymSystem_Setup_v1.0.0.exe  ║
echo ╚══════════════════════════════════════════════════════════╝
goto :END

:BUILD_SUCCESS
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║                  تم بناء التطبيق! ✓                     ║
echo ╠══════════════════════════════════════════════════════════╣
echo ║  مجلد التطبيق الجاهز للتوزيع:                          ║
echo ║    build\windows\x64\runner\Release\                    ║
echo ╚══════════════════════════════════════════════════════════╝

:END
echo.
pause
