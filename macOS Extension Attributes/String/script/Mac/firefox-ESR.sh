#!/usr/bin/env bash

################################################################################
#Script is designed to return the 'version number' of Mozilla Firefox ESR.     # 
#Locates the installed version of Mozilla Firefox ESR                          #
#before returning 'version number' or 'not installed'                          #
################################################################################
RESULT="Not Installed"

for i in /Applications/Firefox*.app; do
  /usr/bin/grep mozilla-esr "$i"/Contents/Resources/application.ini
  if [[ $? -eq 0 ]]; then
  	RESULT=$(/usr/bin/defaults read "$i"/Contents/Info.plist CFBundleShortVersionString)
  fi
done
/bin/echo "<result>$RESULT</result>"
