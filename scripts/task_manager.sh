#!/bin/bash

# Task Manager Script for AI-Driven Development
# This script helps manage tasks in the TASK_BOARD.md file

TASK_BOARD="doc/task/TASK_BOARD.md"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show current sprint tasks
show_current_sprint() {
    echo -e "${BLUE}=== Current Sprint Tasks ===${NC}"
    grep -A 50 "## 当前 Sprint" "$TASK_BOARD" | grep -E "^- \[" | head -20
}

# Function to show task statistics
show_stats() {
    local total=$(grep -c "^- \[" "$TASK_BOARD")
    local completed=$(grep -c "^- \[x\]" "$TASK_BOARD")
    local in_progress=$(grep -c "^- \[~\]" "$TASK_BOARD")
    local pending=$((total - completed - in_progress))

    echo -e "${BLUE}=== Task Statistics ===${NC}"
    echo -e "Total Tasks: ${total}"
    echo -e "${GREEN}Completed: ${completed}${NC}"
    echo -e "${YELLOW}In Progress: ${in_progress}${NC}"
    echo -e "Pending: ${pending}"
    echo ""
    echo -e "Progress: $((completed * 100 / total))%"
}

# Function to list high priority tasks
show_high_priority() {
    echo -e "${RED}=== High Priority Tasks ===${NC}"
    grep -B 1 "优先级：高" "$TASK_BOARD" | grep "^###" | sed 's/### //'
}

# Main menu
case "${1:-menu}" in
    sprint)
        show_current_sprint
        ;;
    stats)
        show_stats
        ;;
    priority)
        show_high_priority
        ;;
    menu|*)
        echo -e "${BLUE}Task Manager - AI-Driven Development${NC}"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  sprint    - Show current sprint tasks"
        echo "  stats     - Show task statistics"
        echo "  priority  - Show high priority tasks"
        echo "  menu      - Show this menu (default)"
        ;;
esac
