#!/bin/sh

if [ -e "/Library/Fonts/Gotham-Bold.otf" ]; then
	echo "<result>Yes</result>"
elif [ -e "$HOME/Library/Fonts/Gotham-Bold.otf" ]; then
    echo "<result>Yes</result>"
elif [ -e "System/Library/Fonts/Gotham-Bold.otf" ]; then
    echo "<result>Yes</result>"
else
	echo "<result>No</result>"
fi
