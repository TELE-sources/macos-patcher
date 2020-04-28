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

	if [[ "$model_airport" == *"$model"* ]]; then
		model_airport="1"
	fi

	if [[ "$model_apfs" == *"$model"* ]]; then
		model_apfs="1"
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
		disk_identifier_whole="$(diskutil list|grep "\<Container $disk_identifier_whole\>"|sed 's/.*\ //'|sed 's/s[0-9]*$/s/')"
		disk_identifier_efi="${disk_identifier_whole}1"
	fi
	
	if [[ "$(diskutil info "$volume_name"|grep "File System Personality"|sed 's/.*\ //')" == "HFS+" ]]; then
		disk_identifier_efi="${disk_identifier_whole}s1"
	fi

	Output_Off diskutil mount $disk_identifier_efi
}

Check_Volume_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system version."${erase_style}

		volume_version="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		volume_version_short="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
		volume_build="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

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

Input_Operation()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Remove all system patches"${erase_style}

	if [[ $volume_patch_apfs == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Remove APFS system patch"${erase_style}
	fi

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " operation_system
	Input_Off

	if [[ $operation_system == "1" ]]; then
		Clean_Volume
		Restore_Volume
	fi

	if [[ $operation_system == "2" && $volume_patch_apfs == "1" ]]; then
		Restore_APFS
	fi
}

Clean_Volume()
{
	Output_Off rm -R "$volume_path"/usr/patch

	Output_Off rm "$volume_path"/System/Library/LaunchDaemons/com.rmc.swurun.plist

	Output_Off rm "$volume_path"/usr/bin/swurun
	Output_Off rm "$volume_path"/usr/bin/swuprep
	Output_Off rm "$volume_path"/usr/bin/swupost
}

Restore_Volume()
{
	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing boot.efi patch."${erase_style}

			chflags nouchg "$volume_path"/System/Library/CoreServices/boot.efi
			rm "$volume_path"/System/Library/CoreServices/boot.efi

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed boot.efi patch."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing input drivers patch."${erase_style}

		rm -R "$volume_path"/System/Library/Extensions/LegacyUSBEthernet.kext
		rm -R "$volume_path"/System/Library/Extensions/LegacyUSBInjector.kext
		rm -R "$volume_path"/System/Library/Extensions/LegacyUSBVideoSupport.kext
		
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AppleUSBACM.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
		fi

		if [[ $volume_version_short == "10.14" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
			rm -R "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		fi
	
		if [[ $volume_version_short == "10.15" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IOHIDFamily.kext
		fi
	
		if [[ $model == "MacBook4,1" ]]; then
			rm -R  "$volume_path"/System/Library/Extensions/AppleIRController.kext
			rm -R  "$volume_path"/System/Library/Extensions/AppleMultitouchDriver.kext
			rm -R  "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
			rm -R  "$volume_path"/System/Library/Extensions/IOBDStorageFamily.kext
			rm -R  "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
			rm -R  "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
			rm -R  "$volume_path"/System/Library/Extensions/IOUSBMassStorageClass.kext
	
			rm -R  "$volume_path"/System/Library/Extensions/AppleHIDMouse.kext
			rm -R  "$volume_path"/System/Library/Extensions/AppleHSSPIHIDDriver.kext
			rm -R  "$volume_path"/System/Library/Extensions/AppleTopCase.kext
			rm -R  "$volume_path"/System/Library/Extensions/AppleUSBMultitouch.kext
			rm -R  "$volume_path"/System/Library/Extensions/IOSerialFamily.kext
		fi

		if [[ $model == "MacBook4,1" || $model == "MacBook5,2" ]]; then
			rm -R "$volume_path"/System/Library/PreferencePanes/Trackpad.prefPane
		fi

		if [[ $model == "MacBook5,2" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AppleTopCase.kext
		fi

		if [[ $volume_version_short == "10.15" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IOATAFamily.kext/Contents/PlugIns/AppleIntelPIIXATA.kext
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed input drivers patch."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing graphics drivers patch."${erase_style}

		if [[ $model == "MacPro3,1" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AAAMouSSE.kext
		fi

		if [[ $volume_version_short == "10.1"[3-5] ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX3000.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX3000GLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX4000.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX4000GLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/IOAccelerator2D.plugin
			rm -R "$volume_path"/System/Library/Extensions/IOAcceleratorFamily2.kext
		fi
	
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AMD2400Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD2600Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD3800Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD4600Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD4800Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD5000Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMD6000Controller.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDFramebuffer.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDLegacyFramebuffer.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDLegacySupport.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonVADriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonVADriver2.bundle
			rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX4000HWServices.kext
			rm -R "$volume_path"/System/Library/Extensions/AMDShared.bundle
			rm -R "$volume_path"/System/Library/Extensions/AMDSupport.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelFramebufferAzul.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelFramebufferCapri.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHD3000Graphics.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsGA.plugin
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsGLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHD3000GraphicsVADriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHDGraphics.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsFB.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsGA.plugin
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsGLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelHDGraphicsVADriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelSNBGraphicsFB.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelSNBVA.bundle
			rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX2000.kext
			rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX2000GA.plugin
			rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX2000GLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX2000VADriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/GeForceTesla.kext
			rm -R "$volume_path"/System/Library/Extensions/GeForceTeslaGLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/GeForceTeslaVADriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/IOGraphicsFamily.kext
			rm -R "$volume_path"/System/Library/Extensions/IONDRVSupport.kext
			rm -R "$volume_path"/System/Library/Extensions/NVDANV50HalTesla.kext
			rm -R "$volume_path"/System/Library/Extensions/NVDAResmanTesla.kext
		fi

		if [[ $volume_version_short == "10.14" ]] && [[ ! $model == "MacBook4,1" ]]; then
			rm -R "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
		fi
	
		if [[ $volume_version == "10.14."[4-6] || $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]]; then
			rm "$volume_path"/System/Library/PrivateFrameworks/GPUSupport.framework/Versions/A/Libraries/libGPUSupport.dylib
			rm -R "$volume_path"/System/Library/Frameworks/OpenGL.framework
		fi
	
		if [[ $volume_version == "10.14."[5-6] ]] && [[ ! $model == "MacBook4,1" ]]; then
			rm -R "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
		fi
	
		if [[ $volume_version_short == "10.15" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IOSurface.kext
		fi

		if [[ $volume_version_short == "10.15" ]] && [[ ! $model == "MacBook4,1" ]]; then
			rm -R "$volume_path"/System/Library/Frameworks/CoreDisplay.framework
			rm -R "$volume_path"/System/Library/PrivateFrameworks/SkyLight.framework
		fi
	
		if [[ $model == "MacBook4,1" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100FB.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GA.plugin
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GLDriver.bundle
			rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100VADriver.bundle
		fi
	
		if [[ $model == "MacBookPro6,2" ]] && [[ $volume_version == "10.14."[5-6] || $volume_version_short == "10.15" ]]; then
			rm -R "$volume_path"/System/Library/Extensions/AppleGraphicsControl.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleGraphicsPowerManagement.kext
			rm -R "$volume_path"/System/Library/Extensions/AppleMCCSControl.kext
			rm -R "$volume_path"/System/Library/PrivateFrameworks/GPUWrangler.framework
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed graphics drivers patch."${erase_style}


	if [[ $volume_version == "10.15."[4-6] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing monitor preferences patch."${erase_style}

			rm -R "$volume_path"/System/Library/PrivateFrameworks/MonitorPanel.framework
			rm -R "$volume_path"/System/Library/MonitorPanels

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed monitor preferences patch."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing audio drivers patch."${erase_style}

		rm -R "$volume_path"/System/Library/Extensions/AppleHDA.kext
		rm -R "$volume_path"/System/Library/Extensions/IOAudioFamily.kext

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed audio drivers patch."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing backlight drivers patch."${erase_style}

		rm -R "$volume_path"/System/Library/Extensions/AppleBacklight.kext
		rm -R "$volume_path"/System/Library/Extensions/AppleBacklightExpert.kext
		rm -R "$volume_path"/System/Library/PrivateFrameworks/DisplayServices.framework

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed backlight drivers patch."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing ambient light sensor drivers patch."${erase_style}

		rm -R "$volume_path"/System/Library/Extensions/AppleSMCLMU.kext/Contents/PlugIns/AmbientLightSensorHID.plugin

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed ambient light sensor drivers patch."${erase_style}
	

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing AirPort drivers patch."${erase_style}

		if [[ $volume_version_short == "10.15" ]]; then 
			rm -R "$volume_path"/System/Library/Extensions/IO80211Family.kext
		fi
		
		if [[ $volume_version_short == "10.1"[4-5] ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IO80211Family.kext/Contents/PlugIns/AirPortAtheros40.kext
		fi
		
		if [[ $model_airport == *$model* ]]; then
			rm -R "$volume_path"/System/Library/Extensions/IO80211Family.kext
			rm -R "$volume_path"/System/Library/Extensions/corecapture.kext
			rm -R "$volume_path"/System/Library/Extensions/CoreCaptureResponder.kext
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed AirPort drivers patch."${erase_style}


	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing Ethernet drivers patch."${erase_style}

			rm -R "$volume_path"/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/nvenet.kext
			rm -R "$volume_path"/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/AppleYukon2.kext

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed Ethernet drivers patch."${erase_style}
	fi


	if [[ $model == "MacBook4,1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing Bluetooth drivers patch."${erase_style}

			rm -R "$volume_path"/System/Library/Extensions/IOBluetoothFamily.kext
			rm -R "$volume_path"/System/Library/Extensions/IOBluetoothHIDDriver.kext

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed Bluetooth drivers patch."${erase_style}
	fi


	if [[ $volume_version == "10.14."[4-6] || $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing Siri application patch."${erase_style}

			rm -R "$volume_path"/System/Library/PrivateFrameworks/SiriUI.framework

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed Siri application patch."${erase_style}
	fi


	if [[ $volume_version_short == "10.1"[4-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing News+ patch."${erase_style}
	
			if [[ $(grep "/System/Library/Frameworks/OpenCL.framework" "$volume_path"/System/iOSSupport/dyld/macOS-whitelist.txt) == "/System/Library/Frameworks/OpenCL.framework" ]]; then
   	 			sed -i '' 's|/System/Library/Frameworks/OpenCL.framework||' "$volume_path"/System/iOSSupport/dyld/macOS-whitelist.txt
			fi
	
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed News+ patch."${erase_style}
	fi


	if [[ $volume_version_short == "10.15" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing Japanesse input method patch."${erase_style}

			rm -R "$volume_path"/usr/lib/libmecabra.dylib
			rm -R "$volume_path"/System/Library/PrivateFrameworks/TextInput.framework
			rm -R "$volume_path"/System/Library/Input\ Methods/JapaneseIM.app

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed Japanesse input method patch."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing software update check patch."${erase_style}

		rm "$volume_path"/usr/lib/SUVMMFaker.dylib
		rm "$volume_path"/System/Library/LaunchDaemons/com.apple.softwareupdated.plist

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed software update check patch."${erase_style}


	if [[ $volume_version_short == "10.1"[4-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing kernel panic patch."${erase_style}

			rm -R "$volume_path"/System/Library/Extensions/AAAtelemetrap.kext

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed kernel panic patch."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing System Integrity Protection patch."${erase_style}

		rm -R "$volume_path"/System/Library/Extensions/SIPManager.kext

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed System Integrity Protection patch."${erase_style}
}

Restore_APFS()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing APFS system patch."${erase_style}

		rm /Volumes/EFI/EFI/BOOT/startup.nsh
		rm /Volumes/EFI/EFI/BOOT/BOOTX64.efi
		rm /Volumes/EFI/EFI/apfs.efi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed APFS system patch."${erase_style}
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
Input_Model
Input_Volume
Mount_EFI
Check_Volume_Version
Check_Volume_Support
Volume_Variables
Check_Volume_dosdude
Input_Operation
End