; ================================================================
;  Inno Setup Script — نظام إدارة الصالة الرياضية
;  الإصدار: 1.0.0
;  المطور: Abd Elhamed
; ================================================================

#define AppName      "نظام إدارة الصالة"
#define AppNameEn    "GymSystem"
#define AppVersion   "1.0.0"
#define AppPublisher "Abd Elhamed"
#define AppExeName   "gym_system.exe"
#define AppBuildDir  "..\..\..\build\windows\x64\runner\Release"
#define AppIconFile  "..\runner\resources\app_icon.ico"

[Setup]
; معلومات التطبيق الأساسية
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/abdelhamedrefat
AppSupportURL=mailto:abdelhamedrefat@gmail.com

; مجلد التثبيت الافتراضي
DefaultDirName={autopf}\{#AppNameEn}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes

; الأيقونة
SetupIconFile={#AppIconFile}
UninstallDisplayIcon={app}\{#AppExeName}

; ملف الـ Installer الناتج
OutputDir=.\Output
OutputBaseFilename=GymSystem_Setup_v{#AppVersion}

; الضغط
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes

; صلاحيات التثبيت — يتثبت للمستخدم الحالي بدون حاجة admin
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; إعدادات الشاشة
WizardStyle=modern
WizardSizePercent=120
WizardResizable=yes

; اللغة والترميز
; Windows Arabic support
ShowLanguageDialog=no

; يحتاج Windows 10 أو أحدث
MinVersion=10.0

[Languages]
Name: "arabic"; MessagesFile: "compiler:Default.isl"; LanguageName: Arabic
Name: "english"; MessagesFile: "compiler:Default.isl"; LanguageName: English

[Tasks]
Name: "desktopicon"; Description: "إنشاء أيقونة على سطح المكتب"; GroupDescription: "أيقونات إضافية:"; Flags: unchecked
Name: "startuprun";  Description: "تشغيل البرنامج عند بدء تشغيل ويندوز"; GroupDescription: "خيارات التشغيل:"; Flags: unchecked

[Files]
; ─── الملف التنفيذي الرئيسي ───────────────────────────────
Source: "{#AppBuildDir}\{#AppExeName}";     DestDir: "{app}"; Flags: ignoreversion

; ─── مكتبات Flutter الأساسية ──────────────────────────────
Source: "{#AppBuildDir}\flutter_windows.dll";  DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppBuildDir}\*.dll";                DestDir: "{app}"; Flags: ignoreversion recursesubdirs

; ─── ملفات الـ Assets ─────────────────────────────────────
Source: "{#AppBuildDir}\data\*";               DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; أيقونة قائمة ابدأ
Name: "{group}\{#AppName}";           Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"
Name: "{group}\إلغاء تثبيت {#AppName}"; Filename: "{uninstallexe}"

; أيقونة سطح المكتب (اختيارية)
Name: "{autodesktop}\{#AppName}";     Filename: "{app}\{#AppExeName}"; IconFilename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Registry]
; تسجيل التطبيق في ويندوز
Root: HKCU; Subkey: "Software\{#AppPublisher}\{#AppNameEn}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\{#AppPublisher}\{#AppNameEn}"; ValueType: string; ValueName: "Version"; ValueData: "{#AppVersion}"; Flags: uninsdeletevalue

; تشغيل عند الإقلاع (اختياري)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppNameEn}"; ValueData: """{app}\{#AppExeName}"""; Flags: uninsdeletevalue; Tasks: startuprun

[Run]
; تشغيل البرنامج بعد اكتمال التثبيت
Filename: "{app}\{#AppExeName}"; Description: "تشغيل {#AppName} الآن"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; تنظيف عند إلغاء التثبيت
Filename: "taskkill.exe"; Parameters: "/F /IM {#AppExeName}"; Flags: runhidden; RunOnceId: "KillApp"

[Code]
// ─────────────────────────────────────────────────────────────
// التحقق من متطلبات ويندوز قبل التثبيت
// ─────────────────────────────────────────────────────────────
function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  // نتطلب Windows 10 (Build 10240) أو أحدث
  if (Version.Major < 10) then
  begin
    MsgBox('هذا التطبيق يتطلب Windows 10 أو أحدث.'#13#10'يرجى تحديث نظام التشغيل.', mbError, MB_OK);
    Result := False;
  end else
    Result := True;
end;

// ─────────────────────────────────────────────────────────────
// إغلاق البرنامج إن كان مفتوحًا قبل التحديث
// ─────────────────────────────────────────────────────────────
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  // محاولة إغلاق البرنامج إن كان يعمل
  Exec('taskkill.exe', '/F /IM {#AppExeName}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := '';
end;
