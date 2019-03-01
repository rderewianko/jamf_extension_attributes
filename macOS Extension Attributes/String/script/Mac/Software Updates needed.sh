#!/bin/sh

availableUpdates=`/usr/sbin/softwareupdate -l | grep "*" | sed "s/\*//g" | sed "s/$/,/g" | sed 's/.$//'`

echo "<result> $availableUpdates </result>"
