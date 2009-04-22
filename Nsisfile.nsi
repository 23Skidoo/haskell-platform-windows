;NSIS Modern User Interface
;Welcome/Finish Page Example Script
;Written by Joost Verburg

;--------------------------------
;Includes

  !include "MUI2.nsh"
  !include "EnvVarUpdate.nsh"
  !include "WordFunc.nsh"

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

  ; Best available compression
  SetCompressor /SOLID lzma

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME

  ; TODO: fix text messages
  !Define MUI_PAGE_HEADER_SUBTEXT "Step 1 of 2."
  !Define MUI_DIRECTORYPAGE_TEXT_TOP "Choose the folder in which to install GHC."
  !insertmacro MUI_PAGE_DIRECTORY

  !Define MUI_PAGE_HEADER_SUBTEXT "Step 2 of 2."
  !Define MUI_DIRECTORYPAGE_TEXT_TOP "Choose the folder in which to install extra libraries provided by the Haskell Platform."
  !Define MUI_DIRECTORYPAGE_VARIABLE $PLATFORMDIR
  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
  !Define MUI_PAGE_HEADER_SUBTEXT "Choose a Start Menu folder for the GHC ${GHC_VERSION} shortcuts."
  !Define MUI_STARTMENUPAGE_TEXT_TOP "Select the Start Menu folder in which you would like to create Glasgow Haskell Compiler's shortcuts. You can also enter a name to create a new folder."
  !Define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
  !Define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Haskell\GHC\ghc-${GHC_VERSION}"
  !Define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !Define MUI_STARTMENUPAGE_DEFAULTFOLDER "GHC"
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
  File /r "ghc\*"

  SetOutPath "$PLATFORMDIR"
  File /r "extralibs\*"

  ; Registry keys
  WriteRegStr HKLM "Software\Haskell\HaskellPlatform-${PLATFORM_VERSION}" "GHCInstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\Haskell\HaskellPlatform-${PLATFORM_VERSION}" "PlatformInstallDir" "$PLATFORMDIR"

  StrCpy $INSTDIR "$INSTDIR\ghc-${GHC_VERSION}"
  ; Copied from the GHC installer.
  WriteRegStr HKCU "Software\Haskell\GHC\ghc-${GHC_VERSION}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Haskell\GHC" "InstallDir" "$INSTDIR"

  ; Associations
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
  "DisplayIcon" "$INSTDIR\icons\installer.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "Publisher" "Haskell.org"

  ; Modify $INSTDIR\package.conf to point to $PLATFORMDIR
  ${WordReplace} "$PLATFORMDIR" "\" "\\\\" "+" $R1
  ExecDos::exec '"$INSTDIR\perl.exe" -p -e "s/\@PLATFORMDIR\@/$R1/g" "$INSTDIR\package.conf"' "" "$INSTDIR\package.conf.new"
  Delete "$INSTDIR\package.conf"
  Rename "$INSTDIR\package.conf.new" "$INSTDIR\package.conf"

  ; Update PATH
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\bin"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$PLATFORMDIR\bin"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$PROGRAMFILES\Haskell\bin"

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  Delete "$INSTDIR\Uninstall.exe"

  ; TODO: Uninstall only installed files
  ; TOLOOKAT: http://nsis.sourceforge.net/Advanced_Uninstall_Log_NSIS_Header
  ReadRegStr $0 HKLM "Software\Haskell\HaskellPlatform-${PLATFORM_VERSION}" "GHCInstallDir"
  RMDir /r "$0"
  ReadRegStr $0 HKLM "Software\Haskell\HaskellPlatform-${PLATFORM_VERSION}" "PlatformInstallDir"
  RMDir /r "$0"

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
  DeleteRegKey HKLM "Software\Haskell\HaskellPlatform-${PLATFORM_VERSION}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}"

SectionEnd
