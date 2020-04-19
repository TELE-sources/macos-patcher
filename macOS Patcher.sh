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

	if [[ $parameters == *"-unus"* ]]; then
		catalina_unus="1"
	fi
}

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"

	resources_path="$directory_path/resources"
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

Input_Operation()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Patch installer"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Patch update"${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " operation
	Input_Off

	if [[ $operation == "1" ]]; then
		Input_Installer
		Check_Installer_Stucture
		Check_Installer_Version
		Check_Installer_Support
		Installer_Variables
		Input_Volume

		if [[ $installer_version_short == "10.1"[2-4] ]]; then
			Create_Installer
			Patch_Installer
		fi

		if [[ $installer_version_short == "10.15" && ! $catalina_unus == "1" ]]; then
			Modern_Installer
		fi

		if [[ $installer_version_short == "10.15" && $catalina_unus == "1" ]]; then
			Download_Unus
			Create_Installer
			Patch_Installer
		fi
	fi

	if [[ $operation == "2" ]]; then
		Input_Package
		Patch_Package
	fi
}

Input_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What installer would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an installer path."${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " installer_application_path
	Input_Off

	installer_application_name="${installer_application_path##*/}"
	installer_application_name_partial="${installer_application_name%.app}"

	installer_sharedsupport_path="$installer_application_path/Contents/SharedSupport"
}

Check_Installer_Stucture()
{
	Output_Off hdiutil attach "$installer_sharedsupport_path"/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse -noverify

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking installer structure."${erase_style}

		if [[ -e /tmp/InstallESD/BaseSystem.dmg ]]; then
			installer_images_path="/tmp/InstallESD"
		fi
		if [[ -e "$installer_sharedsupport_path"/BaseSystem.dmg ]]; then
			installer_images_path="$installer_sharedsupport_path"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked installer structure."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Mounting installer disk images."${erase_style}

		Output_Off hdiutil attach "$installer_images_path"/BaseSystem.dmg -mountpoint /tmp/Base\ System -nobrowse -noverify

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Mounted installer disk images."${erase_style}
}

Check_Installer_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking installer version."${erase_style}

		installer_version="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		installer_version_short="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked installer version."${erase_style}	
}

Check_Installer_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking installer support."${erase_style}

	if [[ $installer_version_short == "10.1"[2-4] || $installer_version == "10.15" || $installer_version == "10.15."[1-4] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Installer support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Installer support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with a supported installer."${erase_style}

		Input_On
		exit
	fi
}

Installer_Variables()
{
	if [[ $installer_version_short == "10.1"[2-5] || $installer_version == "10.13."[1-3] ]]; then
		installer_prelinkedkernel="$installer_version_short"
	fi

	if [[ $installer_version == "10.12."[1-3] || $installer_version == "10.14."[1-3] ]]; then
		installer_prelinkedkernel="$installer_version_short.1"
	fi

	if [[ $installer_version == "10.12."[4-6] || $installer_version == "10.13."[4-6] || $installer_version == "10.14."[4-6] ]]; then
		installer_prelinkedkernel="$installer_version_short.4"
	fi

	if [[ $installer_version_short == "10.15" && $catalina_unus == "1" ]]; then
		installer_prelinkedkernel="10.14.4"
	fi

	installer_prelinkedkernel_path="$resources_path/prelinkedkernel/$installer_prelinkedkernel"
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
	read -e -p "$(date "+%b %m %H:%M:%S") / " installer_volume_name
	Input_Off

	installer_volume_path="/Volumes/$installer_volume_name"
}

Download_Unus()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Downloading Catalina Unus."${erase_style}

		curl -L -s -o /tmp/catalina-unus.zip https://github.com/rmc-team/catalina-unus/archive/master.zip
		unzip -q /tmp/catalina-unus.zip -d /tmp
	
		unus_resources_path="/tmp/catalina-unus-master/resources"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Downloaded Catalina Unus."${erase_style}
}

