#!/bin/sh

parameters="${1}${2}${3}${4}${5}${6}${7}${8}${9}"

Escape_Variables()
{
	text_progress="\033[38;5;113m"
	text_success="\033[38;5;113m"
	text_warning="\033[38;5;221m"
	text_error="\033[38;5;203m"
	text_message="\033[38;5;75m"

	text_bold="\033[1m"
	text_faint="\033[2m"
	text_italic="\033[3m"
	text_underline="\033[4m"

	erase_style="\033[0m"
	erase_line="\033[0K"

	move_up="\033[1A"
	move_down="\033[1B"
	move_foward="\033[1C"
	move_backward="\033[1D"
}

Parameter_Variables()
{
	if [[ $parameters == *"-v"* || $parameters == *"-verbose"* ]]; then
		verbose="1"
		set -x
	fi
}

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"

	resources_path="/usr/patch"
}

Input_Off()
{
	stty -echo
}

Input_On()
{
	stty echo
}

Output_Off()
{
	if [[ $verbose == "1" ]]; then
		"$@"
	else
		"$@" &>/dev/null
	fi
}

Check_Environment()
{
	echo ${text_progress}"> Checking system environment."${erase_style}

	if [ ! -d /Install\ *.app ]; then
		exit
	fi

	echo ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Root()
{
	echo ${text_progress}"> Checking for root permissions."${erase_style}

	if [[ $environment == "installer" ]]; then
		root_check="passed"
		echo ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
	else

		if [[ $(whoami) == "root" && $environment == "system" ]]; then
			root_check="passed"
			echo ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
		fi

		if [[ ! $(whoami) == "root" && $environment == "system" ]]; then
			root_check="failed"
			echo ${text_error}"- Root permissions check failed."${erase_style}
			echo ${text_message}"/ Run this tool with root permissions."${erase_style}

			Input_On
			exit
		fi

	fi
}

Check_SIP()
{
	echo ${text_progress}"> Checking System Integrity Protection status."${erase_style}

	if [[ $(csrutil status | grep status) == *disabled* || $(csrutil status | grep status) == *unknown* ]]; then
		echo ${move_up}${erase_line}${text_success}"+ System Integrity Protection status check passed."${erase_style}
	fi

	if [[ $(csrutil status | grep status) == *enabled* ]]; then
		echo ${text_error}"- System Integrity Protection status check failed."${erase_style}
		echo ${text_message}"/ Run this tool with System Integrity Protection disabled."${erase_style}

		Input_On
		exit
	fi
}

Check_Resources()
{
	echo ${text_progress}"> Checking for resources."${erase_style}

	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi

	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo ${text_error}"- Resources check failed."${erase_style}
		echo ${text_message}"/ Run this tool with the required resources."${erase_style}

		Input_On
		exit
	fi
}

Input_Model()
{

model_list="/     iMac7,1
/     iMac8,1
/     iMac9,1
/     iMac10,1
/     iMac10,2
/     iMac11,1
/     iMac11,2
/     iMac11,3
/     iMac12,1
/     iMac12,2
/     MacBook4,1
/     MacBook5,1
/     MacBook5,2
/     MacBook6,1
/     MacBook7,1
/     MacBookAir2,1
/     MacBookAir3,1
/     MacBookAir3,2
/     MacBookAir4,1
/     MacBookAir4,2
/     MacBookPro4,1
/     MacBookPro5,1
/     MacBookPro5,2
/     MacBookPro5,3
/     MacBookPro5,4
/     MacBookPro5,5
/     MacBookPro6,1
/     MacBookPro6,2
/     MacBookPro7,1
/     MacBookPro8,1
/     MacBookPro8,2
/     MacBookPro8,3
/     Macmini3,1
/     Macmini4,1
/     Macmini5,1
/     Macmini5,2
/     Macmini5,3
/     MacPro3,1
/     MacPro4,1
/     Xserve2,1
/     Xserve3,1"

model_apfs="iMac7,1
iMac8,1
iMac9,1
MacBook4,1
MacBook5,1
MacBook5,2
MacBookAir2,1
MacBookPro4,1
MacBookPro5,1
MacBookPro5,2
MacBookPro5,3
MacBookPro5,4
MacBookPro5,5
Macmini3,1
MacPro3,1
MacPro4,1
Xserve2,1
Xserve3,1"

model_airport="iMac7,1
iMac8,1
MacBookAir2,1
MacBookPro4,1
Macmini3,1
MacPro3,1"
	
	model_detected="$(sysctl -n hw.model)"

	echo ${text_progress}"> Detecting model."${erase_style}
	echo ${move_up}${erase_line}${text_success}"+ Detected model as $model_detected."${erase_style}

	echo ${text_message}"/ What model would you like to use?"${erase_style}
	echo ${text_message}"/ Input an model option."${erase_style}
	echo ${text_message}"/     1 - Use detected model"${erase_style}
	echo ${text_message}"/     2 - Use manually selected model"${erase_style}

	Input_On
	echo "/ 1"${erase_style}
	Input_Off

	# if [[ $model_option == "1" ]]; then
		model="$model_detected"
		echo ${text_success}"+ Using $model_detected as model."${erase_style}
	# fi

	if [[ $model_option == "2" ]]; then
		echo ${text_message}"/ What model would you like to use?"${erase_style}
		echo ${text_message}"/ Input your model."${erase_style}
		echo ${text_message}"$model_list"${erase_style}

		Input_On
		read -e -p "/ " model_selected
		Input_Off

		model="$model_selected"
		echo ${text_success}"+ Using $model_selected as model."${erase_style}
	fi

	if [[ "$model_apfs" == *"$model"* ]]; then
		model_apfs="1"
	fi
}

Input_Volume()
{
	echo ${text_message}"/ What volume would you like to use?"${erase_style}
	echo ${text_message}"/ Input a volume name."${erase_style}

	for volume_path in /Volumes/*; do
		volume_name="${volume_path#/Volumes/}"

		if [[ ! "$volume_name" == com.apple* ]]; then
			echo ${text_message}"/     ${volume_name}"${erase_style} | sort -V
		fi

	done

	if [[ $(find /Volumes/* -name "macOS\ Install\ Data" -maxdepth 1 | wc -l | sed 's/\       //') == "1" ]]; then
		volume_path="$(find /Volumes/* -name "macOS\ Install\ Data" -maxdepth 1)"

		volume_path="${volume_path%/macOS Install Data}"
		volume_name="${volume_path#/Volumes/}"
	else
		exit
	fi

	Input_On
	echo "/ $volume_name"${erase_style}
	Input_Off
}

Mount_EFI()
{
	disk_identifier="$(diskutil info "$volume_name"|grep "Device Identifier")"
	disk_identifier="disk${disk_identifier#*disk}"
	disk_identifier_whole="$(diskutil info "$volume_name"|grep "Part of Whole")"
	disk_identifier_whole="disk${disk_identifier_whole#*disk}"
	
	if [[ "$(diskutil info "$volume_name"|grep "APFS")" == *"APFS"* ]]; then
		disk_identifier_whole="$(diskutil list|grep "\<$disk_identifier_whole\>")"
		disk_identifier_whole="${disk_identifier_whole#*disk}"
		disk_identifier_whole="${disk_identifier_whole#*disk}"
		disk_identifier_whole="disk${disk_identifier_whole:0:1}"
		disk_identifier_efi="${disk_identifier_whole}s1"
	fi
	
	if [[ "$(diskutil info "$volume_name"|grep "HFS")" == *"HFS"* ]]; then
		disk_identifier_efi="${disk_identifier_whole}s1"
	fi

	Output_Off diskutil mount $disk_identifier_efi
}

Check_Volume_Version()
{
	echo ${text_progress}"> Checking system version."${erase_style}

		volume_version="$(defaults read "$volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductVersion)"
		volume_version_short="$(defaults read "$volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductVersion | cut -c-5)"
	
		volume_build="$(defaults read "$volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductBuildVersion)"

	echo ${move_up}${erase_line}${text_success}"+ Checked system version."${erase_style}
}

Check_Volume_Support()
{
	echo ${text_progress}"> Checking system support."${erase_style}

	if [[ $volume_version_short == "10.15" ]]; then
		echo ${move_up}${erase_line}${text_success}"+ System support check passed."${erase_style}
	else
		echo ${text_error}"- System support check failed."${erase_style}
		echo ${text_message}"/ Run this tool on a supported system."${erase_style}

		Input_On
		exit
	fi
}

Patch_Volume()
{
	echo ${text_progress}"> Patching platform support check."${erase_style}

		Output_Off rm "$volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/PlatformSupport.plist

	echo ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}
}

Input_Operation_APFS()
{
	if [[ "$(diskutil info "$volume_name"|grep "APFS")" == *"APFS"* ]]; then
		if [[ $model_apfs == "1" ]]; then
			echo ${text_warning}"! Your system doesn't support APFS."${erase_style}
			echo ${text_message}"/ What operation would you like to run?"${erase_style}
			echo ${text_message}"/ Input an operation number."${erase_style}
			echo ${text_message}"/     1 - Install the APFS patch"${erase_style}
			echo ${text_message}"/     2 - Continue without the APFS patch"${erase_style}

			Input_On
			echo "/ 1"${erase_style}
			Input_Off

			# if [[ $operation_apfs == "1" ]]; then
				Patch_APFS
			# fi
		fi
	fi
}

Patch_APFS()
{
	echo ${text_progress}"> Installing APFS system patch."${erase_style}

		volume_uuid="$(diskutil info "$volume_name"|grep "Volume UUID")"
		volume_uuid="${volume_uuid:30:38}"
	
		if [[ ! -d /Volumes/EFI/EFI ]]; then
			mkdir /Volumes/EFI/EFI
		fi

		if [[ ! -d /Volumes/EFI/EFI/BOOT ]]; then
			mkdir /Volumes/EFI/EFI/BOOT
		fi
	
		cp "$resources_path"/startup.nsh /Volumes/EFI/EFI/BOOT
		cp "$resources_path"/BOOTX64.efi /Volumes/EFI/EFI/BOOT

		Output_Off hdiutil attach "$volume_path"/macOS\ Install\ Data/BaseSystem.dmg -mountpoint /tmp/Base\ System -nobrowse

		cp /tmp/Base\ System/usr/standalone/i386/apfs.efi /Volumes/EFI/EFI

		Output_Off hdiutil detach /tmp/Base\ System
	
		if [[ -d "$volume_path"/Library/PreferencePanes/APFS\ Boot\ Selector.prefPane ]]; then
			rm -R "$volume_path"/Library/PreferencePanes/APFS\ Boot\ Selector.prefPane
		fi
	
		sed -i '' "s/\"volume_uuid\"/\"$volume_uuid\"/g" /Volumes/EFI/EFI/BOOT/startup.nsh
		sed -i '' "s/\"boot_file\"/\"macOS Install Data\\\Locked Files\\\Boot Files\\\boot.efi\"/g" /Volumes/EFI/EFI/BOOT/startup.nsh
	
		if [[ $(diskutil info "$volume_name"|grep "Device Location") == *"Internal" ]]; then
			Output_Off bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/EFI/BOOT/BOOTX64.efi --shortform
		fi

	echo ${move_up}${erase_line}${text_success}"+ Installed APFS system patch."${erase_style}
}

Patch_Volume_Helpers()
{
	disk_identifier="$(diskutil info "$volume_name"|grep "Device Identifier")"
	disk_identifier="disk${disk_identifier#*disk}"
	disk_identifier_whole="$(diskutil info "$volume_name"|grep "Part of Whole")"
	disk_identifier_whole="disk${disk_identifier_whole#*disk}"
	disk_identifier_number="$((${disk_identifier: -1} + 1))"

	if [[ "$(diskutil info "$volume_name"|grep "APFS")" == *"APFS"* ]]; then
		echo ${text_progress}"> Patching Preboot partition."${erase_style}

			if [[ "$(diskutil info "${disk_identifier_whole}s2"|grep "Volume Name")" == *"Preboot" ]]; then
				preboot_identifier="${disk_identifier_whole}s2"
			fi
			if [[ "$(diskutil info "${disk_identifier_whole}s3"|grep "Volume Name")" == *"Preboot" ]]; then
				preboot_identifier="${disk_identifier_whole}s3"
			fi
			if [[ "$(diskutil info "${disk_identifier_whole}s4"|grep "Volume Name")" == *"Preboot" ]]; then
				preboot_identifier="${disk_identifier_whole}s4"
			fi
	
			if [[ ! "$(diskutil info "${preboot_identifier}"|grep "Volume Name")" == *"Preboot" ]]; then
				echo ${text_error}"- Error patching Preboot partition."${erase_style}
				echo ${text_error}"- Preboot partition could not be found."${erase_style}
			else
	
				Output_Off diskutil mount "$preboot_identifier"
	
				for numeric_folder in /Volumes/Preboot/*; do
					if [[ -e "$numeric_folder"/System/Library/CoreServices/SystemVersion.plist ]]; then
						preboot_version="$(defaults read "$numeric_folder"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
						preboot_version_short="$(defaults read "$numeric_folder"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
					fi
					
					if [[ "$(diskutil info "$volume_name"|grep "Volume UUID")" == *"${numeric_folder#/Volumes/Preboot/}"* ]]; then
						if [[ $volume_version_short == $preboot_version_short ]]; then
							preboot_folder="$numeric_folder"
						fi
					fi
				done
	
				if [[ ! $preboot_folder == "/Volumes/Preboot/"* ]]; then
					echo ${text_error}"- Error patching Preboot partition."${erase_style}
				else
					Output_Off rm "$preboot_folder"/System/Library/CoreServices/PlatformSupport.plist
					Output_Off rm "$preboot_folder"/com.apple.installer/PlatformSupport.plist
	
					Output_Off diskutil unmount /Volumes/Preboot

				echo ${move_up}${erase_line}${text_success}"+ Patched Preboot partition."${erase_style}
			fi
		fi
	fi
}

End()
{
	Output_Off diskutil unmount /Volumes/EFI

	echo ${text_message}"/ Thank you for using macOS Patcher."${erase_style}

	Input_On
	Output_Off shutdown -r now
}

Input_Off
Escape_Variables
Parameter_Variables
Path_Variables
Check_Environment
Check_Root
Check_SIP
Check_Resources
Input_Model
Input_Volume
Mount_EFI
Check_Volume_Version
Check_Volume_Support
Patch_Volume
Input_Operation_APFS
Patch_Volume_Helpers
End