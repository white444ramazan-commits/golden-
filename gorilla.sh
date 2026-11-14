#!/system/bin/sh
# GORILLA KR — root launcher and Android-side diagnostics
# Install: /data/local/tmp/gorilla.sh
PKG="com.pubg.krmobile"
SELF="/data/local/tmp/gorilla.sh"
DATA="/data/local/tmp/gorilla"
CONF="$DATA/config"
LOG="$DATA/gorilla.log"
VERSION="2.0.0"
mkdir -p "$DATA" 2>/dev/null
[ -f "$CONF" ] || printf "performance=0\n" > "$CONF"
touch "$LOG" 2>/dev/null
has() { command -v "$1" >/dev/null 2>&1; }
root() { [ "$(id -u 2>/dev/null)" = "0" ]; }
log() { printf "[%s] %s\n" "$(date "+%F %T" 2>/dev/null)" "$*" >> "$LOG"; }
if ! root; then
  if ! has su; then echo "Root manager su binary not found."; exit 1; fi
  exec su -c "sh \"$SELF\" --root"
fi
if [ ! -x /system/bin/sh ]; then echo "Unsupported Android environment."; exit 1; fi
read_perf() { PERF="$(sed -n "s/^performance=//p" "$CONF" 2>/dev/null | tail -n 1)"; [ "$PERF" = "1" ] || PERF=0; }
save_perf() { printf "performance=%s\n" "$PERF" > "$CONF.tmp" && mv "$CONF.tmp" "$CONF"; chmod 600 "$CONF" 2>/dev/null; }
installed() { pm path "$PKG" >/dev/null 2>&1; }
game_version() { dumpsys package "$PKG" 2>/dev/null | sed -n "s/^[[:space:]]*versionName=//p" | head -n 1; }
status() {
  echo "Package: $PKG"
  if installed; then echo "Game: installed"; echo "Version: $(game_version)"; else echo "Game: not installed"; fi
  echo "Root UID: $(id -u)"
  echo "Android: $(getprop ro.build.version.release 2>/dev/null)"
  echo "Device: $(getprop ro.product.device 2>/dev/null)"
  echo "SELinux: $(getenforce 2>/dev/null || echo unknown)"
  if [ -e /data/adb/ksu ] || [ -d /data/adb/ksud ] || has ksud; then echo "KernelSU: detected"; else echo "KernelSU: not confirmed"; fi
  read_perf; echo "Performance profile: $([ "$PERF" = "1" ] && echo ON || echo OFF)"
  df -h /data 2>/dev/null | tail -n 1
}
launch() {
  if ! installed; then echo "PUBG KR is not installed ($PKG)."; log "launch rejected: package missing"; return 1; fi
  echo "Starting PUBG MOBILE KR..."
  if has monkey; then monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; else am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$PKG" >/dev/null 2>&1; fi
  RC=$?; log "launch request rc=$RC version=$(game_version)"
  [ "$RC" -eq 0 ] && echo "Launch request sent." || echo "Launch command failed (exit $RC)."
  return "$RC"
}
performance_on() {
  if ! installed; then echo "Game is not installed."; return 1; fi
  if ! has cmd || ! cmd game help >/dev/null 2>&1; then echo "Android Game Mode is unavailable on this ROM."; log "Game Mode unavailable"; return 1; fi
  if cmd game mode performance "$PKG" >/dev/null 2>&1; then PERF=1; save_perf; echo "Android Game Mode performance requested."; log "performance mode enabled"; else echo "ROM rejected the performance request."; log "performance request failed"; return 1; fi
}
performance_off() {
  if has cmd && cmd game help >/dev/null 2>&1; then cmd game mode standard "$PKG" >/dev/null 2>&1; fi
  PERF=0; save_perf; echo "Standard Game Mode requested; ROM support may vary."; log "standard mode requested"
}
pause() { printf "\nPress Enter to continue..."; read _; }
while :; do
  read_perf
  clear 2>/dev/null
  echo "╔════════════════════════════════════════════╗"
  echo "║             G O R I L L A                  ║"
  echo "║          PUBG MOBILE KR  /  ROOT            ║"
  echo "╚════════════════════════════════════════════╝"
  echo " Version $VERSION | UID $(id -u) | Profile $([ "$PERF" = "1" ] && echo PERFORMANCE || echo STANDARD)"
  echo "────────────────────────────────────────────"
  echo " [1] Launch PUBG MOBILE KR"
  echo " [2] Device / game / root diagnostics"
  echo " [3] Request Android Game Mode: Performance"
  echo " [4] Request Android Game Mode: Standard"
  echo " [5] View latest log entries"
  echo " [0] Exit"
  echo "────────────────────────────────────────────"
  printf " Select: "; read CHOICE || exit 0
  case "$CHOICE" in
    1) launch; pause ;;
    2) status; pause ;;
    3) performance_on; pause ;;
    4) performance_off; pause ;;
    5) tail -n 50 "$LOG" 2>/dev/null; pause ;;
    0) log "launcher exited"; exit 0 ;;
    *) echo "Invalid option."; sleep 1 ;;
  esac
done
