# Universal Background Job Monitor (PID & TSP)

This script monitors a running background process (via PID) or a Task Spooler (`tsp`) task and sends periodic updates to your device via `ntfy.sh`.

## Setup

Before running the script for the first time, you must grant it executable permissions:

```bash
chmod +x monitor_job.sh

```

---

## Usage Examples

**1. Basic Usage**
By default, the script checks the target every 30 minutes (1800 seconds). You must provide either a TSP ID (`-i`) or a Process ID (`-p`).

To monitor a Task Spooler job (extracts the last line of output by default):

```bash
./monitor_job.sh -t my_secret_topic_99 -i 2

```

To monitor a standard background process by PID (Note: You should provide a custom extraction command via `-c` for PIDs to get meaningful metrics in your notification):

```bash
./monitor_job.sh -t my_secret_topic_99 -p 3473

```

**2. Custom Time Interval**
You can adjust how frequently the script checks the task and sends notifications. For example, to check every 5 minutes (300 seconds):

```bash
./monitor_job.sh -t my_secret_topic_99 -p 3473 -s 300

```

**3. Custom Extraction Command**
You can replace the default metric extraction with your own command. Wrap your bash pipeline in quotes:

For a PID (e.g., reading the tail of a `nohup` output file):

```bash
./monitor_job.sh -t my_secret_topic_99 -p 3473 -s 6 -c 'tail -n 3 /path/to/nohup.out'

```

For a TSP task (e.g., filtering specifically for an accuracy metric):

```bash
./monitor_job.sh -t my_secret_topic_99 -i 5 -s 3600 -c "tail -n 2 $(tsp -o 5)"
```

**4. Running in the Background**
To keep the monitor running after you disconnect from your terminal/SSH session, use `nohup`:

```bash
nohup ./monitor_job.sh -t my_secret_topic_99 -p 3473 -s 1800 > monitor.log 2>&1 &

```
