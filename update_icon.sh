#!/usr/bin/env bash

python3 assets/icon.py
magick assets/background_icon.svg android/app/src/main/res/drawable/background_icon.png
magick -background none assets/foreground_icon.svg android/app/src/main/res/drawable/foreground_icon.png
