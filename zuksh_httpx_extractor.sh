#!/bin/bash

# Zuksh's Advanced HTTPX Status Code Extractor
# Function to display banner
function show_banner() {
    echo "========================================="
    echo "    Zuksh's HTTPX Status Code Extractor"
    echo "========================================="
    echo "  Crafted by: Zuksh"
    echo "  Version: 1.0"
    echo "  Purpose: Extract domains by HTTP status"
    echo "========================================="
    echo
}

# Function to check if a command exists
function check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it."
        echo "For httpx: https://github.com/projectdiscovery/httpx"
        exit 1
    fi
}

# Function to display usage
function show_usage() {
    echo "Usage: $0 <domains_file> [-o <output_format>] [-c <config_file>]"
    echo "  <domains_file>: Text file with one domain per line"
    echo "  -o <output_format>: Output format (txt or json, default: txt)"
    echo "  -c <config_file>: Configuration file for httpx settings"
    echo "Example: $0 domains.txt -o json -c httpx.conf"
    exit 1
}

# Default settings
OUTPUT_FORMAT="txt"
CONFIG_FILE=""
THREADS=100
TIMEOUT=10
RETRIES=2
STATUS_CODES=("200" "301" "403" "404")

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o)
            OUTPUT_FORMAT="$2"
            if [[ "$OUTPUT_FORMAT" != "txt" && "$OUTPUT_FORMAT" != "json" ]]; then
                echo "Error: Output format must be 'txt' or 'json'"
                exit 1
            fi
            shift 2
            ;;
        -c)
            CONFIG_FILE="$2"
            if [ ! -f "$CONFIG_FILE" ]; then
                echo "Error: Config file '$CONFIG_FILE' not found!"
                exit 1
            fi
            shift 2
            ;;
        *)
            if [ -z "$DOMAINS_FILE" ]; then
                DOMAINS_FILE="$1"
            else
                echo "Error: Unknown argument '$1'"
                show_usage
            fi
            shift
            ;;
    esac
done

# Validate domains file
if [ -z "$DOMAINS_FILE" ]; then
    echo "Error: No domains file provided!"
    show_usage
fi

if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Error: File '$DOMAINS_FILE' not found!"
    exit 1
fi

# Check for httpx
check_command httpx

# Load config file if provided
if [ -n "$CONFIG_FILE" ]; then
    echo "Loading configuration from $CONFIG_FILE..."
    source "$CONFIG_FILE"
fi

# Create output directory
OUTPUT_DIR="zuksh_httpx_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"
ERROR_LOG="$OUTPUT_DIR/error.log"

# Count total domains for progress
TOTAL_DOMAINS=$(wc -l < "$DOMAINS_FILE")
echo "Total domains to process: $TOTAL_DOMAINS"

# Initialize httpx base command
HTTPX_BASE="httpx -l $DOMAINS_FILE -threads $THREADS -timeout $TIMEOUT -retries $RETRIES -silent"

# Add output-specific flags
if [ "$OUTPUT_FORMAT" = "json" ]; then
    HTTPX_BASE="$HTTPX_BASE -json"
fi

# Add metadata flags
HTTPX_BASE="$HTTPX_BASE -title -tech-detect -status-code"

# Process each status code
for STATUS in "${STATUS_CODES[@]}"; do
    echo "Processing status code $STATUS..."
    OUTPUT_FILE="$OUTPUT_DIR/domains_${STATUS}.${OUTPUT_FORMAT}"

    # Run httpx with match-code filter
    $HTTPX_BASE -mc "$STATUS" -o "$OUTPUT_FILE" 2>>"$ERROR_LOG"

    # Check if output file exists and has content
    if [ -s "$OUTPUT_FILE" ]; then
        echo "Results saved to $OUTPUT_FILE"
        if [ "$OUTPUT_FORMAT" = "txt" ]; then
            COUNT=$(wc -l < "$OUTPUT_FILE")
        else
            COUNT=$(jq -c . "$OUTPUT_FILE" | wc -l)
        fi
        echo "Found $COUNT domains with status $STATUS"
    else
        echo "No domains found with status code $STATUS"
        rm -f "$OUTPUT_FILE"
    fi
done

# Generate summary report
SUMMARY_FILE="$OUTPUT_DIR/summary.txt"
echo "Generating summary report..."
cat << EOF > "$SUMMARY_FILE"
Zuksh's HTTPX Extractor Summary
===============================
Run Date: $(date)
Input File: $DOMAINS_FILE
Total Domains Processed: $TOTAL_DOMAINS
Output Format: $OUTPUT_FORMAT
Output Directory: $OUTPUT_DIR
===============================
Results:
EOF

for STATUS in "${STATUS_CODES[@]}"; do
    OUTPUT_FILE="$OUTPUT_DIR/domains_${STATUS}.${OUTPUT_FORMAT}"
    if [ -f "$OUTPUT_FILE" ]; then
        if [ "$OUTPUT_FORMAT" = "txt" ]; then
            COUNT=$(wc -l < "$OUTPUT_FILE")
        else
            COUNT=$(jq -c . "$OUTPUT_FILE" | wc -l)
        fi
        echo "Status $STATUS: $COUNT domains" >> "$SUMMARY_FILE"
    else
        echo "Status $STATUS: 0 domains" >> "$SUMMARY_FILE"
    fi
done

if [ -s "$ERROR_LOG" ]; then
    echo "Errors encountered: Check $ERROR_LOG for details" >> "$SUMMARY_FILE"
else
    echo "No errors encountered" >> "$SUMMARY_FILE"
fi

echo "Processing complete. Summary saved to $SUMMARY_FILE"
echo "Thank you for using Zuksh's HTTPX Extractor!"
