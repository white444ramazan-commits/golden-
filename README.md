# GORILLA PUBG KR Root Launcher

A root shell launcher/helper for the Android package `com.pubg.krmobile`.

## Install

Copy `gorilla.sh` to `/data/local/tmp/gorilla.sh`, then run:

```sh
su -c 'sh /data/local/tmp/gorilla.sh'
```

The script requests root itself when started without UID 0. It stores its configuration and log under `/data/local/tmp/gorilla/`.

## Included

- Root UID check and `su` relaunch
- Basic KernelSU presence detection
- PUBG KR package-installed check and version display
- Launch through Android's launcher intent
- Optional Android Game Mode performance/standard requests, only when supported by the ROM
- Persistent setting and diagnostic log

## Scope

This is a launcher and safe Android-side helper. It does not implement ESP, aimbot, game-memory modification, code injection, anti-cheat evasion, or claims of anti-cheat protection. It does not modify game files or game memory.

The script cannot guarantee a particular FPS or thermal result; Game Mode behavior depends on the Android build and device vendor.
