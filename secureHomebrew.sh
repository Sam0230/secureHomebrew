if [ "$(/usr/bin/arch)" != "arm64" ]; then
	echo "Currently only macOS on Apple Silicon is supported. Failed."
	exit
fi
APFSContainerRefDisk="$(sudo diskutil info -plist / | grep 'APFSContainerReference' -A 1  | sed '1d' | sed -E 's/\<\/?string\>//g' | sed 's/\t//g')"
password="$(uuidgen)-$(uuidgen)"
diskLable="$(sudo diskutil apfs addVolume "$APFSContainerRefDisk" APFSX Homebrew -passphrase "$password" -nomount | grep 'Disk from APFS operation: '"$APFSContainerRefDisk"'s' | sed 's/Disk from APFS operation: //')"
diskUUID="$(diskutil info -plist "$diskLable" | grep 'DiskUUID' -A 1  | sed '1d' | sed -E 's/\<\/?string\>//g' | sed 's/\t//g')"
sudo diskutil umount force /opt/homebrew 2>/dev/null
sudo diskutil umount force /opt/homebrew 2>/dev/null
sudo rm -rf /opt/homebrew
sudo dscl . -delete /Users/_homebrew >/dev/null 2>/dev/null
sudo dscl . -delete /Groups/_homebrew >/dev/null 2>/dev/null
sudo dscl . -create /Users/_homebrew
sudo dscl . -delete /Users/_homebrew dsAttrTypeNative:accountPolicyData
sudo dscl . -delete /Users/_homebrew dsAttrTypeNative:record_daemon_version
sudo dscl . -create /Users/_homebrew NFSHomeDirectory /opt/homebrew/brewaccounthome
sudo dscl . -create /Users/_homebrew PrimaryGroupID 290
sudo dscl . -create /Users/_homebrew RealName Homebrew
sudo dscl . -create /Users/_homebrew UniqueID 290
sudo dscl . -create /Users/_homebrew UserShell /usr/bin/false
sudo dscl . -delete /Users/_homebrew dsAttrTypeNative:accountPolicyData
sudo dscl . -delete /Users/_homebrew dsAttrTypeNative:record_daemon_version
sudo dscl . -create /Groups/_homebrew
sudo dscl . -delete /Groups/_homebrew dsAttrTypeNative:accountPolicyData
sudo dscl . -delete /Groups/_homebrew dsAttrTypeNative:record_daemon_version
sudo dscl . -create /Groups/_homebrew PrimaryGroupID 290
sudo dscl . -create /Groups/_homebrew RealName Homebrew
sudo dscl . -delete /Groups/_homebrew dsAttrTypeNative:accountPolicyData
sudo dscl . -delete /Groups/_homebrew dsAttrTypeNative:record_daemon_version
sudo diskutil apfs unlockVolume "$diskUUID" -passphrase "$password" -nomount >/dev/null 2>/dev/null
sudo rm -rf /opt/homebrew
sudo mkdir /opt/homebrew
sudo diskutil mount nobrowse -mountOptions nobrowse,noowners,-u=290,-g=290 -mountPoint /opt/homebrew "$diskUUID" >/dev/null
sudo mkdir /opt/homebrew/brewaccounthome
# echo $'#include <stdlib.h>\n#include <unistd.h>\n#include <errno.h>\n\nint main(int argc, char * argv[]) {\n\tint uid=atoi(argv[1]), gid=atoi(argv[2]);\n\tif (setregid(gid, gid)) {\n\t\treturn errno;\n\t}\n\tif (setreuid(uid, uid)) {\n\t\treturn errno;\n\t}\n\tif (execvp(argv[3], argv + 4)) {\n\t\treturn errno;\n\t}\n\treturn -1;\n}' | sudo gcc -x c -o /opt/homebrew/setugid -
echo $'#!/bin/sh\numask 002\nPATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"\nexec sudo sudo -u _homebrew -- "$@"' | sudo tee /opt/homebrew/enterbrewenv_raw >/dev/null
sudo chmod 755 /opt/homebrew/enterbrewenv_raw
sudo tee /opt/homebrew/enterbrewenv >/dev/null <<__END__
#!/bin/sh
eval "\$1"
precmd="\$2"
shift
shift
exec /opt/homebrew/enterbrewenv_raw /bin/sh -c '
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin"
mkdir -p /opt/homebrew/var/tmp
export HOMEBREW_TEMP=/opt/homebrew/var/tmp
unset SUDO_COMMAND
umask 0002
envWarn=0
if [ "\$1"		!= "" ]; then envWarn=1; printf "Warning: http_proxy has been set!\n%s\n" "http_proxy=\$1"; 								export http_proxy="\$1"					; fi
if [ "\$2"		!= "" ]; then envWarn=1; printf "Warning: https_proxy has been set!\n%s\n" "https_proxy=\$2"; 								export https_proxy="\$2"					; fi
if [ "\$3"		!= "" ]; then envWarn=1; printf "Warning: ftp_proxy has been set!\n%s\n" "ftp_proxy=\$3"; 									export ftp_proxy="\$3"					; fi
if [ "\$4"		!= "" ]; then envWarn=1; printf "Warning: telnet_proxy has been set!\n%s\n" "telnet_proxy=\$4"; 							export telnet_proxy="\$4"				; fi
if [ "\$5"		!= "" ]; then envWarn=1; printf "Warning: all_proxy has been set!\n%s\n" "all_proxy=\$5"; 								export all_proxy="\$5"					; fi
if [ "\$6"		!= "" ]; then envWarn=1; printf "Warning: HTTP_PROXY has been set!\n%s\n" "HTTP_PROXY=\$6"; 								export HTTP_PROXY="\$6"					; fi
if [ "\$7"		!= "" ]; then envWarn=1; printf "Warning: HTTPS_PROXY has been set!\n%s\n" "HTTPS_PROXY=\$7"; 								export HTTPS_PROXY="\$7"					; fi
if [ "\$8"		!= "" ]; then envWarn=1; printf "Warning: FTP_PROXY has been set!\n%s\n" "FTP_PROXY=\$8"; 									export FTP_PROXY="\$8"					; fi
if [ "\$9"		!= "" ]; then envWarn=1; printf "Warning: TELNET_PROXY has been set!\n%s\n" "TELNET_PROXY=\$9"; 							export TELNET_PROXY="\$9"				; fi
if [ "\${10}"	!= "" ]; then envWarn=1; printf "Warning: ALL_PROXY has been set!\n%s\n" "ALL_PROXY=\${10}"; 							export ALL_PROXY="\${10}"				; fi
if [ "\${11}"	!= "" ]; then envWarn=1; printf "Warning: HOMEBREW_BOTTLE_DOMAIN is set!\n%s\n" "HOMEBREW_BOTTLE_DOMAIN=\${11}";		export HOMEBREW_BOTTLE_DOMAIN="\${11}"	; fi
if [ "\${12}"	!= "" ]; then envWarn=1; printf "Warning: HOMEBREW_BREW_GIT_REMOTE is set!\n%s\n" "HOMEBREW_BREW_GIT_REMOTE=\${12}";	export HOMEBREW_BREW_GIT_REMOTE="\${12}"	; fi
if [ "\${13}"	!= "" ]; then envWarn=1; printf "Warning: HOMEBREW_CORE_GIT_REMOTE is set!\n%s\n" "HOMEBREW_CORE_GIT_REMOTE=\${13}";	export HOMEBREW_CORE_GIT_REMOTE="\${13}"	; fi
if [ "\$envWarn" == "1" ]; then
	read -p "Continue? (Y/n) " cont
	if [ "\$cont" == "n" -o "\$cont" == "N" ]; then
		exit
	fi
