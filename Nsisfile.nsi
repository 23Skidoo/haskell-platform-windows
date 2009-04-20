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
  Var START_MENU_FOLDER

;--------------------------------
;Callbacks

Function .onInit
  SetShellVarContext all
  StrCpy $SYSTEM_DRIVE $WINDIR 2
  StrCpy $INSTDIR "$SYSTEM_DRIVE\ghc"
  StrCpy $PLATFORMDIR "$PROGRAMFILES\Haskell"
  StrCpy $START_MENU_FOLDER "GHC"
FunctionEnd

Function un.onInit
  SetShellVarContext all
FunctionEnd

;--------------------------------
;General settings

  ;Name and file
  Name "Haskell Platform ${PLATFORM_VERSION}"
  OutFile "HaskellPlatform-${PLATFORM_VERSION}-setup.exe"

  ;Icon
  !Define MUI_ICON "installer.ico"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME

  ; TODO: fix text messages
  !Define MUI_DIRECTORYPAGE_TEXT_TOP "GHC directory"
  !insertmacro MUI_PAGE_DIRECTORY

  !Define MUI_DIRECTORYPAGE_TEXT_TOP "Haskell Platform directory"
  !Define MUI_DIRECTORYPAGE_VARIABLE $PLATFORMDIR
  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
  !Define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
  !Define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Haskell\GHC\ghc-${GHC_VERSION}"
  !Define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !insertmacro MUI_PAGE_STARTMENU StartMenuPage $START_MENU_FOLDER
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
  File /r ghc\*

  SetOutPath "$PLATFORMDIR"
  File /r extralibs\*

  ; Set registry keys
  WriteRegStr HKCU "Software\Haskell\GHC\ghc-${GHC_VERSION}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Haskell\GHC" "InstallDir" "$INSTDIR"

  ; Set associations
  WriteRegStr HKCR ".hs" "" "ghc_haskell"
  WriteRegStr HKCR ".lhs" "" "ghc_haskell"
  WriteRegStr HKCR "ghc_haskell" "" "Haskell Source File"
  WriteRegStr HKCR "ghc_haskell\DefaultIcon" "" "$INSTDIR\icons\hsicon.ico"
  WriteRegStr HKCR "ghc_haskell\shell\open\command" "" '"$INSTDIR\bin\ghci.exe" "%1"'

  ; Add start menu shortcuts

  !insertmacro MUI_STARTMENU_WRITE_BEGIN StartMenuPage

    ;Create shortcuts
    CreateDirectory "$SMPROGRAMS\$START_MENU_FOLDER"
    CreateDirectory "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}"
    CreateShortCut \
    "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Documentation.lnk" \
     "$INSTDIR\doc\index.html"
    CreateShortCut \
    "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Flag Reference.lnk" \
    "$INSTDIR\doc\users_guide\flag-reference.html"
    CreateShortCut \
    "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Library Documentation.lnk" \
    "$INSTDIR\doc\libraries\index.html"
    CreateShortCut "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHCi.lnk" "$INSTDIR\bin\ghci.exe"

  !insertmacro MUI_STARTMENU_WRITE_END

  ; Add uninstall information to Add/Remove Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "DisplayName" "Haskell Platform ${PLATFORM_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "Publisher" "Haskell.org"

  ; TODO: Modify $INSTDIR\package.conf to point to $PLATFORM_DIR

  ; TODO: Update PATH

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...

  Delete "$INSTDIR\Uninstall.exe"

  ; TODO: Uninstall only installed files
  ; TOLOOKAT: http://nsis.sourceforge.net/Advanced_Uninstall_Log_NSIS_Header
  RMDir /r "$INSTDIR"
  RMDir /r "$PLATFORMDIR"

  ; Delete start menu shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER StartMenuPage $START_MENU_FOLDER

  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Documentation.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Flag Reference.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Library Documentation.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHCi.lnk"
  RMDir "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}"
  RMDir "$SMPROGRAMS\$START_MENU_FOLDER\"

  ; Delete registry keys
  DeleteRegKey HKCR ".hs"
  DeleteRegKey HKCR ".lhs"
  DeleteRegKey HKCR "ghc_haskell"
  DeleteRegKey HKCU "Software\Haskell\GHC"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}"

SectionEnd
