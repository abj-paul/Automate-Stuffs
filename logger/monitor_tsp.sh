#!/bin/bash

# --- Default values ---
INTERVAL=1800
TASK_ID=""
PID=""
TOPIC=""
EXTRACT_CMD=""

# --- Help Function ---
usage() {
    echo "Usage: $0 -t <topic> [-i <tsp_id> | -p <pid>] [-s <sleep_interval>] [-c <extract_command>]"
    echo "Options:"
    echo "  -t, --topic        ntfy topic name (required)"
    echo "  -i, --id           Task Spooler (tsp) ID to monitor"
    echo "  -p, --pid          Process ID (PID) to monitor"
    echo "  -s, --sleep        Time in seconds between notifications (default: 1800)"
    echo "  -c, --command      Custom bash command to extract the metric (optional)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Note: You must provide either a TSP ID (-i) OR a PID (-p), but not both."
    exit 1
}

# --- Parse Command Line Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--topic) TOPIC="$2"; shift ;;
        -i|--id) TASK_ID="$2"; shift ;;
        -p|--pid) PID="$2"; shift ;;
        -s|--sleep) INTERVAL="$2"; shift ;;
        -c|--command) EXTRACT_CMD="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# --- Validation ---
if [ -z "$TOPIC" ]; then
    echo "Error: Topic (-t) is required."
    usage
fi

if [ -z "$TASK_ID" ] && [ -z "$PID" ]; then
    echo "Error: You must provide either a TSP ID (-i) or a PID (-p)."
    usage
fi

if [ -n "$TASK_ID" ] && [ -n "$PID" ]; then
    echo "Error: Please provide ONLY a TSP ID (-i) OR a PID (-p), not both."
    usage
fi

# Set default extraction command based on the mode
if [ -z "$EXTRACT_CMD" ]; then
    if [ -n "$TASK_ID" ]; then
        EXTRACT_CMD="tsp -c $TASK_ID | tail -n 1"
    else
        echo "Warning: No extraction command provided for PID mode. Standard output will be empty."
        EXTRACT_CMD="echo 'No metric extracted.'"
    fi
fi

# Setup variables based on mode
if [ -n "$TASK_ID" ]; then
    TARGET_LABEL="Task $TASK_ID"
    echo "Starting TSP monitor for $TARGET_LABEL to ntfy.sh/$TOPIC"
else
    TARGET_LABEL="Process $PID"
    echo "Starting PID monitor for $TARGET_LABEL to ntfy.sh/$TOPIC"
fi

echo "Interval: $INTERVAL seconds"
echo "Extract command: $EXTRACT_CMD"

# --- Main Monitoring Loop ---
while true; do
    
    # 1. Check Status based on Mode
    if [ -n "$TASK_ID" ]; then
        # TSP Mode
        STATUS=$(tsp -s "$TASK_ID")
        if [ "$STATUS" == "finished" ] || [ "$STATUS" == "died" ]; then
            IS_RUNNING=false
        else
            IS_RUNNING=true
        fi
    else
        # PID Mode
        if kill -0 "$PID" 2>/dev/null; then
            STATUS="running"
            IS_RUNNING=true
        else
            STATUS="finished_or_died"
            IS_RUNNING=false
        fi
    fi
    
    # 2. Extract Metrics
    LATEST_METRIC=$(eval "$EXTRACT_CMD")
    
    # 3. Format Notification Message
    if [ -z "$LATEST_METRIC" ]; then
        MESSAGE="$TARGET_LABEL is $STATUS. No metrics found yet."
    else
        MESSAGE="$TARGET_LABEL ($STATUS):\n$LATEST_METRIC"
    fi

    # 4. Send Periodic Notification
    curl -s -H "Title: Training Update" -d "$MESSAGE" "https://ntfy.sh/$TOPIC" > /dev/null

    # 5. Handle Exit Condition
    if [ "$IS_RUNNING" = false ]; then
        curl -s -H "Title: Training Stopped" -H "Priority: high" -H "Tags: warning" -d "$TARGET_LABEL ended with status: $STATUS" "https://ntfy.sh/$TOPIC" > /dev/null
        echo "$TARGET_LABEL finished/died. Exiting monitor."
        break
    fi

    sleep "$INTERVAL"
done
