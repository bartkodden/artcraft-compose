#!/bin/bash
LOG=/var/log/artcraft-update.log
SCRIPT=/var/docker/storytold/update.sh

echo "Starting ArtCraft update in background..."
echo "Follow progress with: tail -f $LOG"
echo ""

nohup sudo bash $SCRIPT > $LOG 2>&1 &
echo "PID: $!"
