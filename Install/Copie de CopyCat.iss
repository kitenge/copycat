; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define protected
#ifndef SetupName
  #define SetupName "CopyCat"
  #define README_FILE "..\License\Readme.txt"
  #define LICENSE_FILE "..\License\License.txt"
#endif
#define VERSION "1.03.0"

[Setup]
AppName=Microtec CopyCat
#ifdef Trial
AppVerName=CopyCat Evaluation v.{#VERSION}
#else
AppVerName=CopyCat v.{#VERSION}
#endif
AppPublisher=Microtec Communications
AppPublisherURL=http://www.microtec.fr
AppSupportURL=http://www.microtec.fr
AppUpdatesURL=http://www.microtec.fr
DefaultDirName={pf}\CopyCat\
DisableDirPage=false
DefaultGroupName=Microtec CopyCat
VersionInfoVersion={#VERSION}
OutputBaseFilename={#SetupName}
InternalCompressLevel=max
VersionInfoCompany=Microtec Communications
ShowLanguageDialog=yes
WizardImageBackColor=clSilver
WizardSmallImageFile=Microtec2.bmp
WindowVisible=false
BackColor=clNavy
BackColor2=$ee928a
WizardImageStretch=true
AppCopyright=Microtec Communications
WizardImageFile=Wizard.bmp
BackColorDirection=toptobottom
OutputDir=.
SolidCompression=true
#ifdef UserPassword
Password={#UserPassword}
Encryption=true
#endif
AppVersion={#VERSION}
AllowNoIcons=true
AlwaysShowComponentsList=true
InfoBeforeFile={#README_FILE}
InfoAfterFile=..\License\Install.txt
LicenseFile={#LICENSE_FILE}
VersionInfoCopyright=Microtec Informatique
UserInfoPage=true

[Tasks]

[Files]
#define i 1

#sub CheckVersions
#undef public BCB
#undef public Delphi
#undef public BDS
#if i == 1
  #define public BCB
  #define public DIR "BCB5"
  #define public RegDir "Software\Borland\C++Builder\5.0"
  #define public suffixe "C5";
#elif i == 2
  #define public BCB
  #define public DIR "BCB6"
  #define public RegDir "Software\Borland\C++Builder\6.0"
  #define public suffixe "C6";
#elif i == 3
  #define public Delphi
  #define public DIR "D6"
  #define public RegDir "Software\Borland\Delphi\6.0"
  #define public suffixe "D6";
#elif i == 4
  #define public Delphi
  #define public DIR "D7"
  #define public RegDir "Software\Borland\Delphi\7.0"
  #define public suffixe "D7";
#elif i == 5
  #define public BDS
  #define public DIR "D2005"
  #define public RegDir "Software\Borland\BDS\3.0"
  #define public suffixe "2005";
#else
  #define public BDS
  #define public DIR "D2006"
  #define public RegDir "Software\Borland\BDS\4.0"
  #define public suffixe "2006";
#endif

#ifndef BDS
  #define public ProjectDir "{code:GetRootDir|" + RegDir + "}\Projects"
#else
  #define public ProjectDir "{userdocs}\Borland Studio Projects"
#endif

#ifdef Trial
  #define public SourceDir "Trial\" + DIR
#else
  #define public SourceDir DIR
#endif
#endsub

#sub AddSource
#expr CheckVersions

#ifdef FullSource
Source: ..\Cc*; DestDir: {app}\{#DIR}; Components: {#DIR}; Excludes: *.bak, *.dtx, *.~*, *.dcu, *.hpp, *.obj, CcTrial.*
Source: ..\CopyCat_{#suffixe}.*; DestDir: {app}\{#DIR}; Components: {#DIR}; Excludes: *.~*, *.tds
#endif

Source: ..\FIBPlus\*.pas; DestDir: {app}\{#DIR}\FIBPlus; Components: {#DIR}\CopyCatFIB
Source: ..\FIBPlus\CopyCatFIB_{#suffixe}.*; DestDir: {app}\{#DIR}\FIBPlus; Components: {#DIR}\CopyCatFIB; Excludes: *.~*, *.tds, *.bpl, *.bpi, *.lib, *.obj, *.map
Source: ..\IBX\*.pas; DestDir: {app}\{#DIR}\IBX; Components: {#DIR}\CopyCatIBX
Source: ..\IBX\CopyCatIBX_{#suffixe}.*; DestDir: {app}\{#DIR}\IBX; Components: {#DIR}\CopyCatIBX; Excludes: *.~*, *.tds, *.bpl, *.bpi, *.lib, *.obj, *.map
Source: ..\UIB\*.pas; DestDir: {app}\{#DIR}\UIB; Components: {#DIR}\CopyCatUIB
Source: ..\UIB\CopyCatUIB_{#suffixe}.*; DestDir: {app}\{#DIR}\UIB; Components: {#DIR}\CopyCatUIB; Excludes: *.~*, *.tds, *.bpl, *.bpi, *.lib, *.obj, *.map
Source: ..\IBO\*.pas; DestDir: {app}\{#DIR}\IBO; Components: {#DIR}\CopyCatIBO
Source: ..\IBO\CopyCatIBO_{#suffixe}.*; DestDir: {app}\{#DIR}\IBO; Components: {#DIR}\CopyCatIBO; Excludes: *.~*, *.tds, *.bpl, *.bpi, *.lib, *.obj, *.map

Source: ..\{#SourceDir}\CopyCat_*.bpl; DestDir: {#ProjectDir}\Bpl; Components: {#DIR}
Source: ..\{#SourceDir}\CopyCat_*.bpl; DestDir: {sys}; Components: {#DIR}

#ifdef Trial
Source: ..\CcTrial.dfm; DestDir: {app}\{#DIR}; Components: {#DIR}
Source: ..\{#SourceDir}\CcTrial.dcu; DestDir: {app}\{#DIR}; Components: {#DIR}
#endif
Source: ..\{#SourceDir}\Cc*; DestDir: {app}\{#DIR}; Components: {#DIR}; Excludes: CcTrial.*

#ifdef BCB
Source: ..\{#SourceDir}\CopyCat_*.bpi; DestDir: {#ProjectDir}\Lib; Components: {#DIR}
Source: ..\{#SourceDir}\CopyCat_*.lib; DestDir: {#ProjectDir}\Lib; Components: {#DIR}
#else
Source: ..\{#SourceDir}\CopyCat_*.dcp; DestDir: {#ProjectDir}\Bpl; Components: {#DIR}
#endif

Source: ..\Examples\*; DestDir: {app}\Examples; Excludes: *.exe,*.tds,*.map, *.~*, *.elf, *.obj, *.cpp, *.h; Components: Examples; Languages: ; Flags: recursesubdirs
#endsub

#for {i=1;i<=6;i++} AddSource

Source: {#LICENSE_FILE}; DestDir: {app}; DestName: License.txt
Source: {#README_FILE}; DestDir: {app}; DestName: Readme.txt
Source: ..\License\Install.txt; DestDir: {app}

Source: ..\Doc\CopyCat.als; DestDir: {app}\Doc; Components: Doc
Source: ..\Doc\CopyCat.cnt; DestDir: {app}\Doc; Components: Doc
Source: ..\Doc\CopyCat.hlp; DestDir: {app}\Doc; Components: Doc
[Dirs]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
[Icons]
Name: {group}\{cm:UninstallProgram, Microtec CopyCat}; Filename: {uninstallexe}

[Run]

[LangOptions]
CopyrightFontName=Arial
CopyrightFontSize=10

[Languages]
Name: Default; MessagesFile: compiler:Default.isl
[_ISTool]
UseAbsolutePaths=false
[Registry]

#sub AddReg
#expr CheckVersions
Root: HKCU; Subkey: {#RegDir}\Known packages; ValueType: string; ValueName: {#ProjectDir}\Bpl\CopyCat_{#Suffixe}.bpl; ValueData: CopyCat v.{#VERSION}; Components: {#DIR}
Root: HKCU; Subkey: {#RegDir}\Library; ValueType: string; ValueName: Search Path; ValueData: "{code:GetSearchPath|{#RegDir}};{app}\{#DIR}\FIBPlus"; Components: {#DIR}\CopyCatFIB; Check: CheckSearchPath('{#RegDir}', ExpandConstant('{app}\{#DIR}\FIBPlus'))
Root: HKCU; Subkey: {#RegDir}\Library; ValueType: string; ValueName: Search Path; ValueData: "{code:GetSearchPath|{#RegDir}};{app}\{#DIR}\IBX"; Components: {#DIR}\CopyCatIBX; Check: CheckSearchPath('{#RegDir}', ExpandConstant('{app}\{#DIR}\IBX'))
Root: HKCU; Subkey: {#RegDir}\Library; ValueType: string; ValueName: Search Path; ValueData: "{code:GetSearchPath|{#RegDir}};{app}\{#DIR}\IBO"; Components: {#DIR}\CopyCatIBO; Check: CheckSearchPath('{#RegDir}', ExpandConstant('{app}\{#DIR}\IBO'))
Root: HKCU; Subkey: {#RegDir}\Library; ValueType: string; ValueName: Search Path; ValueData: "{code:GetSearchPath|{#RegDir}};{app}\{#DIR}\UIB"; Components: {#DIR}\CopyCatUIB; Check: CheckSearchPath('{#RegDir}', ExpandConstant('{app}\{#DIR}\UIB'))
#endsub
#for {i=1;i<=6;i++} AddReg

[Components]
Name: BCB5; Description: C++Builder 5; Types: compact full custom; Check: BCB5Installed
Name: BCB5\CopyCatIBX; Description: IBX provider for BCB 5; Types: Custom Full compact
Name: BCB5\CopyCatFIB; Description: FIBPlus provider for BCB 5; Types: Full
Name: BCB5\CopyCatUIB; Description: UIB provider for BCB 5; Types: Full
Name: BCB5\CopyCatIBO; Description: IBO provider for BCB 5; Types: Full

Name: BCB6; Description: C++Builder 6; Types: compact full custom; Check: BCB6Installed
Name: BCB6\CopyCatIBX; Description: IBX provider for BCB 6; Types: Custom Full compact
Name: BCB6\CopyCatFIB; Description: FIBPlus provider for BCB 6; Types: Full
Name: BCB6\CopyCatUIB; Description: UIB provider for BCB 6; Types: Full
Name: BCB6\CopyCatIBO; Description: IBO provider for BCB 6; Types: Full

Name: D6; Description: Delphi 6; Types: full custom compact; Check: D6Installed
Name: D6\CopyCatIBX; Description: IBX provider for Delphi 6; Types: Custom Full compact
Name: D6\CopyCatFIB; Description: FIBPlus provider for Delphi 6; Types: Full
Name: D6\CopyCatUIB; Description: UIB provider for Delphi 6; Types: Full
Name: D6\CopyCatIBO; Description: IBO provider for Delphi 6; Types: Full

Name: D7; Description: Delphi 7; Types: full custom compact; Check: D7Installed
Name: D7\CopyCatIBX; Description: IBX provider for Delphi 7; Types: Custom Full compact
Name: D7\CopyCatFIB; Description: FIBPlus provider for Delphi 7; Types: Full
Name: D7\CopyCatUIB; Description: UIB provider for Delphi 7; Types: Full
Name: D7\CopyCatIBO; Description: IBO provider for Delphi 7; Types: Full

Name: D2005; Description: Delphi 2005; Types: full custom compact; Check: D2005Installed
Name: D2005\CopyCatIBX; Description: IBX provider for Delphi 2005; Types: Custom Full compact
Name: D2005\CopyCatFIB; Description: FIBPlus provider for Delphi 2005; Types: Full
Name: D2005\CopyCatUIB; Description: UIB provider for Delphi 2005; Types: Full
Name: D2005\CopyCatIBO; Description: IBO provider for Delphi 2005; Types: Full

Name: D2006; Description: Delphi 2006; Types: full custom compact; Check: D2006Installed
Name: D2006\CopyCatIBX; Description: IBX provider for Delphi 2006; Types: Custom Full compact
Name: D2006\CopyCatFIB; Description: FIBPlus provider for Delphi 2006; Types: Full
Name: D2006\CopyCatUIB; Description: UIB provider for Delphi 2006; Types: Full
Name: D2006\CopyCatIBO; Description: IBO provider for Delphi 2006; Types: Full

Name: Doc; Description: Documentation; Types: full
Name: Examples; Description: Example projects; Types: full
[Code]
function GetSearchPath(RegDir:String):String;
begin
  RegQueryStringValue (HKCU, RegDir + '\Library', 'Search Path', Result);
end;

function GetRootDir(RegDir:String):String;
begin
  RegQueryStringValue (HKCU, RegDir, 'RootDir', Result);
  if Result = '' then
    RegQueryStringValue (HKLM, RegDir, 'RootDir', Result);
end;

function GetProjectDir(RegDir, DefaultDir:String):String;
begin
  RegQueryStringValue(HKCU, RegDir, 'RootDir', Result);
  Result := Result + '\Projects';
  if not FileExists(Result) then
    Result := DefaultDir;
end;

function CheckSearchPath(RegDir, Dir:String):Boolean;
begin
  Result := (Pos(Dir, GetSearchPath(RegDir)) = 0);
end;

function D6Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\Delphi\6.0');
end;

function D7Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\Delphi\7.0');
end;

function D2005Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\BDS\3.0');
end;

function D2006Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\BDS\4.0');
end;

function BCB5Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\C++Builder\5.0');
end;

function BCB6Installed:Boolean;
begin
  Result := RegKeyExists(HKCU, 'Software\Borland\C++Builder\6.0');
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
#sub DelReg
#expr CheckVersions
  RegDeleteValue(HKCU, '{#RegDir}\Known packages', ExpandConstant('{#ProjectDir}\Bpl\CopyCat_{#Suffixe}.bpl'));
#endsub
#for {i=1;i<=6;i++} DelReg
  end;
end;
