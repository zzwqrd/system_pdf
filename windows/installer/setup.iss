; ================================================================
;  Inno Setup Script — نظام إدارة الصالة الرياضية
;  الإصدار: 1.0.0
;  المطور: Abd Elhamed
;  الميزات: Admin كامل + VC++ تلقائي + تثبيت سريع
; ================================================================

#define AppName      "نظام إدارة الصالة"
#define AppNameEn    "GymSystem"
#define AppVersion   "1.0.0"
#define AppPublisher "Abd Elhamed"
#define AppExeName   "gym_system.exe"
#define AppBuildDir  "..\..\build\windows\x64\runner\Release"
#define AppIconFile  "..\runner\resources\app_icon.ico"
#define VCRedistFile "VC_redist.x64.exe"

[Setup]
; ─── معلومات التطبيق ──────────────────────────────────────────
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/abdelhamedrefat
AppSupportURL=mailto:abdelhamedrefat@gmail.com

; ─── مجلد التثبيت ────────────────────────────────────────────
DefaultDirName={autopf}\{#AppNameEn}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes

; ─── الأيقونة ─────────────────────────────────────────────────
SetupIconFile={#AppIconFile}
UninstallDisplayIcon={app}\{#AppExeName}

; ─── ملف الـ Installer الناتج ────────────────────────────────
OutputDir=.\Output
OutputBaseFilename=GymSystem_Setup_v{#AppVersion}

; ─── الضغط: أقصى ضغط مع سرعة فك ضغط عالية ──────────────────
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMANumBlockThreads=4

; ─── الصلاحيات: Admin إجباري ─────────────────────────────────
;   - يفتح UAC مرة واحدة عند التثبيت فقط
;   - يثبت في Program Files بشكل صحيح
;   - يسجل في HKLM (للكل) بدلاً من HKCU (للمستخدم فقط)
PrivilegesRequired=admin

; ─── إعدادات الشاشة ──────────────────────────────────────────
WizardStyle=modern
WizardSizePercent=120
WizardResizable=no
DisableWelcomePage=no
DisableDirPage=no
DisableReadyPage=no

; ─── لا تحتاج restart بعد التثبيت ────────────────────────────
AlwaysRestart=no
RestartIfNeededByRun=no

; ─── Windows 10 (1809) فأكثر ─────────────────────────────────
MinVersion=10.0.17763

; ─── معلومات Add/Remove Programs ─────────────────────────────
AppContact=abdelhamedrefat@gmail.com
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName}

[Languages]
Name: "arabic";  MessagesFile: "compiler:Default.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "إنشاء أيقونة على سطح المكتب";    GroupDescription: "أيقونات إضافية:"; Flags: checkedonce
Name: "startuprun";  Description: "تشغيل البرنامج عند بدء ويندوز";  GroupDescription: "خيارات التشغيل:"; Flags: unchecked

[Files]
; ─── VC++ Redistributable (يُحمَّل في الـ workflow تلقائياً) ──
Source: "{#VCRedistFile}"; DestDir: "{tmp}"; Flags: deleteafterinstall; Check: NeedsVCRedist

; ─── الملف التنفيذي الرئيسي ───────────────────────────────────
Source: "{#AppBuildDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; ─── جميع الـ DLLs (Flutter + مكتبات) ────────────────────────
Source: "{#AppBuildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

; ─── ملفات الـ Assets والـ Data ───────────────────────────────
Source: "{#AppBuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
; إنشاء مجلد البيانات مع صلاحيات كتابة كاملة لجميع المستخدمين
Name: "{commonappdata}\{#AppNameEn}";        Permissions: everyone-full
Name: "{commonappdata}\{#AppNameEn}\data";   Permissions: everyone-full
Name: "{commonappdata}\{#AppNameEn}\backup"; Permissions: everyone-full
Name: "{app}";                               Permissions: everyone-full

[Icons]
; أيقونة قائمة ابدأ
Name: "{group}\{#AppName}";              Filename: "{app}\{#AppExeName}"
Name: "{group}\إلغاء تثبيت {#AppName}"; Filename: "{uninstallexe}"
; أيقونة سطح المكتب
Name: "{autodesktop}\{#AppName}";        Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Registry]
; ─── تسجيل التطبيق في HKLM (لكل المستخدمين) ─────────────────
Root: HKLM; Subkey: "Software\{#AppPublisher}\{#AppNameEn}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}";                           Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#AppPublisher}\{#AppNameEn}"; ValueType: string; ValueName: "Version";     ValueData: "{#AppVersion}";                   Flags: uninsdeletevalue
Root: HKLM; Subkey: "Software\{#AppPublisher}\{#AppNameEn}"; ValueType: string; ValueName: "DataPath";    ValueData: "{commonappdata}\{#AppNameEn}";    Flags: uninsdeletevalue

; ─── تشغيل عند الإقلاع لكل المستخدمين (اختياري) ──────────────
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppNameEn}"; ValueData: """{app}\{#AppExeName}"""; Flags: uninsdeletevalue; Tasks: startuprun

; ─── السماح للتطبيق بالمرور عبر Windows Firewall ────────────
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"; ValueType: string; ValueName: "{#AppNameEn}-In";  ValueData: "v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|App={app}\{#AppExeName}|Name={#AppName}|";  Flags: uninsdeletevalue
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"; ValueType: string; ValueName: "{#AppNameEn}-Out"; ValueData: "v2.30|Action=Allow|Active=TRUE|Dir=Out|Protocol=6|App={app}\{#AppExeName}|Name={#AppName}|"; Flags: uninsdeletevalue

[Run]
; ─── تثبيت VC++ أولاً لو محتاج ──────────────────────────────
Filename: "{tmp}\{#VCRedistFile}"; Parameters: "/quiet /norestart"; StatusMsg: "جاري تثبيت Microsoft Visual C++ Runtime..."; Check: NeedsVCRedist; Flags: waituntilterminated

; ─── تشغيل البرنامج بعد اكتمال التثبيت ──────────────────────
Filename: "{app}\{#AppExeName}"; Description: "تشغيل {#AppName} الآن"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; إيقاف البرنامج قبل إلغاء التثبيت
Filename: "taskkill.exe"; Parameters: "/F /IM {#AppExeName}"; Flags: runhidden; RunOnceId: "KillApp"

[UninstallDelete]
; حذف ملفات اللوج المؤقتة فقط (وليس قاعدة البيانات)
Type: filesandordirs; Name: "{app}\*.log"

[Code]
// ─────────────────────────────────────────────────────────────
// فحص إصدار ويندوز قبل التثبيت
// ─────────────────────────────────────────────────────────────
function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  if (Version.Major < 10) or ((Version.Major = 10) and (Version.Build < 17763)) then
  begin
    MsgBox(
      'هذا التطبيق يتطلب Windows 10 (إصدار 1809) أو أحدث.' + #13#10 +
      'يرجى تحديث نظام التشغيل ثم إعادة التثبيت.',
      mbError, MB_OK
    );
    Result := False;
  end else
    Result := True;
end;

// ─────────────────────────────────────────────────────────────
// فحص إذا كان VC++ 2015-2022 Redistributable x64 مثبتاً
// إذا كان مثبتاً → تخطي تثبيته (توفير وقت)
// إذا لم يكن → تثبيته تلقائياً بدون أي تدخل
// ─────────────────────────────────────────────────────────────
function NeedsVCRedist(): Boolean;
var
  Installed: Cardinal;
begin
  Result := True;
  // مسار التسجيل الأساسي لـ VC++ 2015-2022 x64
  if RegQueryDWordValue(HKLM,
    'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Installed', Installed) then
  begin
    if Installed = 1 then
    begin
      Result := False;
      Exit;
    end;
  end;
  // مسار بديل (على بعض إصدارات ويندوز)
  if RegQueryDWordValue(HKLM,
    'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Installed', Installed) then
  begin
    if Installed = 1 then
      Result := False;
  end;
end;

// ─────────────────────────────────────────────────────────────
// إغلاق البرنامج إن كان مفتوحاً قبل التحديث
// ─────────────────────────────────────────────────────────────
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  Exec('taskkill.exe', '/F /IM {#AppExeName}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  NeedsRestart := False;
  Result := '';
end;

// ─────────────────────────────────────────────────────────────
// بعد التثبيت: ضبط صلاحيات مجلد البيانات لجميع المستخدمين
// ─────────────────────────────────────────────────────────────
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  DataPath: string;
begin
  if CurStep = ssPostInstall then
  begin
    DataPath := ExpandConstant('{commonappdata}\{#AppNameEn}');
    // S-1-1-0 = Everyone → Full Control (OI)(CI) = للمجلد والمحتوى
    Exec('icacls.exe',
      '"' + DataPath + '" /grant *S-1-1-0:(OI)(CI)F /T /Q',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
