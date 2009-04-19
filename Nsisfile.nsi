;NSIS Modern User Interface
;Welcome/Finish Page Example Script
;Written by Joost Verburg

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;Defines

  !Define GHC_VERSION "6.10.2"
  !Define PLATFORM_VERSION "2009.0.0"

;--------------------------------
;Variables

  Var PLATFORMDIR
  Var SYSTEM_DRIVE

;--------------------------------
;Init callback

Function .onInit
  StrCpy $SYSTEM_DRIVE $WINDIR 2
  StrCpy $INSTDIR "$SYSTEM_DRIVE\ghc"
  StrCpy $PLATFORMDIR "$PROGRAMFILES\Haskell"
FunctionEnd

;--------------------------------
;General settings

  ;Name and file
  Name "Haskell Platform ${PLATFORM_VERSION}"
  OutFile "HaskellPlatform-${PLATFORM_VERSION}-setup.exe"

  ;Icon
  !Define MUI_ICON "installer.ico"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME

  !Define MUI_DIRECTORYPAGE_TEXT_TOP "GHC directory"
  !insertmacro MUI_PAGE_DIRECTORY

  !Define MUI_DIRECTORYPAGE_TEXT_TOP "Haskell Platform directory"
  !Define MUI_DIRECTORYPAGE_VARIABLE $PLATFORMDIR
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Main" SecMain

  SetOutPath "$INSTDIR"

  ;ADD YOUR OWN FILES HERE...

  ;Store installation folder
  ;WriteRegStr HKCU "Software\Modern UI Test" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\Modern UI Test"

SectionEnd
