#!/bin/bash
SilverlightVersion=""
if [ -f /Library/Internet\ Plug-Ins/Silverlight.plugin/Contents/Info.plist ]
	then
		SilverlightVersion=$(defaults read /Library/Internet\ Plug-Ins/Silverlight.plugin/Contents/Info.plist CFBundleShortVersionString)
fi

echo "<result>$SilverlightVersion</result>"

exit 0
