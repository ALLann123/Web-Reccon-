#!/usr/bin/env bash

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 -m <mode> <domain1> <domain2> ... <domainN>"
    echo "Modes: nmap, dirsearch, crt, all"
    exit 1
fi

# Parse options
while getopts "m:" opt; do
    case "$opt" in
        m) MODE=$OPTARG ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

# Shift processed options
shift $((OPTIND - 1))

# Get the list of domains from the remaining arguments
domains=("$@")
if [[ ${#domains[@]} -eq 0 ]]; then
    echo "Error: No domains provided."
    exit 1
fi

# Define scan functions
nmap_scan() {
    echo "[+] Running nmap scan on $domain"
    nmap "$domain" > "$directory/nmap"
    echo "[+] Nmap results saved to $directory/nmap"
}

dirsearch_scan() {
    echo "[+] Running dirsearch on $domain"
    dirsearch -u "$domain" -e php --output="$directory/dirsearch" --format=simple
    echo "[+] Dirsearch results saved to $directory/dirsearch"
}

crt_scan() {
    echo "[+] Fetching certificate transparency data for $domain"
    curl -s "https://crt.sh/?q=$domain&output=json" -o "$directory/crt.json"
    if jq empty "$directory/crt.json" 2>/dev/null; then
        echo "[+] CRT results saved to $directory/crt.json"
    else
        echo "[-] Failed to fetch valid JSON from crt.sh. Check the network or domain name."
        rm -f "$directory/crt.json"
    fi
}

# Loop over each domain
for domain in "${domains[@]}"; do
    # Create directory for scan results
    directory="${domain}_reccon"
    echo "[+] Creating new directory called $directory"
    mkdir -p "$directory"

    # Run scans based on the mode
    case "$MODE" in
        nmap)
            nmap_scan
            ;;
        dirsearch)
            dirsearch_scan
            ;;
        crt)
            crt_scan
            ;;
        all)
            nmap_scan
            dirsearch_scan
            crt_scan
            ;;
        *)
            echo "Error: Invalid mode '$MODE'. Use nmap, dirsearch, crt, or all."
            exit 1
            ;;
    esac

    # Add a timestamp for when the scan is done
    timestamp=$(date)
    echo "Scan completed on $timestamp"

    # Generate the report
    report_file="$directory/report"
    echo "[+] Generating report at $report_file"

    {
        echo "Scan completed on: $timestamp"
        echo
        echo "=== Nmap Results ==="
        if [[ -f "$directory/nmap" ]]; then
            grep -E "^\S+\s+\S+\s+\S+$" "$directory/nmap" || echo "No matching lines found in nmap results."
        else
            echo "No nmap results."
        fi
        echo
        echo "=== Dirsearch Results ==="
        if [[ -f "$directory/dirsearch" ]]; then
            cat "$directory/dirsearch"
        else
            echo "No dirsearch results."
        fi
        echo
        echo "=== CRT.sh Results ==="
        if [[ -f "$directory/crt.json" ]]; then
            jq -r ".[] | .name_value" "$directory/crt.json" || echo "No certificate transparency data found."
        else
            echo "No CRT.sh results."
        fi
    } > "$report_file"

    echo "[+] Report saved to $report_file"
done
