#!/bin/bash

result="`dscl /Search -read / | grep "/LDAPv3/" | sort -u`"
if [ -z "$result" ]; then
echo "Not Bound"
else
echo "<result>$result</result>"
fi
exit 0
