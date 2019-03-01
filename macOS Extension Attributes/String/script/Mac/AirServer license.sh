#!/bin/sh

if [ -f "/Library/Preferences/com.pratikkumar.airserver-mac.plist" ]; then
	result=`defaults read /Library/Preferences/com.pratikkumar.airserver-mac code`
	echo "<result>$result</result>"
else
	echo "<result>Not Installed</result>"
fi
