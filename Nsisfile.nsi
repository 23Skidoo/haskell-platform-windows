; Haskell Platform Installer

;--------------------------------
;Includes

  !Include "EnvVarUpdate.nsh"
  !Include "FileFunc.nsh"
  !Include "LogicLib.nsh"
  !Include "MUI2.nsh"
  !Include "WordFunc.nsh"

;--------------------------------
;Defines

  !Define GHC_VERSION "6.10.4"
  !Define PLATFORM_VERSION "2009.2.0.2"
  !Define PRODUCT_DIR_REG_KEY "Software\Haskell\Haskell Platform\${PLATFORM_VERSION}"
  !Define FILES_SOURCE_PATH "files"
  !Define INST_DAT "inst.dat"
  !Define UNINST_DAT "uninst.dat"

;--------------------------------
;Variables

  Var START_MENU_FOLDER

;--------------------------------
;Callbacks

Function .onInit
  SetShellVarContext all
FunctionEnd

Function un.onInit
  SetShellVarContext all
FunctionEnd

;--------------------------------
;General settings

  ;Name and file
  Name "Haskell Platform ${PLATFORM_VERSION}"
  OutFile "HaskellPlatform-${PLATFORM_VERSION}-setup.exe"

  ;Default install dir
  InstallDir "$PROGRAMFILES\Haskell Platform\${PLATFORM_VERSION}"
  InstallDirRegKey HKLM "${PRODUCT_DIR_REG_KEY}" ""

  ;Icon
  !Define MUI_ICON "installer.ico"
  !Define MUI_UNICON "installer.ico"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

  ;Best available compression
  SetCompressor /SOLID lzma

  ;Install types
  InstType "Standard"
  InstType "Just unpack the files"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !Define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_DIRECTORY

  !Define MUI_COMPONENTSPAGE_NODESC
  !insertmacro MUI_PAGE_COMPONENTS

  ;Start Menu Folder Page Configuration
  !Define MUI_PAGE_HEADER_SUBTEXT "Choose a Start Menu folder for the GHC ${GHC_VERSION} shortcuts."
  !Define MUI_STARTMENUPAGE_TEXT_TOP "Select the Start Menu folder in which you would like to create Glasgow Haskell Compiler's shortcuts. You can also enter a name to create a new folder."
  !Define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
  !Define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Haskell\GHC\ghc-${GHC_VERSION}"
  !Define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  !Define MUI_STARTMENUPAGE_DEFAULTFOLDER "Haskell Platform ${PLATFORM_VERSION}"
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

Section "Base components" SecMain

  SectionIn 1 2
  ; Make this section mandatory
  SectionIn RO

  !Include ${INST_DAT}

SectionEnd

SectionGroup "Update system settings" SecGr

Section "Associate .hs/.lhs files with GHCi" SecAssoc

  SectionIn 1

  ; File associations
  WriteRegStr HKCR ".hs" "" "ghc_haskell"
  WriteRegStr HKCR ".lhs" "" "ghc_haskell"
  WriteRegStr HKCR "ghc_haskell" "" "Haskell Source File"
  WriteRegStr HKCR "ghc_haskell\DefaultIcon" "" "$INSTDIR\icons\hsicon.ico"
  WriteRegStr HKCR "ghc_haskell\shell\open\command" "" '"$INSTDIR\bin\ghci.exe" "%1"'

  ;Remember that we registered associations
  WriteRegDWORD HKLM "${PRODUCT_DIR_REG_KEY}" Assocs 0x1

SectionEnd

Section "Update the PATH environment variable" SecPath

  SectionIn 1

  ; Update PATH
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\bin"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\extralibs\bin"
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$PROGRAMFILES\Haskell\bin"

SectionEnd

Section "Store GHC's location in registry"

  SectionIn 1

  ; (copied from the GHC installer).
  WriteRegStr HKCU "Software\Haskell\GHC\ghc-${GHC_VERSION}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Haskell\GHC" "InstallDir" "$INSTDIR"

SectionEnd

Section "Create uninstaller" SecAddRem

  SectionIn 1

  ; Add uninstall information to Add/Remove Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "DisplayName" "Haskell Platform ${PLATFORM_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "DisplayIcon" "$INSTDIR\icons\installer.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}" \
  "Publisher" "Haskell.org"

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; This is needed for uninstaller to work
  WriteRegStr HKLM "${PRODUCT_DIR_REG_KEY}" "" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REG_KEY}" "InstallDir" "$INSTDIR"

SectionEnd

SectionGroupEnd

Section "-StartMenu" StartMenu
  SectionIn 1 2

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

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  !Include ${UNINST_DAT}

  Delete "$INSTDIR\Uninstall.exe"
  RMDir $INSTDIR

  ;Since we install to '$PF\Haskell Platform\$PLATFORM_VERSION', we
  ;should also try to delete '$PF\Haskell Platform' if it is empty.
  ${GetParent} $INSTDIR $R0
  RMDir $R0

  ; Delete start menu shortcuts
  !insertmacro MUI_STARTMENU_GETFOLDER StartMenuPage $START_MENU_FOLDER

  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Documentation.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Flag Reference.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHC Library Documentation.lnk"
  Delete "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}\GHCi.lnk"
  RMDir "$SMPROGRAMS\$START_MENU_FOLDER\${GHC_VERSION}"
  RMDir "$SMPROGRAMS\$START_MENU_FOLDER\"

  ; Delete registry keys
  ReadRegDWORD $0 HKLM "${PRODUCT_DIR_REG_KEY}" Assocs

  ${If} $0 = 0x1
    DeleteRegKey HKCR ".hs"
    DeleteRegKey HKCR ".lhs"
    DeleteRegKey HKCR "ghc_haskell"
  ${EndIf}

  DeleteRegKey HKCU "Software\Haskell\GHC\ghc-${GHC_VERSION}"
  DeleteRegKey HKCU "Software\Haskell\GHC"
  DeleteRegKey HKLM "${PRODUCT_DIR_REG_KEY}"
  DeleteRegKey /IfEmpty HKCU Software\Haskell
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HaskellPlatform-${PLATFORM_VERSION}"

  ; Update PATH
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\extralibs\bin"

SectionEnd
