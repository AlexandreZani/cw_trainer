#!/usr/bin/env bash

python3 assets/icon.py
magick -background none assets/cw_icon.svg assets/cw_icon.png
flutter pub run flutter_launcher_icons
