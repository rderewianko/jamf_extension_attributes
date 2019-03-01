#!/bin/sh

version="Unknown"

if [ -e "/Applications/Microsoft Word.app" ]; then
	version=`defaults read /Applications/Microsoft\ Word.app/Contents/Info CFBundleShortVersionString | cut -c 1-5`
elif [ -e "/Applications/Microsoft Office 2011/Microsoft Word.app" ]; then
	version="14"
fi

echo "<result>$version</result>"
