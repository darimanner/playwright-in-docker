#!/bin/bash
set -e

# restart: on-failure reuses the container filesystem, and a stale lock makes Xvfb refuse :99.
rm -f /tmp/.X99-lock
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
export DISPLAY=:99

# exec so SIGTERM from `docker stop` reaches Python instead of dying in bash.
exec python src/main.py
