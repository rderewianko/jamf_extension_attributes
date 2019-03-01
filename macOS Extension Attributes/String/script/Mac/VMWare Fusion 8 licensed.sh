#!/bin/sh

if [ -e "/Library/Preferences/VMware Fusion/license-fusion-80-e3-201505" ]; then
	echo "<result>Yes</result>"
else
	echo "<result>No</result>"
fi
