#!/bin/bash

#Get username and password attributes from the JSS#
#stylesheet=$(mktemp -t "CreateAccount")
#echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" >> $stylesheet
#echo "<xsl:stylesheet version=\"1.0\"" >> $stylesheet
#echo "xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">" >> $stylesheet
#echo "<xsl:output method=\"text\"/>" >> $stylesheet
#echo "<xsl:template match=\"/\">" >> $stylesheet
#echo "<xsl:value-of select=\"/computer/location/username\"/>" >> $stylesheet
#echo "</xsl:template>" >> $stylesheet
#echo "</xsl:stylesheet>" >> $stylesheet

#comname=`scutil --get ComputerName`
#url="https://jssurl/JSSResource/computers/name/$comname"
#username=$(curl -ks -H "Accept: application/xml" -u username:password "$url" | xsltproc "$stylesheet" -)
#rm -f "$stylesheet"

file="/System/Library/User Template/English.lproj/Documents/Calvin College Emergency Quick Reference Guide.pdf"
result="Yes"

#if [ $USER = "root" ]; then
#    result="User not logged in at time of check"
#    echo "<result>$result</result>"
#    exit 0
#fi

#if [ $USER != "$username" ]; then
#    result="Username does not match JSS"
#    echo "<result>$result</result>"
#    exit 0
#fi

#if [ -e $file ]; then
#    result="Yes"
#fi

if [ ! -e $file ]; then
    result="No"
fi

echo "<result>$result</result>"
