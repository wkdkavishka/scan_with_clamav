#!/bin/sh
#
# Authors: Fabio Mucciante
# Created: 2021/08/31
# Updated: 2024/05/13
# Version: 1.2.0
# License: GPL-v3
#
# References:
#   - https://freeaptitude.altervista.org/projects/kde-servicemenus.html
#   - https://github.com/fabiomux/kde-servicemenus

log_file='./uninstall.log'
dest_folder=''
desktop_filename='scan_with_clamav.desktop'
kde_version=''

echo '[=] Started to uninstall scan_with_clamav' | tee $log_file

if [ -n "$(command -v plasmashell)" ]; then
  kde_version="Plasma $(plasmashell -v | cut -d ' ' -f 2 | cut -d '.' -f 1)"
elif [ -n "$(command -v kf5-config)" ]; then
  kde_version='Plasma 5'
elif [ -n "$(command -v kde4-config)" ]; then
  kde_version='KDE 4'
elif [ -n "$(command -v qtpaths6)" ]; then
  kde_version='Plasma 6'
else
  echo '[X] Unable to find the Service Menus path!' | tee -a $log_file
  exit 1
fi

case $kde_version in
'KDE 4')
  dest_folder=$(kde4-config --path services | cut -f 1 -d ':')ServiceMenus
;;
'Plasma 5')
  dest_folder=$(kf5-config --path services | cut -f 1 -d ':')ServiceMenus
;;
'Plasma 6')
  dest_folder=$(qtpaths --locate-dirs GenericDataLocation kio/servicemenus | cut -f 1 -d ':')
  writable_path=$(qtpaths --writable-path GenericDataLocation)
  dest_folder=$(echo "$dest_folder" | sed "s@^/usr/share@$writable_path@g")
;;
*)
  echo "[X] Unknown Desktop Environment: $kde_version" | tee -a $log_file
  exit 2
;;
esac

echo "[*] Desktop Environment: $kde_version" | tee -a $log_file
echo "[*] Destination path: $dest_folder" | tee -a $log_file

echo "[>] Uninstalling $desktop_filename" | tee -a $log_file
if [ -f "$dest_folder/$desktop_filename" ]; then
  rm "$dest_folder/$desktop_filename"
  echo "[V] Service Menu '$desktop_filename' removed!" | tee -a $log_file
else
  echo "[V] Service Menu '$desktop_filename' was already removed!" | tee -a $log_file
fi

echo '[=] Finished uninstalling scan_with_clamav' | tee -a $log_file
