#!/bin/bash

result="`dscl /Search -read / | grep "/Active Directory/" | sort -u`"
if [ -z "$result" ]; then
echo "Not Bound"
else
echo "<result>$result</result>"
fi
exit 0