Create_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Restoring installer disk image."${erase_style}

		if [[ $installer_version_short == "10.15" && $catalina_unus == "1" ]]; then
			Output_Off asr restore -source "$unus_resources_path"/UnusSystem.dmg -target "$installer_volume_path" -noprompt -noverify -erase
		else
			Output_Off asr restore -source "$installer_images_path"/BaseSystem.dmg -target "$installer_volume_path" -noprompt -noverify -erase
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Restored installer disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Renaming installer volume."${erase_style}

		Output_Off diskutil rename /Volumes/*Base\ System "$installer_volume_name"
		bless --folder "$installer_volume_path"/System/Library/CoreServices --label "$installer_volume_name"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Renamed installer volume."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer packages."${erase_style}

		rm "$installer_volume_path"/System/Installation/Packages
		cp -R /tmp/InstallESD/Packages "$installer_volume_path"/System/Installation/

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer packages."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer disk images."${erase_style}

		cp "$installer_images_path"/BaseSystem.dmg "$installer_volume_path"/
		cp "$installer_images_path"/BaseSystem.chunklist "$installer_volume_path"/
	
		if [[ -e "$installer_images_path"/AppleDiagnostics.dmg ]]; then
			cp "$installer_images_path"/AppleDiagnostics.dmg "$installer_volume_path"/
			cp "$installer_images_path"/AppleDiagnostics.chunklist "$installer_volume_path"/
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer disk images."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Unmounting installer disk images."${erase_style}

		Output_Off hdiutil detach /tmp/InstallESD
		Output_Off hdiutil detach /tmp/Base\ System

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Unmounted installer disk images."${erase_style}
}

Patch_Installer()
{
	if [[ $installer_version_short == "10.1"[3-4] ]]; then
		Patch_Supported
	fi

	Patch_Unsupported
}

Patch_Supported()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Replacing installer utilities menu."${erase_style}

		cp "$resources_path"/InstallerMenuAdditions.plist "$installer_volume_path"/System/Installation/CDIS/*Installer.app/Contents/Resources

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Replacing installer utilities menu."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer app."${erase_style}

		cp -R "$installer_volume_path"/System/Installation/CDIS/macOS\ Installer.app "$installer_volume_path"/tmp/macOS\ Installer-original.app
		cp -R "$resources_path"/macOS\ Installer.app "$installer_volume_path"/tmp/macOS\ Installer-patched.app
		cp "$installer_volume_path"/tmp/macOS\ Installer-original.app/Contents/Resources/X.tiff "$installer_volume_path"/tmp/macOS\ Installer-patched.app/Contents/Resources/
		cp "$installer_volume_path"/tmp/macOS\ Installer-original.app/Contents/Resources/OSXTheme.car "$installer_volume_path"/tmp/macOS\ Installer-patched.app/Contents/Resources/
		cp "$installer_volume_path"/tmp/macOS\ Installer-original.app/Contents/Resources/ReleaseNameTheme.car "$installer_volume_path"/tmp/macOS\ Installer-patched.app/Contents/Resources/
		cp "$installer_volume_path"/tmp/macOS\ Installer-original.app/Contents/Resources/InstallerMenuAdditions.plist "$installer_volume_path"/tmp/macOS\ Installer-patched.app/Contents/Resources/
		rm -R "$installer_volume_path"/System/Installation/CDIS/macOS\ Installer.app
		cp -R "$installer_volume_path"/tmp/macOS\ Installer-patched.app "$installer_volume_path"/System/Installation/CDIS/macOS\ Installer.app

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer app."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer framework."${erase_style}

		rm -R "$installer_volume_path"/System/Library/PrivateFrameworks/OSInstaller.framework
		cp -R "$resources_path"/OSInstaller.framework "$installer_volume_path"/System/Library/PrivateFrameworks/

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer framework."${erase_style}


	if [[ $installer_version_short == "10.1"[4-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching system migration frameworks."${erase_style}

			rm -R "$installer_volume_path"/System/Library/PrivateFrameworks/SystemMigration.framework
			rm -R "$installer_volume_path"/System/Library/PrivateFrameworks/SystemMigrationUtils.framework
			cp -R "$resources_path"/SystemMigration.framework "$installer_volume_path"/System/Library/PrivateFrameworks/
			cp -R "$resources_path"/SystemMigrationUtils.framework "$installer_volume_path"/System/Library/PrivateFrameworks/

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched system migration frameworks."${erase_style}
	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching graphics driver."${erase_style}

		cp -R "$installer_volume_path"/System/Library/Frameworks/Quartz.framework "$installer_volume_path"/tmp/Quartz-original.framework
		cp -R "$resources_path"/Quartz.framework "$installer_volume_path"/tmp/Quartz-patched.framework
		rm -R "$installer_volume_path"/tmp/Quartz-patched.framework/Versions/A/Frameworks/QuickLookUI.framework
		cp -R "$installer_volume_path"/tmp/Quartz-original.framework/Versions/A/Frameworks/QuickLookUI.framework "$installer_volume_path"/tmp/Quartz-patched.framework/Versions/A/Frameworks/
		rm -R "$installer_volume_path"/System/Library/Frameworks/Quartz.framework
		cp -R "$installer_volume_path"/tmp/Quartz-patched.framework "$installer_volume_path"/System/Library/Frameworks/Quartz.framework

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched graphics driver."${erase_style}
}

Patch_Unsupported()
{
	if [[ $installer_version_short == "10.12" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer framework."${erase_style}

			rm -R "$installer_volume_path"/System/Library/PrivateFrameworks/OSInstaller.framework
			cp -R "$resources_path"/OSInstaller.framework "$installer_volume_path"/System/Library/PrivateFrameworks/

		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer framework."${erase_style}

	fi


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer package."${erase_style}

		cp "$installer_volume_path"/System/Installation/Packages/OSInstall.mpkg "$installer_volume_path"/tmp
		pkgutil --expand "$installer_volume_path"/tmp/OSInstall.mpkg "$installer_volume_path"/tmp/OSInstall
		sed -i '' 's/cpuFeatures\[i\] == "VMM"/1 == 1/' "$installer_volume_path"/tmp/OSInstall/Distribution
		sed -i '' 's/nonSupportedModels.indexOf(currentModel)&gt;= 0/1 == 0/' "$installer_volume_path"/tmp/OSInstall/Distribution
		sed -i '' 's/boardIds.indexOf(boardId)== -1/1 == 0/' "$installer_volume_path"/tmp/OSInstall/Distribution
		pkgutil --flatten "$installer_volume_path"/tmp/OSInstall "$installer_volume_path"/tmp/OSInstall.mpkg
		cp "$installer_volume_path"/tmp/OSInstall.mpkg "$installer_volume_path"/System/Installation/Packages

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer package."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching input drivers."${erase_style}

		cp -R "$resources_path"/patch/LegacyUSBInjector.kext "$installer_volume_path"/System/Library/Extensions

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched input drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching platform support check."${erase_style}

		rm "$installer_volume_path"/System/Library/CoreServices/PlatformSupport.plist

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel cache."${erase_style}
	
		chflags nouchg "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		rm "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		cp "$installer_prelinkedkernel_path"/prelinkedkernel "$installer_volume_path"/System/Library/PrelinkedKernels
		chflags uchg "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
	
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel cache."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching System Integrity Protection."${erase_style}

		cp -R "$resources_path"/patch/SIPManager.kext "$installer_volume_path"/System/Library/Extensions

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched System Integrity Protection."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying patcher utilities."${erase_style}

		cp -R "$resources_path"/patch "$installer_volume_path"/
		cp "$resources_path"/patch.sh "$installer_volume_path"/usr/bin/patch
		cp "$resources_path"/restore.sh "$installer_volume_path"/usr/bin/restore
		chmod +x "$installer_volume_path"/usr/bin/patch
		chmod +x "$installer_volume_path"/usr/bin/restore

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied patcher utilities."${erase_style}
}

Modern_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Unmounting installer disk images."${erase_style}

		Output_Off hdiutil detach /tmp/Base\ System
		Output_Off hdiutil detach /tmp/InstallESD

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Unmounted installer disk images."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Creating installer disk."${erase_style}

		export installer_application_path
		export installer_volume_name

		chmod +x "$resources_path"/openinstallmedia.sh
		Output_Off "$resources_path"/openinstallmedia.sh -v

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Created installer disk."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Renaming installer volume."${erase_style}

		Output_Off diskutil rename /Volumes/"$installer_application_name_partial" "$installer_volume_name"
		bless --folder "$installer_volume_path"/System/Library/CoreServices --label "$installer_volume_name"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Renamed installer volume."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Mounting BaseSystem disk image."${erase_style}
	
		Output_Off hdiutil attach -owners on "$installer_sharedsupport_path"/BaseSystem.dmg -mountpoint /tmp/Base\ System -nobrowse -noverify -shadow

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Mounting BaseSystem disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer files."${erase_style}

		cp "$resources_path"/brtool /tmp/Base\ System/usr/libexec
		cp "$resources_path"/OSInstaller /tmp/Base\ System/System/Library/PrivateFrameworks/OSInstaller.framework/Versions/A
		cp "$resources_path"/OSInstallerSetupInternal /tmp/Base\ System/"$installer_application_name"/Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Frameworks/OSInstallerSetupInternal.framework/Versions/A
		cp "$resources_path"/OSInstallerSetupInternal "$installer_volume_path"/"$installer_application_name"/Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Frameworks/OSInstallerSetupInternal.framework/Versions/A
		cp "$resources_path"/osishelperd /tmp/Base\ System/"$installer_application_name"/Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Resources
		cp "$resources_path"/osishelperd "$installer_volume_path"/"$installer_application_name"/Contents/Frameworks/OSInstallerSetup.framework/Versions/A/Resources
		cp -R "$resources_path"/DisableLibraryValidation.kext /tmp/Base\ System/System/Library/Extensions
		
		cp "$resources_path"/apfsprep.sh /tmp/Base\ System/sbin/apfsprep
		chmod +x /tmp/Base\ System/sbin/apfsprep

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer files."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching input drivers."${erase_style}

		cp -R "$resources_path"/patch/LegacyUSBInjector.kext /tmp/Base\ System/System/Library/Extensions

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched input drivers."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching platform support check."${erase_style}

		Output_Off sed -i '' 's|BaseSystem.dmg</string>|BaseSystem.dmg -no_compat_check</string>|' /tmp/Base\ System/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
		Output_Off sed -i '' 's|BaseSystem.dmg</string>|BaseSystem.dmg -no_compat_check</string>|' "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.boot.plist
		
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel cache."${erase_style}
	
		chflags nouchg /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel
		rm /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel
		cp "$installer_prelinkedkernel_path"/prelinkedkernel /tmp/Base\ System/System/Library/PrelinkedKernels
		chflags uchg /tmp/Base\ System/System/Library/PrelinkedKernels/prelinkedkernel

		chflags nouchg "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		rm "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		cp "$installer_prelinkedkernel_path"/prelinkedkernel "$installer_volume_path"/System/Library/PrelinkedKernels
		chflags uchg "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
	
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel cache."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching System Integrity Protection."${erase_style}

		cp -R "$resources_path"/patch/SIPManager.kext /tmp/Base\ System/System/Library/Extensions

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched System Integrity Protection."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying patcher utilities."${erase_style}

		cp -R "$resources_path"/patch "$installer_volume_path"
		cp "$resources_path"/patch.sh /tmp/Base\ System/usr/bin/patch
		cp "$resources_path"/restore.sh /tmp/Base\ System/usr/bin/restore
		chmod +x /tmp/Base\ System/usr/bin/patch
		chmod +x /tmp/Base\ System/usr/bin/restore

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied patcher utilities."${erase_style}

	
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Unmounting BaseSystem disk image."${erase_style}

		Output_Off hdiutil detach /tmp/Base\ System

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Unmounted BaseSystem disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Converting BaseSystem disk image."${erase_style}
	
		mv "$installer_volume_path"/"$installer_application_name"/Contents/SharedSupport/BaseSystem.dmg "$installer_volume_path"/"$installer_application_name"/Contents/SharedSupport/BaseSystem-stock.dmg
		Output_Off hdiutil convert -format UDZO "$installer_sharedsupport_path"/BaseSystem.dmg -o "$installer_volume_path"/"$installer_application_name"/Contents/SharedSupport/BaseSystem.dmg -shadow

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Converted BaseSystem disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Mounting InstallESD disk image."${erase_style}

		Output_Off hdiutil attach -owners on "$installer_sharedsupport_path"/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse -noverify -shadow

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Mounted InstallESD disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer package."${erase_style}

		cp /tmp/InstallESD/Packages/OSInstall.mpkg /tmp
		pkgutil --expand /tmp/OSInstall.mpkg /tmp/OSInstall
		sed -i '' 's/cpuFeatures\[i\] == "VMM"/1 == 1/' /tmp/OSInstall/Distribution
		sed -i '' 's/nonSupportedModels.indexOf(currentModel)&gt;= 0/1 == 0/' /tmp/OSInstall/Distribution
		sed -i '' 's/boardIds.indexOf(boardId)== -1/1 == 0/' /tmp/OSInstall/Distribution
		pkgutil --flatten /tmp/OSInstall /tmp/OSInstall.mpkg
		cp /tmp/OSInstall.mpkg /tmp/InstallESD/Packages

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer package."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Unmounting InstallESD disk image."${erase_style}

		Output_Off hdiutil detach /tmp/InstallESD

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Unmounted InstallESD disk image."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Converting InstallESD disk image."${erase_style}
	
		rm "$installer_volume_path"/"$installer_application_name"/Contents/SharedSupport/InstallESD.dmg
		Output_Off hdiutil convert -format UDZO "$installer_sharedsupport_path"/InstallESD.dmg -o "$installer_volume_path"/"$installer_application_name"/Contents/SharedSupport/InstallESD.dmg -shadow

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Converting InstallESD disk image."${erase_style}
}

Input_Package()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What update would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an update path."${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " package_path
	Input_Off

	package_folder="${package_path%.*}"
}

Patch_Package()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Expanding update package."${erase_style}

		pkgutil --expand "$package_path" "$package_folder"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Expanded update package."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching update package."${erase_style}

		sed -i '' 's|<pkg-ref id="com\.apple\.pkg\.FirmwareUpdate" auth="Root" packageIdentifier="com\.apple\.pkg\.FirmwareUpdate">#FirmwareUpdate\.pkg<\/pkg-ref>||' "$package_folder"/Distribution
		sed -i "" "s/my.target.filesystem &amp;&amp; my.target.filesystem.type == 'hfs'/1 == 0/" "$package_folder"/Distribution
		sed -i '' 's/cpuFeatures\[i\] == "VMM"/1 == 1/' "$package_folder"/Distribution
		sed -i '' 's/nonSupportedModels.indexOf(currentModel)&gt;= 0/1 == 0/' "$package_folder"/Distribution
		sed -i '' 's/boardIds.indexOf(boardId)== -1/1 == 0/' "$package_folder"/Distribution

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched update package."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing update package."${erase_style}

		pkgutil --flatten "$package_folder" "$package_path"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared update package."${erase_style}


	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}

		Output_Off rm -R "$package_folder"

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}
}

End()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}

		Output_Off rm -R "$installer_volume_path"/tmp/macOS\ Installer-original.app
		Output_Off rm -R "$installer_volume_path"/tmp/macOS\ Installer-patched.app

		Output_Off rm -R "$installer_volume_path"/tmp/Quartz-original.framework
		Output_Off rm -R "$installer_volume_path"/tmp/Quartz-patched.framework

		Output_Off rm -R "$installer_volume_path"/tmp/OSInstall
		Output_Off rm -R "$installer_volume_path"/tmp/OSInstall.mpkg


		if [[ $installer_version_short == "10.15" && ! $catalina_unus == "1" ]]; then
			Output_Off rm -R /tmp/OSInstall
			Output_Off rm -R /tmp/OSInstall.mpkg

			rm "$installer_sharedsupport_path"/BaseSystem.dmg.shadow
			rm "$installer_sharedsupport_path"/InstallESD.dmg.shadow
		fi

		if [[ $installer_version_short == "10.15" && $catalina_unus == "1" ]]; then
			Output_Off rm -R "$installer_volume_path"/tmp/OSInstall
			Output_Off rm -R "$installer_volume_path"/tmp/OSInstall.mpkg
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}


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
Check_Resources
Input_Operation
End