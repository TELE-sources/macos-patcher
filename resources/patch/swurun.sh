#!/bin/bash

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
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system environment."${erase_style}

	if [ -d /Install\ *.app ]; then
		environment="installer"
	fi

	if [ ! -d /Install\ *.app ]; then
		environment="system"
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Root()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for root permissions."${erase_style}

	if [[ $environment == "installer" ]]; then
		root_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
	else

		if [[ $(whoami) == "root" && $environment == "system" ]]; then
			root_check="passed"
			echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
		fi

		if [[ ! $(whoami) == "root" && $environment == "system" ]]; then
			root_check="failed"
			echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Root permissions check failed."${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with root permissions."${erase_style}

			Input_On
			exit
		fi

	fi
}

Check_SIP()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking System Integrity Protection status."${erase_style}

	if [[ $(csrutil status | grep status) == *disabled* ]] || [[ $(csrutil status | grep status) == *Custom\ Configuration* && $(csrutil status | grep "Kext Signing") == *disabled* ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ System Integrity Protection status check passed."${erase_style}
	fi

	if [[ $(csrutil status | grep status) == *enabled* && ! $(csrutil status | grep status) == *Custom\ Configuration* ]] || [[ $(csrutil status | grep status) == *Custom\ Configuration* && $(csrutil status | grep "Kext Signing") == *enabled* ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- System Integrity Protection status check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with System Integrity Protection disabled."${erase_style}

		Input_On
		exit
	fi
}

Input_Volume()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What volume would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input a volume name."${erase_style}

	for volume_path in /Volumes/*; do
		volume_name="${volume_path#/Volumes/}"

		if [[ ! "$volume_name" == com.apple* ]]; then
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     ${volume_name}"${erase_style} | sort
		fi

	done

	volume_path=""
	volume_name=""
	
	if [[ $(find /System/Volumes/* -name "macOS\ Install\ Data" -maxdepth 1 | wc -l | sed 's/\       //') == "1" ]]; then
		volume_path="$(find /System/Volumes/* -name "macOS\ Install\ Data" -maxdepth 1 )"

		update_volume_path="${volume_path%/macOS Install Data}"
		volume_path="$(diskutil info /|grep "Mount Point"|sed 's/.*\ //')"
		volume_name="$(diskutil info /|grep "Volume Name"|sed 's/.*\ //')"
	fi
	
	if [[ $(find /Volumes/* -name "macOS\ Install\ Data" -maxdepth 1 | wc -l | sed 's/\       //') == "1" ]]; then
		volume_path="$(find /Volumes/* -name "macOS\ Install\ Data" -maxdepth 1)"

		update_volume_path="${volume_path%/macOS Install Data}"
		volume_path="${volume_path%/macOS Install Data}"
		volume_name="${volume_path#/Volumes/}"
	fi

	if [[ $(find /Volumes/*/usr/patch -name "SystemVersion.plist" -maxdepth 1 | wc -l | sed 's/\       //') == "1" ]]; then
		volume_path="$(find /Volumes/*/usr/patch -name "SystemVersion.plist" -maxdepth 1)"

		previous_volume_path="${volume_path%/usr/patch/SystemVersion.plist}"
		volume_path="${volume_path%/usr/patch/SystemVersion.plist}"
		volume_name="${volume_path#/Volumes/}"
	fi

	if [[ "$volume_path" == "" ]]; then
		Input_On
		exit
	fi

	Input_On
	echo -e $(date "+%b %m %H:%M:%S") "/ $volume_name"${erase_style}
	Input_Off
}

Check_Volume_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system version."${erase_style}

		volume_version="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		volume_version_short="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
		volume_build="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

		update_version="$(defaults read "$update_volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductVersion)"
		update_version_short="$(defaults read "$update_volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductVersion | cut -c-5)"
		
		update_build="$(defaults read "$update_volume_path"/macOS\ Install\ Data/Locked\ Files/Boot\ Files/SystemVersion.plist ProductBuildVersion)"

		previous_version="$(defaults read "$volume_path"/usr/patch/SystemVersion.plist ProductVersion)"
		previous_version_short="$(defaults read "$volume_path"/usr/patch/SystemVersion.plist ProductVersion | cut -c-5)"
		
		previous_build="$(defaults read "$volume_path"/usr/patch/SystemVersion.plist ProductBuildVersion)"

		if [[ ! "$update_volume_path" == "" ]] && [[ ! $volume_version == $update_version ]]; then
			volume_versions_differ="1"
		fi
	
		if [[ ! "$update_volume_path" == "" ]] && [[ ! $volume_build == $update_build ]]; then
			volume_builds_differ="1"
		fi

		if [[ ! "$previous_volume_path" == "" ]] && [[ ! $volume_version == $previous_version ]]; then
			volume_versions_newer="1"
		fi
	
		if [[ ! "$previous_volume_path" == "" ]] && [[ ! $volume_build == $previous_build ]]; then
			volume_builds_newer="1"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system version."${erase_style}
}

Check_Volume_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system support."${erase_style}

	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ System support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- System support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool on a supported system."${erase_style}

		Input_On
		exit
	fi
}

End()
{
	if [[ $volume_versions_differ == "1" || $volume_builds_differ == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Running swuprep script."${erase_style}

		Input_On
		Output_Off /usr/bin/swuprep -v
	fi

	if [[ $volume_versions_newer == "1" || $volume_builds_newer == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Running swupost script."${erase_style}

		Input_On
		Output_Off /usr/bin/swupost -v
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Thank you for using macOS Patcher."${erase_style}

	Input_On
	exit
}

Input_Off
Escape_Variables
Parameter_Variables
Check_Environment
Check_Root
Check_SIP
Input_Volume
Check_Volume_Version
Check_Volume_Support
End