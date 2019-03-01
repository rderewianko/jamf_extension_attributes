#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the computer extension attributes stored on a Jamf Pro server then do the following:
#
# 1. Download the extension attribute as XML
# 2. Identify the extension attribute name
# 3. Categorize the downloaded extension attribute
# 4. If it's a macOS or Windows extension attribute and it has a script, extract the script.
# 5. Save the extension attribute to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Computer Extension Attributes: Read

# If you choose to specify a directory to save the downloaded extension attributes into,
# please enter the complete directory path into the ExtensionAttributeDownloadDirectory
# variable below.

ExtensionAttributeDownloadDirectory="$HOME/Desktop/macOS Extension Attributes"

# If the ExtensionAttributeDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$ExtensionAttributeDownloadDirectory" ]]; then
   ExtensionAttributeDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded groups has not been specified."
   echo "Downloaded groups will be stored in $ExtensionAttributeDownloadDirectory."
fi

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The username for an account on the Jamf Pro server with sufficient API privileges
# The password for the account
# The Jamf Pro URL

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url="https://clyde.calvin.edu:8443"	    

# Set the username here if you want it hardcoded.
jamfpro_user="apiuser"

# Set the password here if you want it hardcoded.
jamfpro_password="booimaghost"	

# If you do not want to hardcode API information into the script, you can also store
# these values in a ~/Library/Preferences/com.github.jamfpro-info.plist file.
#
# To create the file and set the values, run the following commands and substitute
# your own values where appropriate:
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the account username in the plist file:
# defaults write com.github.jamfpro-info jamfpro_user account_username_goes_here
#
# To store the account password in the plist file:
# defaults write com.github.jamfpro-info jamfpro_password account_password_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will read in the
# relevant information from the plist file.
PLIST="$HOME/Library/Preferences/com.github.jamfpro-info.plist"

if [[ -r "$PLIST" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read "${PLIST%.*}" jamfpro_url)
     fi

     if [[ -z "$jamfpro_user" ]]; then
          jamfpro_user=$(defaults read "${PLIST%.*}" jamfpro_user)
     fi

     if [[ -z "$jamfpro_password" ]]; then
          jamfpro_password=$(defaults read "${PLIST%.*}" jamfpro_password)
     fi

fi

# If the Jamf Pro URL, the account username or the account password aren't available
# otherwise, you will be prompted to enter the requested URL or account credentials.

if [[ -z "$jamfpro_url" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_user" ]]; then
     read -p "Please enter your Jamf Pro user account : " jamfpro_user
fi

if [[ -z "$jamfpro_password" ]]; then
     read -p "Please enter the password for the $jamfpro_user account: " -s jamfpro_password
fi

echo

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# Remove the trailing slash from the ExtensionAttributeDownloadDirectory variable if needed.
ExtensionAttributeDownloadDirectory=${ExtensionAttributeDownloadDirectory%%/}

DownloadComputerExtensionAttribute(){

	# Download the extension attribute information as raw XML,
	# then format it to be readable.
	ComputerExtensionAttribute=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computerextensionattributes/id/${ID}")
	FormattedComputerExtensionAttribute=$(echo "$ComputerExtensionAttribute" | xmllint --format -)
	
	# Identify and display the extension attribute's name.
	DisplayName=$(echo "$FormattedComputerExtensionAttribute" | xpath "/computer_extension_attribute/name/text()" 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded extension attribute is named: \"$DisplayName\""
	
	# Identify the EA type.
	EAType=$(echo "$FormattedComputerExtensionAttribute" | xpath "/computer_extension_attribute/data_type/text()" 2>/dev/null)
 	echo "\"$DisplayName\" is a \"$EAType\" extension attribute."

	# get the number of input_type nodes. In some cases an EA may contain scripts for macOS and Windows. So if we find
	# more than one input_tpye node, we just use the one for macOS
    EAInputTypeNodeCount=$(echo "$FormattedComputerExtensionAttribute" | xpath "count(/computer_extension_attribute/input_type/type)" 2>/dev/null)
    
    while [[ $EAInputTypeNodeCount -gt 0 ]]; do
        
    	EAInputType=$(echo "$FormattedComputerExtensionAttribute" | xpath "/computer_extension_attribute/input_type[$EAInputTypeNodeCount]/type/text()" 2>/dev/null)
    	FinalAttribute=""
    	FileName=""

		if [[ -n "$EAInputType" ]]; then

			echo "\"$DisplayName\" is an extension attribute of type \"$EAInputType\"."
			
			TargetDirectory="$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType"
			
			if [[ "$EAInputType" = "script" ]]; then
							
				# get the platform
				ScriptPlatform=$(echo "$FormattedComputerExtensionAttribute" | xpath "/computer_extension_attribute/input_type[$EAInputTypeNodeCount]/platform/text()" 2>/dev/null)
				
				if [[ -n "$ScriptPlatform" ]]; then
					echo "\"$DisplayName\" runs on $ScriptPlatform."
					TargetDirectory="$TargetDirectory/$ScriptPlatform"
					
					if [[ "$ScriptPlatform" = "Mac" ]]; then
						FileName=$(echo "$DisplayName" | sed 's/[:/[:cntrl:]]/_/g')
						FileName="${FileName}.sh"
					elif [[ "$ScriptPlatform" = "Windows" ]]; then
						FileName=$(echo "$DisplayName" | sed 's/[.<>:"/\|?*[:cntrl:]]/_/g')
						FileName="${FileName}.wsf"
					fi
				fi
				
				FinalAttribute=$(echo "$FormattedComputerExtensionAttribute" | xpath "/computer_extension_attribute/input_type[$EAInputTypeNodeCount]/script/text()" 2>/dev/null | perl -MHTML::Entities -pe 'decode_entities($_);')
			else
				FileName="${DisplayName}.xml"
				FinalAttribute="$FormattedComputerExtensionAttribute"
			fi
	
			# create the directory if needed
			if [[ ! -d "$TargetDirectory" ]]; then
			  	mkdir -p "$TargetDirectory"
			fi
			
			echo "Saving \"$FileName\" file to $TargetDirectory."
			echo "$FinalAttribute" | perl -MHTML::Entities -pe 'decode_entities($_);' > "$TargetDirectory/$FileName"
		else 
			echo "Error! Unable to determine the attribute's input type"
		fi
				
		((EAInputTypeNodeCount--))
	done
	
	echo	
}

ComputerExtensionAttribute_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computerextensionattributes" | xpath "//id" 2>/dev/null)

if [[ -n "$ComputerExtensionAttribute_id_list" ]]; then

	echo "Downloading extension attributes from $jamfpro_url..."
	ComputerExtensionAttribute_id=$(echo "$ComputerExtensionAttribute_id_list" | grep -Eo "[0-9]+")

	for ID in ${ComputerExtensionAttribute_id}; do
	   DownloadComputerExtensionAttribute
	done
	
else
	echo "ERROR! Unable to get extension attribute list"
fi

exit 0