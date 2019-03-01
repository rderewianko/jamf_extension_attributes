#!/bin/sh

SSD=$(diskutil info / | awk '/Solid State/{print $NF}')

if [ $SSD == "Yes" ]; then
    echo "<result>Yes</result>"
else
    echo "<result>No</result>"
fi

exit 0
