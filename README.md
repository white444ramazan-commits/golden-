# GORILLA KR Root Launcher

Android shell launcher for PUBG MOBILE KR (`com.pubg.krmobile`).

## Install

Place `gorilla.sh` at `/data/local/tmp/gorilla.sh`, then run:

```sh
su
chmod 700 /data/local/tmp/gorilla.sh
sh /data/local/tmp/gorilla.sh
```

It re-executes itself through `su` if started without UID 0. The menu launches the installed game, reports package/version and device/root status, and requests Android Game Mode performance or standard mode where the ROM supports it. Logs and configuration are stored in `/data/local/tmp/gorilla/`.

## Compatibility

Requires Android, a working `su` implementation (KernelSU or Magisk), and the installed package `com.pubg.krmobile`. Game Mode behavior depends on the Android version and vendor ROM. The launcher does not guarantee FPS improvements.

## Scope

This project is a root launcher and local diagnostics utility. It does not include ESP, aimbot, game-memory patching, code injection, anti-cheat bypass, or anti-cheat evasion. No such functionality is claimed.
