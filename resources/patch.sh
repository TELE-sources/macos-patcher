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

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"

	resources_path="$directory_path/patch"

	if [[ -d "/patch" ]]; then
		resources_path="/patch"
	fi
	
	if [[ -d "/Volumes/Image Volume/patch" ]]; then
		resources_path="/Volumes/Image Volume/patch"
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

Check_Resources()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for resources."${erase_style}

	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi

	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Resources check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required resources."${erase_style}

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
MacBook4,1
MacBookAir2,1
MacBookPro4,1
Macmini3,1
MacPro3,1"

model_metal="MacPro3,1
MacPro4,1
MacPro5,1
iMac12,1
iMac12,2
Xserve2,1
Xserve3,1"
	
	model_detected="$(sysctl -n hw.model)"

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Detecting model."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Detected model as $model_detected."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What model would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an model option."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Use detected model"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Use manually selected model"${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " model_option
	Input_Off

	if [[ $model_option == "1" ]]; then
		model="$model_detected"
		echo -e $(date "+%b %m %H:%M:%S") ${text_success}"+ Using $model_detected as model."${erase_style}
	fi

	if [[ $model_option == "2" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What model would you like to use?"${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input your model."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"$model_list"${erase_style}

		Input_On
		read -e -p "$(date "+%b %m %H:%M:%S") / " model_selected
		Input_Off

		model="$model_selected"
		echo -e $(date "+%b %m %H:%M:%S") ${text_success}"+ Using $model_selected as model."${erase_style}
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

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " volume_name
	Input_Off

	volume_path="/Volumes/$volume_name"
}

Mount_EFI()
{
	disk_identifier="$(diskutil info "$volume_name"|grep "Device Identifier"|sed 's/.*\ //')"
	disk_identifier_whole="$(diskutil info "$volume_name"|grep "Part of Whole"|sed 's/.*\ //')"
	
	if [[ "$(diskutil info "$volume_name"|grep "File System Personality"|sed 's/.*\ //')" == "APFS" ]]; then
		disk_identifier_whole="$(diskutil info "$volume_name"|grep "APFS Physical Store"|sed 's/.*\ //'|cut -c-6)"
		disk_identifier_efi="${disk_identifier_whole}1"
	fi
	
	if [[ "$(diskutil info "$volume_name"|grep "File System Personality"|sed 's/.*\ //')" == "HFS" ]]; then
		disk_identifier_efi="${disk_identifier_whole}1"
	fi

	Output_Off diskutil mount $disk_identifier_efi
}

Check_Volume_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system version."${erase_style}

		volume_version="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		volume_version_short="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
		volume_build="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

		if [[ -d "/Volumes/Image Volume" ]]; then
			image_volume_version="$(defaults read /Volumes/Image\ Volume/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
			image_volume_version_short="$(defaults read /Volumes/Image\ Volume/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
			image_volume_build="$(defaults read /Volumes/Image\ Volume/System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system version."${erase_style}
}