fi
eval "\${14}"
shift
shift
shift
shift
shift
shift
shift
shift
shift
shift
shift
shift
shift
shift
exec -- "\$@"
' - "\$http_proxy" "\$https_proxy" "\$ftp_proxy" "\$telnet_proxy" "\$all_proxy" "\$HTTP_PROXY" "\$HTTPS_PROXY" "\$FTP_PROXY" "\$TELNET_PROXY" "\$ALL_PROXY" "\$HOMEBREW_BOTTLE_DOMAIN" "\$HOMEBREW_BREW_GIT_REMOTE" "\$HOMEBREW_CORE_GIT_REMOTE" "\$precmd" "\$@"
__END__
sudo chmod 755 /opt/homebrew/enterbrewenv
echo $'#!/bin/sh\nexec /opt/homebrew/enterbrewenv "cd /opt/homebrew/brewaccounthome" "" /opt/homebrew/bin/brew "$@"' | sudo tee /opt/homebrew/sbrew >/dev/null
sudo chmod 755 /opt/homebrew/sbrew
sudo sh -c "echo '_homebrew:*:290:290:Homebrew:/opt/homebrew/brewaccounthome:/usr/bin/false' >>/etc/passwd"
sudo sh -c "echo '_homebrew:*:290:_homebrew' >>/etc/group"
sudo sh -c "echo '_homebrew ALL = (ALL) NOPASSWD:ALL' >/etc/sudoers.d/homebrew_account"
sudo touch /usr/local/mnthbvol
sudo chmod 700 /usr/local/mnthbvol
echo $'#!/bin/sh\nsudo diskutil apfs unlockVolume "'"$diskUUID"'" -passphrase "'"$password"$'" -nomount >/dev/null 2>/dev/null\nsudo diskutil mount nobrowse -mountOptions nobrowse,noowners,-u=290,-g=290 -mountPoint /opt/homebrew "'"$diskUUID"'" >/dev/null' | sudo tee /usr/local/mnthbvol >/dev/null
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>nonexist.sam0230.securehomebrew</string>
	<key>Program</key>
	<string>/usr/local/mnthbvol</string>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>' | sudo tee /Library/LaunchDaemons/nonexist.sam0230.securehomebrew.plist >/dev/null
echo 'Now `/opt/homebrew/enterbrewenv "cd /opt/homebrew/brewaccounthome" "" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"` to begin Homebrew installation.'
