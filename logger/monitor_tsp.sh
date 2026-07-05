#!/bin/bash

# --- Default values ---
INTERVAL=1800
TASK_ID=""
TOPIC=""
EXTRACT_CMD=""

# --- Help Function ---
usage() {
    echo "Usage: $0 -t <topic> -i <task_id> [-s <sleep_interval>] [-c <extract_command>]"
    echo "Options:"
    echo "  -t, --topic        ntfy topic name (required)"
    echo "  -i, --id           tsp task ID (required)"
    echo "  -s, --sleep        Time in seconds between notifications (default: 1800)"
    echo "  -c, --command      Custom bash command to extract the metric (optional)"
    echo "  -h, --help         Show this help message"
    exit 1
}

# --- Parse Command Line Arguments ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--topic) TOPIC="$2"; shift ;;
        -i|--id) TASK_ID="$2"; shift ;;
        -s|--sleep) INTERVAL="$2"; shift ;;
        -c|--command) EXTRACT_CMD="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# --- Validation ---
if [ -z "$TOPIC" ] || [ -z "$TASK_ID" ]; then
    echo "Error: Topic (-t) and Task ID (-i) are required."
    usage
fi

# Set default extraction command if the user didn't provide one
if [ -z "$EXTRACT_CMD" ]; then
    EXTRACT_CMD="tsp -c $TASK_ID | grep 'eval/acc1' | tail -n 1 | awk '{\$1=\$1;print}'"
fi

echo "Starting monitor for tsp task $TASK_ID to ntfy.sh/$TOPIC"
echo "Interval: $INTERVAL seconds"
echo "Extract command: $EXTRACT_CMD"

# --- Main Monitoring Loop ---
while true; do
    # Get the current status of the task
    STATUS=$(tsp -s "$TASK_ID")
    
    # Run the extraction command (eval handles the piped/custom string safely here)
    LATEST_METRIC=$(eval "$EXTRACT_CMD")
    
    # Format the message
    if [ -z "$LATEST_METRIC" ]; then
        MESSAGE="Task $TASK_ID is $STATUS. No metrics found yet."
    else
        MESSAGE="Task $TASK_ID ($STATUS): $LATEST_METRIC"
    fi

    # Send notification via ntfy
    curl -s -H "Title: Training Update" -d "$MESSAGE" "https://ntfy.sh/$TOPIC" > /dev/null

    # Stop the script if the task is no longer running
    if [ "$STATUS" == "finished" ] || [ "$STATUS" == "died" ]; then
        curl -s -H "Title: Training Stopped" -H "Priority: high" -H "Tags: warning" -d "Task $TASK_ID ended with status: $STATUS" "https://ntfy.sh/$TOPIC" > /dev/null
        echo "Task finished/died. Exiting monitor."
        break
    fi

    sleep "$INTERVAL"
done
