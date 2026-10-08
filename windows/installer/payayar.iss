; PAYAYAR — Windows installer (Inno Setup)
; Compiled by CI: ISCC.exe windows\installer\payayar.iss
; Produces PAYAYAR-Setup-<version>.exe

#define MyAppName "PAYAYAR"
#define MyAppNameFA "پایا‌یار"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "PAYAYAR"
#define MyAppURL "https://github.com/fbfbdfdffv/payayar"
#define MyAppExeName "payayar.exe"

[Setup]
AppId={{7B3C1F2A-5D4E-4A6B-9C8D-1E2F3A4B5C6D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
VersionInfoVersion={#MyAppVersion}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=PAYAYAR-Setup-{#MyAppVersion}
OutputDir=.
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; نصب برای همان کاربر (بدون نیاز به Administrator)
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#MyAppName} {#MyAppNameFA}
SetupIconFile=
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
