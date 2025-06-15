#!/usr/bin/env bash

python3 assets/icon.py
magick -background none assets/cw_icon.svg assets/cw_icon.png
cp assets/cw_icon.png android/app/src/main/res/drawable/
