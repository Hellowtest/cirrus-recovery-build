#!/usr/bin/env bash

# Logging functions
function _err() {
  echo "[ERROR] $*"
  exit 1
}

function err() {
  echo "[ERROR] $*"
  send_file "$HOME/build.log" "$*"
  exit 1
}

function log() {
  echo "[LOG] $*"
}

# Telegram functions
# send_msg <text>
function send_msg() {
  local text=$(echo -e "$1")
  [ -z "$text" ] && _err "send_msg: A text needed."
  curl -s -X POST \
    -d "chat_id=$TG_CHAT_ID" \
    -d "disable_web_page_preview=true" \
    -d "parse_mode=markdown" \
    -d "text=$text" \
    "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage"
}

# send_file <file> [<caption>]
function send_file() {
  local file="$1"
  local caption="${2:-}"
  [ -z "$file" ] && _err "send_file: A file needed."
  [ -f "$file" ] || _err "send_file: File not found."
  chmod 777 "$file"
  curl -s -F document=@"$file" \
    -F "chat_id=$TG_CHAT_ID" \
    -F "disable_web_page_preview=true" \
    -F "parse_mode=Markdown" \
    -F "caption=$caption" \
    "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendDocument"
}
