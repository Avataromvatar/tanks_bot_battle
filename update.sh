#!/bin/sh
set -e
cd package/tanks_battel_server
dart pub upgrade
sleep 1
cd ..
cd ..
flutter pub upgrade