Check_Volume_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system support."${erase_style}

	if [[ $volume_version_short == "10.1"[2-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ System support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- System support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool on a supported system."${erase_style}

		Input_On
		exit
	fi
}

Volume_Variables()
{
	if [ -e $volume_path/Library/LaunchAgents/com.dd1* ] || [ -e $volume_path/Library/LaunchAgents/com.dosdude1* ]; then
		volume_patch_variant_dosdude="1"
	fi

	if [[ -e /Volumes/EFI/EFI/BOOT/BOOTX64.efi && -e /Volumes/EFI/EFI/apfs.efi ]]; then
		volume_patch_apfs="1"
	fi
}

Check_Volume_dosdude()
{
	if [[ $volume_patch_variant_dosdude == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Your system was patched by another patcher."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool on a clean system."${erase_style}

		Input_On
		exit
	fi
}

Clean_Volume()
{
	Output_Off rm "$volume_path"/System/Library/CoreServices/SystemVersion-pip.plist

	Output_Off rm "$volume_path"/usr/bin/piputil
	Output_Off rm "$volume_path"/usr/bin/transutil

	if [[ $system_version_short	== "10.15" ]]; then
		Output_Off rm "$volume_path - Data"/Library/LaunchAgents/com.rmc.pipagent.plist
		Output_Off rm -R "$volume_path - Data"/Library/Application\ Support/com.rmc.pipagent
	else
		Output_Off rm "$volume_path"/Library/LaunchAgents/com.rmc.pipagent.plist
		Output_Off rm -R "$volume_path"/Library/Application\ Support/com.rmc.pipagent
	fi

	Output_Off rm "$volume_path"/System/Library/PrivateFrameworks/CoreUI.framework/Versions/Current/CoreUI-bak
	Output_Off rm "$volume_path"/System/Library/Frameworks/AppKit.framework/Versions/Current/AppKit-bak
	Output_Off rm "$volume_path"/System/Library/Frameworks/Carbon.framework/Frameworks/HIToolbox.framework/Versions/Current/HIToolbox-bak
}

Patch_Volume()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching input drivers."${erase_style}

		cp -R "$resources_path"/LegacyUSBEthernet.kext "$volume_path"/System/Library/Extensions
		cp -R "$resources_path"/LegacyUSBInjector.kext "$volume_path"/System/Library/Extensions
		cp -R "$resources_path"/LegacyUSBVideoSupport.kext "$volume_path"/System/Library/Extensions
	
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			cp -R "$resources_path"/AppleUSBACM.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleUSBTopCase.kext "$volume_path"/System/Library/Extensions
		fi

		if [[ $volume_version_short == "10.14" ]]; then
			cp -R "$resources_path"/IOUSBFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IOUSBHostFamily.kext "$volume_path"/System/Library/Extensions
		fi
		
	
		# if [[ $volume_version_short == "10.15" ]]; then
		# 	cp -R "$resources_path"/IOHIDFamily.kext "$volume_path"/System/Library/Extensions
		# fi
	
		if [[ $model == "MacBook4,1" ]]; then
			cp -R "$resources_path"/MacBook4,1/AppleIRController.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleMultitouchDriver.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleUSBTopCase.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOBDStorageFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOUSBFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOUSBHostFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOUSBMassStorageClass.kext "$volume_path"/System/Library/Extensions
	
			if [[ ! $volume_version_short == "10.15" ]]; then
				cp -R "$resources_path"/MacBook4,1/AppleHIDMouse.kext "$volume_path"/System/Library/Extensions
				cp -R "$resources_path"/MacBook4,1/AppleHSSPIHIDDriver.kext "$volume_path"/System/Library/Extensions
				cp -R "$resources_path"/MacBook4,1/AppleTopCase.kext "$volume_path"/System/Library/Extensions
				cp -R "$resources_path"/MacBook4,1/AppleUSBMultitouch.kext "$volume_path"/System/Library/Extensions
				cp -R "$resources_path"/MacBook4,1/IOSerialFamily.kext "$volume_path"/System/Library/Extensions
			fi
		fi
	
		if [[ $model == "MacBook4,1" || $model == "MacBook5,2" ]]; then
			cp -R "$resources_path"/Trackpad.prefPane "$volume_path"/System/Library/PreferencePanes
		fi

		if [[ $model == "MacBook5,2" ]]; then
			cp -R "$resources_path"/AppleTopCase.kext "$volume_path"/System/Library/Extensions
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched input drivers."${erase_style}


	if [[ $model_metal == *$model* ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Metal graphics card compatible model detected."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ These graphics patches are not for Metal cards."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Install the graphics patches"${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Continue without the graphics patch"${erase_style}
		Input_On
		read -e -p "$(date "+%b %m %H:%M:%S") / " operation_graphis_card
		Input_Off
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching graphics drivers."${erase_style}

		if [[ $model == "MacPro3,1" ]]; then
			cp -R "$resources_path"/AAAMouSSE.kext "$volume_path"/System/Library/Extensions
		fi

		if [[ $volume_version_short == "10.1"[3-5] ]]; then
			cp -R "$resources_path"/AMDRadeonX3000.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonX3000GLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonX4000.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonX4000GLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IOAccelerator2D.plugin "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IOAcceleratorFamily2.kext "$volume_path"/System/Library/Extensions
		fi
	
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			cp -R "$resources_path"/AMD2400Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD2600Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD3800Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD4600Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD4800Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD5000Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMD6000Controller.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDFramebuffer.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDLegacyFramebuffer.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDLegacySupport.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonVADriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonVADriver2.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDRadeonX4000HWServices.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDShared.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AMDSupport.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelFramebufferAzul.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelFramebufferCapri.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHD3000Graphics.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHD3000GraphicsGA.plugin "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHD3000GraphicsGLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHD3000GraphicsVADriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHDGraphics.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHDGraphicsFB.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHDGraphicsGA.plugin "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHDGraphicsGLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelHDGraphicsVADriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelSNBGraphicsFB.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleIntelSNBVA.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/ATIRadeonX2000.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/ATIRadeonX2000GA.plugin "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/ATIRadeonX2000GLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/ATIRadeonX2000VADriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/GeForceTesla.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/GeForceTeslaGLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/GeForceTeslaVADriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IOGraphicsFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IONDRVSupport.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/NVDANV50HalTesla.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/NVDAResmanTesla.kext "$volume_path"/System/Library/Extensions
		fi
		
		if [[ $volume_version_short == "10.14" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			rm -R "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
			cp -R "$resources_path"/10.14/SkyLight.framework "$volume_path"/System/Library/PrivateFrameworks
		fi

		if [[ $volume_version == "10.14."[4-6] || $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			cp "$resources_path"/libGPUSupport.dylib "$volume_path"/System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/Libraries
			rm -R "$volume_path"/System/Library/Frameworks/OpenGL.framework
			cp -R "$resources_path"/OpenGL.framework "$volume_path"/System/Library/Frameworks
		fi
	
		if [[ $volume_version == "10.14."[5-6] ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			rm -R "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
			cp -R "$resources_path"/10.14/CoreDisplay.framework "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
		fi

		if [[ $volume_version_short == "10.15" ]]; then
			cp -R "$resources_path"/IOSurface.kext "$volume_path"/System/Library/Extensions
		fi
	
		if [[ $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			rm -R "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
			cp -R "$resources_path"/CoreDisplay.framework "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
			rm -R "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
			cp -R "$resources_path"/SkyLight.framework "$volume_path"/System/Library/PrivateFrameworks
			cp "$resources_path"/libCoreFSCache.dylib "$volume_path"/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries
		fi
	
		if [[ $model == "MacBook4,1" ]]; then
			cp -R "$resources_path"/MacBook4,1/AppleIntelGMAX3100.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleIntelGMAX3100FB.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleIntelGMAX3100GA.plugin "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleIntelGMAX3100GLDriver.bundle "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/AppleIntelGMAX3100VADriver.bundle "$volume_path"/System/Library/Extensions

			if [[ -d "$volume_path - Data" ]]; then
				cp -R "$resources_path"/Brightness\ Slider.app "$volume_path - Data"/Applications/Utilities
				cp -R "$resources_path"/NoSleep.app "$volume_path - Data"/Applications/Utilities
				cp -R "$resources_path"/NoSleep.kext "$volume_path - Data"/Library/Extensions
			else
				cp -R "$resources_path"/Brightness\ Slider.app "$volume_path"/Applications/Utilities
				cp -R "$resources_path"/NoSleep.app "$volume_path"/Applications/Utilities
				cp -R "$resources_path"/NoSleep.kext "$volume_path"/Library/Extensions
			fi
		fi
	
		if [[ $model == "MacBookPro6,2" ]] && [[ $volume_version == "10.14."[5-6] || $volume_version_short == "10.15" ]]; then
			cp -R "$resources_path"/AppleGraphicsControl.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleGraphicsPowerManagement.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/AppleMCCSControl.kext "$volume_path"/System/Library/Extensions
			rm -R "$volume_path"/System/Library/PrivateFrameworks/GPUWrangler.framework
			cp -R "$resources_path"/GPUWrangler.framework "$volume_path"/System/Library/PrivateFrameworks
		fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched graphics drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching audio drivers."${erase_style}

		if [[ $model == "MacBook4,1" ]]; then
			cp -R "$resources_path"/MacBook4,1/AppleHDA.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOAudioFamily.kext "$volume_path"/System/Library/Extensions
		else
			cp -R "$resources_path"/AppleHDA.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/IOAudioFamily.kext "$volume_path"/System/Library/Extensions
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched audio drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching backlight drivers."${erase_style}

		cp -R "$resources_path"/AppleBacklight.kext "$volume_path"/System/Library/Extensions
		cp -R "$resources_path"/AppleBacklightExpert.kext "$volume_path"/System/Library/Extensions
		rm -R "$volume_path"/System/Library/PrivateFrameworks/DisplayServices.framework
		cp -R "$resources_path"/DisplayServices.framework "$volume_path"/System/Library/PrivateFrameworks
		Output_Off rm -R "$volume_path"/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AGDCBacklightControl.kext

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched backlight drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching ambient light sensor drivers."${erase_style}

		cp -R "$resources_path"/AmbientLightSensorHID.plugin "$volume_path"/System/Library/Extensions/AppleSMCLMU.kext/Contents/PlugIns/

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched ambient light sensor drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching AirPort drivers."${erase_style}

		if [[ $volume_version_short == "10.15" ]]; then 
			cp -R "$resources_path"/IO80211Family.kext "$volume_path"/System/Library/Extensions
		fi
	
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			cp -R "$resources_path"/AirPortAtheros40.kext "$volume_path"/System/Library/Extensions/IO80211Family.kext/Contents/PlugIns
		fi
	
		if [[ $model_airport == *$model* ]]; then
			cp -R "$resources_path"/Broadcom/IO80211Family.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/corecapture.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/CoreCaptureResponder.kext "$volume_path"/System/Library/Extensions
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched AirPort drivers."${erase_style}


	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Ethernet drivers."${erase_style}

			cp -R "$resources_path"/nvenet.kext "$volume_path"/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns
			cp -R "$resources_path"/AppleYukon2.kext "$volume_path"/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Ethernet drivers."${erase_style}
	fi


	if [[ $model == "MacBook4,1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Bluetooth drivers."${erase_style}

			cp -R "$resources_path"/MacBook4,1/IOBluetoothFamily.kext "$volume_path"/System/Library/Extensions
			cp -R "$resources_path"/MacBook4,1/IOBluetoothHIDDriver.kext "$volume_path"/System/Library/Extensions

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Bluetooth drivers."${erase_style}
	fi


	if [[ $volume_version == "10.14."[4-6] || $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Siri application."${erase_style}

			rm -R "$volume_path"/System/Library/PrivateFrameworks/SiriUI.framework
			cp -R "$resources_path"/SiriUI.framework "$volume_path"/System/Library/PrivateFrameworks

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Siri application."${erase_style}
	fi


	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching IDE drivers."${erase_style}

			cp -R "$resources_path"/AppleIntelPIIXATA.kext "$volume_path"/System/Library/Extensions/IOATAFamily.kext/Contents/PlugIns

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched IDE drivers."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching News+."${erase_style}

		if [[ ! $(grep -q "/System/Library/Frameworks/OpenCL.framework" "$volume_path"/System/iOSSupport/dyld/macOS-whitelist.txt) == "/System/Library/Frameworks/OpenCL.framework" ]]; then
    		echo "\n/System/Library/Frameworks/OpenCL.framework" >> "$volume_path"/System/iOSSupport/dyld/macOS-whitelist.txt
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched News+."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching software update check."${erase_style}

		if [[ $volume_version_short == "10.12" ]]; then
			cp "$resources_path"/10.12/SUVMMFaker.dylib "$volume_path"/usr/lib/SUVMMFaker.dylib
		fi

		if [[ $volume_version_short == "10.1"[3-4] ]]; then
			cp "$resources_path"/10.13/SUVMMFaker.dylib "$volume_path"/usr/lib/SUVMMFaker.dylib
		fi

		if [[ $volume_version_short == "10.15" ]]; then
			cp "$resources_path"/SUVMMFaker.dylib "$volume_path"/usr/lib/SUVMMFaker.dylib
		fi

		cp "$resources_path"/com.apple.softwareupdated.plist "$volume_path"/System/Library/LaunchDaemons

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched software update check."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching platform support check."${erase_style}
		
		Output_Off rm "$volume_path"/System/Library/CoreServices/PlatformSupport.plist

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}


	if [[ $volume_version_short == "10.1"[4-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel panic issue."${erase_style}

			Output_Off rm -R "$volume_path"/System/Library/UserEventPlugins/com.apple.telemetry.plugin

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel panic issue."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel cache."${erase_style}

		rm "$volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		Output_Off kextcache -i "$volume_path" -kernel "$volume_path"/System/Library/Kernels/kernel

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel cache."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching System Integrity Protection."${erase_style}

		cp -R "$resources_path"/SIPManager.kext "$volume_path"/System/Library/Extensions

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched System Integrity Protection."${erase_style}


	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying patcher utilities."${erase_style}
	
			if [[ ! -d "$volume_path"/usr/patch ]]; then
				mkdir -p "$volume_path"/usr/patch
			fi
			
			cp "$resources_path"/startup.nsh "$volume_path"/usr/patch/
			cp "$resources_path"/startup-update.nsh "$volume_path"/usr/patch/
			cp "$resources_path"/BOOTX64.efi "$volume_path"/usr/patch/
			cp "$resources_path"/com.rmc.swurun.plist "$volume_path"/System/Library/LaunchDaemons
	
			cp "$resources_path"/swurun.sh "$volume_path"/usr/bin/swurun
			cp "$resources_path"/swuprep.sh "$volume_path"/usr/bin/swuprep
			cp "$resources_path"/swupost.sh "$volume_path"/usr/bin/swupost
	
			chmod +x "$volume_path"/usr/bin/swurun
			chmod +x "$volume_path"/usr/bin/swuprep
			chmod +x "$volume_path"/usr/bin/swupost
	
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied patcher utilities."${erase_style}
	fi
}

Repair()
{
	chown -R 0:0 "$@"
	chmod -R 755 "$@"
}

Repair_Permissions()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Repairing permissions."${erase_style}

		Repair "$volume_path"/System/Library/Extensions/LegacyUSBEthernet.kext
		Repair "$volume_path"/System/Library/Extensions/LegacyUSBInjector.kext
		Repair "$volume_path"/System/Library/Extensions/LegacyUSBVideoSupport.kext
		
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			Repair "$volume_path"/System/Library/Extensions/AppleUSBACM.kext
			Repair "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
		fi

		if [[ $volume_version_short == "10.14" ]]; then
			Repair "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
			Repair "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		fi
		
	
		# if [[ $volume_version_short == "10.15" ]]; then
		# 	Repair "$volume_path"/System/Library/Extensions/IOHIDFamily.kext
		# fi
	
		if [[ $model == "MacBook4,1" ]]; then
			Repair "$volume_path"/System/Library/Extensions/AppleIRController.kext
			Repair "$volume_path"/System/Library/Extensions/AppleMultitouchDriver.kext
			Repair "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
			Repair "$volume_path"/System/Library/Extensions/IOBDStorageFamily.kext
			Repair "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
			Repair "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
			Repair "$volume_path"/System/Library/Extensions/IOUSBMassStorageClass.kext
	
			if [[ ! $volume_version_short == "10.15" ]]; then
				Repair "$volume_path"/System/Library/Extensions/AppleHIDMouse.kext
				Repair "$volume_path"/System/Library/Extensions/AppleHSSPIHIDDriver.kext
				Repair "$volume_path"/System/Library/Extensions/AppleTopCase.kext
				Repair "$volume_path"/System/Library/Extensions/AppleUSBMultitouch.kext
				Repair "$volume_path"/System/Library/Extensions/IOSerialFamily.kext
			fi
		fi
	
		if [[ $model == "MacBook4,1" || $model == "MacBook5,2" ]]; then
			Repair "$volume_path"/System/Library/PreferencePanes/Trackpad.prefPane
		fi
		
		Repair "$volume_path"/System/Library/Extensions/AppleTopCase.kext
		
		if [[ $model == "MacPro3,1" ]]; then
			Repair "$volume_path"/System/Library/Extensions/AAAMouSSE.kext
		fi

		Repair "$volume_path"/System/Library/Extensions/AMDRadeonX3000.kext
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonX3000GLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonX4000.kext
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonX4000GLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/IOAccelerator2D.plugin
		Repair "$volume_path"/System/Library/Extensions/IOAcceleratorFamily2.kext
	
		Repair "$volume_path"/System/Library/Extensions/AMD2400Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD2600Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD3800Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD4600Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD4800Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD5000Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMD6000Controller.kext
		Repair "$volume_path"/System/Library/Extensions/AMDFramebuffer.kext
		Repair "$volume_path"/System/Library/Extensions/AMDLegacyFramebuffer.kext
		Repair "$volume_path"/System/Library/Extensions/AMDLegacySupport.kext
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonVADriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonVADriver2.bundle
		Repair "$volume_path"/System/Library/Extensions/AMDRadeonX4000HWServices.kext
		Repair "$volume_path"/System/Library/Extensions/AMDShared.bundle
		Repair "$volume_path"/System/Library/Extensions/AMDSupport.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelFramebufferAzul.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelFramebufferCapri.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHD3000Graphics.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsGA.plugin
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsGLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsVADriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHDGraphics.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsFB.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsGA.plugin
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsGLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsVADriver.bundle
		Repair "$volume_path"/System/Library/Extensions/AppleIntelSNBGraphicsFB.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIntelSNBVA.bundle
		Repair "$volume_path"/System/Library/Extensions/ATIRadeonX2000.kext
		Repair "$volume_path"/System/Library/Extensions/ATIRadeonX2000GA.plugin
		Repair "$volume_path"/System/Library/Extensions/ATIRadeonX2000GLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/ATIRadeonX2000VADriver.bundle
		Repair "$volume_path"/System/Library/Extensions/GeForceTesla.kext
		Repair "$volume_path"/System/Library/Extensions/GeForceTeslaGLDriver.bundle
		Repair "$volume_path"/System/Library/Extensions/GeForceTeslaVADriver.bundle
		Repair "$volume_path"/System/Library/Extensions/IOGraphicsFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IONDRVSupport.kext
		Repair "$volume_path"/System/Library/Extensions/NVDANV50HalTesla.kext
		Repair "$volume_path"/System/Library/Extensions/NVDAResmanTesla.kext

		if [[ $volume_version_short == "10.14" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			Repair "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
		fi
	
		if [[ $volume_version == "10.14."[4-6] || $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			Repair "$volume_path"/System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/Libraries/libGPUSupport.dylib
			Repair "$volume_path"/System/Library/Frameworks/OpenGL.framework
		fi
	
		if [[ $volume_version == "10.14."[5-6] ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			Repair "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
		fi
	
		if [[ $volume_version_short == "10.15" ]]; then
			Repair "$volume_path"/System/Library/Extensions/IOSurface.kext
		fi

		if [[ $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]] && [[ ! $operation_graphis_card == "2" ]]; then
			Repair "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
			Repair "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
		fi
	
		if [[ $model == "MacBook4,1" ]]; then
			Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100.kext
			Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100FB.kext
			Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GA.plugin
			Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GLDriver.bundle
			Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100VADriver.bundle

			if [[ -d "$volume_path - Data" ]]; then
				Repair "$volume_path - Data"/Applications/Utilities/NoSleep.app
				Repair "$volume_path - Data"/Library/Extensions/NoSleep.kext
				Repair "$volume_path - Data"/Library/LaunchAgents/com.protech.NoSleep.plist
			else
				Repair "$volume_path"/Applications/Utilities/NoSleep.app
				Repair "$volume_path"/Library/Extensions/NoSleep.kext
				Repair "$volume_path"/Library/LaunchAgents/com.protech.NoSleep.plist
			fi
		fi
	
		if [[ $model == "MacBookPro6,2" ]] && [[ $volume_version == "10.14."[5-6] || $volume_version_short == "10.15" ]]; then
			Repair "$volume_path"/System/Library/Extensions/AppleGraphicsControl.kext
			Repair "$volume_path"/System/Library/Extensions/AppleGraphicsPowerManagement.kext
			Repair "$volume_path"/System/Library/Extensions/AppleMCCSControl.kext
			Repair "$volume_path"/System/Library/PrivateFrameworks/GPUWrangler.framework
		fi
	
		Repair "$volume_path"/System/Library/Extensions/AppleHDA.kext
		Repair "$volume_path"/System/Library/Extensions/IOAudioFamily.kext
	
		Repair "$volume_path"/System/Library/Extensions/AppleBacklight.kext
		Repair "$volume_path"/System/Library/Extensions/AppleBacklightExpert.kext
		Repair "$volume_path"/System/Library/PrivateFrameworks/DisplayServices.framework
	
		Repair "$volume_path"/System/Library/Extensions/AppleSMCLMU.kext
	
		Repair "$volume_path"/System/Library/Extensions/IO80211Family.kext
	
		if [[ $model_airport == *$model* ]]; then
			Repair "$volume_path"/System/Library/Extensions/corecapture.kext
			Repair "$volume_path"/System/Library/Extensions/CoreCaptureResponder.kext
		fi
	
		if [[ $volume_version_short == "10.15" ]]; then
			Repair "$volume_path"/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/nvenet.kext
		fi

		if [[ $model == "MacBook4,1" ]]; then
			Repair "$volume_path"/System/Library/Extensions/IOBluetoothFamily.kext
			Repair "$volume_path"/System/Library/Extensions/IOBluetoothHIDDriver.kext
		fi
	
		Repair "$volume_path"/System/Library/PrivateFrameworks/SiriUI.framework

		if [[ $volume_version_short == "10.15" ]]; then
			Repair "$volume_path"/System/Library/Extensions/IOATAFamily.kext
		fi
	
		Repair "$volume_path"/usr/lib/SUVMMFaker.dylib
		Repair "$volume_path"/System/Library/LaunchDaemons/com.apple.softwareupdated.plist 
	
		Repair "$volume_path"/System/Library/Extensions/SIPManager.kext

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Repaired permissions."${erase_style}
}

Input_Operation_APFS()
{
	if [[ "$(diskutil info "$volume_name"|grep "APFS")" == *"APFS"* ]]; then
		if [[ $model_apfs == *$model* ]]; then
			echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! APFS incompatible model detected."${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Install the APFS patch"${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Continue without the APFS patch"${erase_style}

			Input_On
			read -e -p "$(date "+%b %m %H:%M:%S") / " operation_apfs
			Input_Off

			if [[ $operation_apfs == "1" ]]; then
				Patch_APFS
			fi

			if [[ $operation_apfs == "2" && $volume_patch_apfs == "1" ]]; then
				echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! The APFS patch is already installed."${erase_style}
				echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run the restore tool to remove it."${erase_style}
			fi
		fi
	fi
}

Patch_APFS()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Installing APFS system patch."${erase_style}

		volume_uuid="$(diskutil info "$volume_name"|grep "Volume UUID"|sed 's/.*\ //')"
	
		if [[ ! -d /Volumes/EFI/EFI/BOOT ]]; then
			mkdir -p /Volumes/EFI/EFI/BOOT
		fi
	
		cp "$resources_path"/startup.nsh /Volumes/EFI/EFI/BOOT
		cp "$resources_path"/BOOTX64.efi /Volumes/EFI/EFI/BOOT
		cp "$volume_path"/usr/standalone/i386/apfs.efi /Volumes/EFI/EFI
	
		if [[ -d "$volume_path"/Library/PreferencePanes/APFS\ Boot\ Selector.prefPane ]]; then
			rm -R "$volume_path"/Library/PreferencePanes/APFS\ Boot\ Selector.prefPane
		fi
	
		sed -i '' "s/\"volume_uuid\"/\"$volume_uuid\"/g" /Volumes/EFI/EFI/BOOT/startup.nsh
		sed -i '' "s/\"boot_file\"/\"System\\\Library\\\CoreServices\\\boot.efi\"/g" /Volumes/EFI/EFI/BOOT/startup.nsh
	
		if [[ $(diskutil info "$volume_name"|grep "Device Location"|sed 's/.*\ //') == "Internal" ]]; then
			bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/EFI/BOOT/BOOTX64.efi --shortform
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Installed APFS system patch."${erase_style}
}

Patch_Volume_Helpers()
{
	disk_identifier="$(diskutil info "$volume_name"|grep "Device Identifier"|sed 's/.*\ //')"
	disk_identifier_whole="$(diskutil info "$volume_name"|grep "Part of Whole"|sed 's/.*\ //')"

	if [[ "$(diskutil info "$volume_name"|grep "File System Personality"|sed 's/.*\ //')" == "APFS" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Preboot partition."${erase_style}

			preboot_identifier="$(diskutil info "$volume_name"|grep "Booter Disk"|sed 's/.*\ //')"
	
			if [[ ! "$(diskutil info "${preboot_identifier}"|grep "Volume Name"|sed 's/.*\ //')" == "Preboot" ]]; then
				echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Fatal error patching Preboot partition."${erase_style}

				exit
			else

				Output_Off diskutil mount "$preboot_identifier"
	
				preboot_folder="$(diskutil info "$volume_name"|grep "Volume UUID"|sed 's/.*\ //')"

				preboot_version="$(defaults read /Volumes/Preboot/"$preboot_folder"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
				preboot_version_short="$(defaults read /Volumes/Preboot/"$preboot_folder"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
				if [[ ! $volume_version == $preboot_version ]]; then
					echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Fatal error patching Preboot partition."${erase_style}

					exit
				else
					Output_Off rm /Volumes/Preboot/"$preboot_folder"/System/Library/CoreServices/PlatformSupport.plist
					Output_Off sed -i '' 's|<string></string>|<string>amfi_get_out_of_my_way=1</string>|' /Volumes/Preboot/"$preboot_folder"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
	
					Output_Off diskutil unmount /Volumes/Preboot

				echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Preboot partition."${erase_style}
			fi
		fi


		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Recovery partition."${erase_style}

			recovery_identifier="$(diskutil info "$volume_name"|grep "Recovery Disk"|sed 's/.*\ //')"
	
			if [[ ! "$(diskutil info "${recovery_identifier}"|grep "Volume Name"|sed 's/.*\ //')" == "Recovery" ]]; then
				echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Error patching Recovery partition."${erase_style}
			else

				Output_Off diskutil mount "$recovery_identifier"

				recovery_folder="$(diskutil info "$volume_name"|grep "Volume UUID"|sed 's/.*\ //')"
	
				recovery_version="$(defaults read /Volumes/Recovery/"$recovery_folder"/SystemVersion.plist ProductVersion)"
				recovery_version_short="$(defaults read /Volumes/Recovery/"$recovery_folder"/SystemVersion.plist ProductVersion | cut -c-5)"
	
				if [[ ! $volume_version == $recovery_version ]]; then
					echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Error patching Recovery partition."${erase_style}
				else

					Output_Off diskutil mount "$recovery_identifier"

					if [[ -f /Volumes/Image\ Volume/Install\ macOS\ Catalina.app/Contents/SharedSupport/BaseSystem-stock.dmg && $image_volume_version == $recovery_version ]]; then
						cp /Volumes/Image\ Volume/Install\ macOS\ Catalina.app/Contents/SharedSupport/BaseSystem-stock.dmg /Volumes/Recovery/"$recovery_folder"/BaseSystem.dmg
					fi

					chflags nouchg /Volumes/Recovery/"$recovery_folder"/prelinkedkernel
					rm /Volumes/Recovery/"$recovery_folder"/prelinkedkernel
					cp "$volume_path"/System/Library/PrelinkedKernels/prelinkedkernel /Volumes/Recovery/"$recovery_folder"/prelinkedkernel
					chflags uchg /Volumes/Recovery/"$recovery_folder"/prelinkedkernel

					Output_Off rm /Volumes/Recovery/"$recovery_folder"/PlatformSupport.plist
					Output_Off sed -i '' 's|\immutablekernel|\prelinkedkernel|' /Volumes/Recovery/"$recovery_folder"/com.apple.boot.plist
					Output_Off sed -i '' 's|dmg</string>|dmg -no_compat_check</string>|' /Volumes/Recovery/"$recovery_folder"/com.apple.boot.plist

					Output_Off diskutil apfs changeVolumeRole "$recovery_identifier" R
					Output_Off diskutil apfs updatePreboot "$recovery_identifier"

					Output_Off diskutil unmount /Volumes/Recovery
					Output_Off diskutil unmount /Volumes/Preboot

				echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Recovery partition."${erase_style}
			fi
		fi
	fi

	if [[ "$(diskutil info "$volume_name"|grep "File System Personality"|sed 's/.*\ //')" == "HFS" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Recovery partition."${erase_style}

			recovery_identifier="$(diskutil info "$volume_name"|grep "Recovery Disk"|sed 's/.*\ //')"
	
			if [[ ! "$(diskutil info "${recovery_identifier}"|grep "Volume Name"|sed 's/.*\ //')" == "Recovery HD" ]]; then
				echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Error patching Recovery partition."${erase_style}
			else

				Output_Off diskutil mount "$recovery_identifier"
				
				chflags nouchg /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
				rm /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
				cp "$volume_path"/System/Library/PrelinkedKernels/prelinkedkernel /Volumes/Recovery\ HD/com.apple.recovery.boot
				chflags uchg /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
	
				Output_Off rm /Volumes/Recovery\ HD/com.apple.recovery.boot/PlatformSupport.plist
				Output_Off sed -i '' 's|dmg</string>|dmg -no_compat_check</string>|' /Volumes/Recovery/"$recovery_folder"/com.apple.boot.plist
	
				Output_Off diskutil unmount /Volumes/Recovery\ HD

			echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Recovery partition."${erase_style}
		fi
	fi
}

End()
{
	Output_Off diskutil unmount /Volumes/EFI

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Thank you for using macOS Patcher."${erase_style}

	Input_On
	exit
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
Volume_Variables
Check_Volume_dosdude
Clean_Volume
Patch_Volume
Repair_Permissions
Input_Operation_APFS
Patch_Volume_Helpers
End