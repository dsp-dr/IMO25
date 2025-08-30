#!/bin/bash
# Run all IMO problems in parallel with multiple agents

REPO_ROOT=$(pwd)
LOG_DIR="$REPO_ROOT/logs/parallel-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"

echo "Starting parallel execution for all IMO problems"
echo "Log directory: $LOG_DIR"
echo "=========================================="

for i in 1 2 3 4 5 6; do
    echo "Launching 5 agents for Problem $i..."
    python3 code/run_parallel.py \
        "$REPO_ROOT/problems/imo0${i}.txt" \
        -n 5 \
        -d "$LOG_DIR/problem${i}" \
        -t 900 \
        --max-workers 5 \
        -e &
    
    # Small delay to avoid overwhelming the API
    sleep 2
done

echo ""
echo "All problem agents launched!"
echo "Monitor progress with: ls -la $LOG_DIR/*/agent*.log"
echo "Generate summary with: make logs-summary"

wait
echo "All agents completed!"
