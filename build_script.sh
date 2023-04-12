#!/bin/sh
set -e
# _file="assets/README.md"
# _header="# Сборка\n"
# _version=$(git describe --tags)
# _row=$(grep -n 'version:' pubspec copy.yaml | cut -d ':' -f1)
# _changeHeader="## Изменения\n"
# _change=$(cat change.md)

# echo "${_header}${_version}\n${_changeHeader}${_change}" > "${_file}"
# echo "${_header}${_version}" > "${_file}"
# echo "Update README.md in /asset DONE"
#run script change pubspec.yaml 

    cd package/tanks_battel_server
    dart pub run build_runner build --delete-conflicting-outputs
    cd ..
    cd ..
    flutter pub run build_runner build --delete-conflicting-outputs
    
