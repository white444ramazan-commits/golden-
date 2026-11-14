#!/system/bin/sh
# GORILLA PUBG KR Launcher — safe root launcher/performance helper
# Target package: com.pubg.krmobile
# Install/run: su -c 'sh /data/local/tmp/gorilla.sh'
# This script does not modify game memory, inject code, hide root, or bypass anti-cheat.

APP="GORILLA PUBG KR"
PKG="com.pubg.krmobile"
BASE="/data/local/tmp/gorilla"
LOG="$BASE/gorilla.log"
CONF="$BASE/config"
SELF="/data/local/tmp/gorilla.sh"

mkdir -p "$BASE" 2>/dev/null
[ -f "$CONF" ] || printf 'performance=0\n' > "$CONF"
touch "$LOG" 2>/dev/null

log() {
  TS="$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
  printf '[%s] %s\n' "${TS:-unknown-time}" "$*" >> "$LOG"
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

is_root() { [ "$(id -u 2>/dev/null)" = "0" ]; }

root_relaunch() {
  if is_root; then return 0; fi
  if ! has_cmd su; then
    echo "ОШИБКА: su не найден. Установи/настрой KernelSU или Magisk."
    exit 1
  fi
  echo "Запрашиваю root через su..."
  exec su -c "sh '$SELF' --root"
}

read_config() {
  PERF="$(sed -n 's/^performance=//p' "$CONF" 2>/dev/null | tail -n 1)"
  [ "$PERF" = "1" ] || PERF="0"
}

write_config() {
  TMP="$CONF.tmp"
  printf 'performance=%s\n' "$PERF" > "$TMP" && mv "$TMP" "$CONF"
  chmod 600 "$CONF" 2>/dev/null
}

game_installed() {
  pm path "$PKG" >/dev/null 2>&1
}

game_version() {
  dumpsys package "$PKG" 2>/dev/null | sed -n 's/^[[:space:]]*versionName=//p' | head -n 1
}

ksu_status() {
  if [ -e /data/adb/ksu ] || [ -d /data/adb/ksud ] || has_cmd ksud; then
    echo "KernelSU: обнаружен"
  elif [ -d /data/adb/modules ]; then
    echo "Root framework: /data/adb/modules найден (KernelSU не подтверждён)"
  else
    echo "KernelSU: не подтверждён (root при этом может работать)"
  fi
}

launch_game() {
  if ! game_installed; then
    echo "PUBG Mobile KR не найдена: $PKG"
    log "launch failed: package not installed"
    return 1
  fi
  echo "Запуск PUBG Mobile KR..."
  log "launch requested; version=$(game_version)"
  if has_cmd monkey; then
    monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  else
    am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$PKG" >/dev/null 2>&1
  fi
  RC=$?
  if [ "$RC" -eq 0 ]; then
    echo "Команда запуска отправлена."
    log "launch command accepted"
  else
    echo "Не удалось отправить команду запуска (код $RC)."
    log "launch command failed rc=$RC"
  fi
  return "$RC"
}

performance_on() {
  # Uses Android's public Game Mode interface when available; no sysfs/kernel tuning.
  if ! game_installed; then echo "Игра не установлена."; return 1; fi
  if has_cmd cmd && cmd game help >/dev/null 2>&1; then
    cmd game mode performance "$PKG" >/dev/null 2>&1
    RC=$?
  else
    echo "На этой прошивке команда Android Game Mode недоступна."
    log "performance mode unsupported by cmd game"
    return 1
  fi
  if [ "$RC" -eq 0 ]; then
    PERF=1; write_config
    log "Android Game Mode performance requested"
    echo "Режим производительности включён через Android Game Mode."
  else
    echo "Прошивка отклонила запрос Game Mode."
    log "performance mode request failed rc=$RC"
    return 1
  fi
}

performance_off() {
  if has_cmd cmd && cmd game help >/dev/null 2>&1; then
    cmd game mode standard "$PKG" >/dev/null 2>&1
    RC=$?
  else
    RC=1
  fi
  PERF=0; write_config
  log "performance mode disabled/restored to standard"
  if [ "$RC" -eq 0 ]; then
    echo "Стандартный режим игры восстановлен."
  else
    echo "Локальный переключатель сброшен. Команда стандартного режима не поддерживается прошивкой."
  fi
}

show_status() {
  echo "----------------------------------------"
  echo "$APP"
  echo "Package: $PKG"
  if game_installed; then
    echo "Игра: установлена"
    echo "Версия: $(game_version | sed 's/^$/не определена/')"
  else
    echo "Игра: не установлена"
  fi
  echo "Root UID: $(id -u 2>/dev/null)"
  ksu_status
  read_config
  echo "Профиль производительности: $([ "$PERF" = "1" ] && echo ON || echo OFF)"
  echo "Лог: $LOG"
  echo "----------------------------------------"
}

show_logs() {
  echo "Последние 40 записей:"
  tail -n 40 "$LOG" 2>/dev/null
}

menu() {
  while true; do
    read_config
    clear 2>/dev/null
    echo "╔══════════════════════════════════════╗"
    echo "║          G O R I L L A               ║"
    echo "║       PUBG MOBILE KR  •  4.7          ║"
    echo "╚══════════════════════════════════════╝"
    echo " Root: $(id -u)   KernelSU: $( [ -e /data/adb/ksu ] && echo YES || echo CHECK )"
    echo "----------------------------------------"
    echo " [1] Запустить PUBG Mobile KR"
    echo " [2] Статус игры и Root"
    echo " [3] Включить режим производительности"
    echo " [4] Вернуть стандартный режим"
    echo " [5] Просмотреть журнал"
    echo " [6] Показать конфигурацию"
    echo " [0] Выход"
    echo "----------------------------------------"
    printf "Выбор: "
    read CHOICE
    case "$CHOICE" in
      1) launch_game; printf "Нажми Enter..."; read WAIT ;;
      2) show_status; printf "Нажми Enter..."; read WAIT ;;
      3) performance_on; printf "Нажми Enter..."; read WAIT ;;
      4) performance_off; printf "Нажми Enter..."; read WAIT ;;
      5) show_logs; printf "Нажми Enter..."; read WAIT ;;
      6) cat "$CONF"; printf "Нажми Enter..."; read WAIT ;;
      0) log "exit"; exit 0 ;;
      *) echo "Неизвестный пункт."; sleep 1 ;;
    esac
  done
}

if [ "$1" != "--root" ]; then
  root_relaunch
fi

if ! is_root; then
  echo "Root-права не получены."
  exit 1
fi

chmod 700 "$SELF" 2>/dev/null
log "started uid=$(id -u) android=$(getprop ro.build.version.release) device=$(getprop ro.product.device)"
menu
