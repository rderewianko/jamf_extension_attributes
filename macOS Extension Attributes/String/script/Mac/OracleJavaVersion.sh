#!/bin/bash
JavaVersion=""

if [ -f "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist" ]; then
    JavaVersion=$(defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist" CFBundleVersion)
fi

echo "<result>$JavaVersion</result>"

exit 0
