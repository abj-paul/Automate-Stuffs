# Task Spooler (tsp) Notification Monitor

This script monitors a running `tsp` (Task Spooler) task and sends periodic updates to your device via `ntfy.sh`.

## Setup

Before running the script for the first time, you must grant it executable permissions:

```bash
chmod +x monitor_tsp.sh

```

---

## Usage Examples

**1. Basic Usage**
By default, the script checks the task every 30 minutes (1800 seconds) and extracts the `eval/acc1` metric. To monitor task `2`:

```bash
./monitor_tsp.sh -t my_secret_topic_99 -i 2

```

**2. Custom Time Interval**
You can adjust how frequently the script checks the task and sends notifications. For example, to check every 5 minutes (300 seconds):

```bash
./monitor_tsp.sh -t my_secret_topic_99 -i 2 -s 300

```

**3. Custom Extraction Command**
You can replace the default metric extraction with your own command. If you want to send the last 3 lines of the log instead of filtering for `eval/acc1`, wrap your bash pipeline in quotes:

```bash
./monitor_tsp.sh -t my_secret_topic_99 -i 2 -s 6 -c 'tail -n 3 $(tsp -o 2)'
```

**4. Running in the Background**
To keep the monitor running after you disconnect from your terminal/SSH session, use `nohup`:

```bash
nohup ./monitor_tsp.sh -t my_secret_topic_99 -i 2 -s 1800 > monitor.log 2>&1 &

```

---

