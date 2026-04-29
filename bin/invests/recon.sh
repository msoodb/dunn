#!/bin/bash

#!/bin/bash

# ==================================================================================
# Script Name:    recon.sh
# Description:    A professional automated reconnaissance tool with subcommands and levels.
# Author:         msoodb (masoud.bolhassani@gmail.com)
# Usage:          ./recon.sh <subcommand> [options]
# ==================================================================================

# Default configuration variables
SCOPES=""            # File containing in-scope domains or URLs
OUT_OF_FSCOPES=""    # File containing out-of-scope domains or URLs (optional)
LEVEL=1              # Default execution level (1 if not specified)

# Display script banner
echo "======================================="
echo "        Automated Reconnaissance        "
echo "======================================="

# Help function
function show_help {
    echo "Usage: $0 <subcommand> [options]"
    echo
    echo "Subcommands:"
    echo "  castle   Perform reconnaissance with levels 1, 2, or 3 (default: 1)."
    echo "  door     Perform advanced reconnaissance with levels 1, 2, or 3 (default: 1)."
    echo
    echo "Options:"
    echo "  -s FILE, --scopes FILE      File containing scopes (domains, URLs, and wildcards in scope)."
    echo "  -oos FILE, --out-of-scope FILE File containing out of scopes (optional, used in Level 1)."
    echo "  -l LEVEL, --level LEVEL     Level of execution (1, 2, or 3). Default is 1."
    echo "  -h, --help                  Show this help message and exit."
    echo
    echo "Description:"
    echo "  Level 1: Basic tasks for reconnaissance."
    echo "  Level 2: Placeholder for additional features."
    echo "  Level 3: Placeholder for advanced features."
    echo
    exit 0
}

# Validate subcommands and arguments
if [[ $# -lt 1 ]]; then
    show_help
fi

SUBCOMMAND=$1
shift

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--scopes)
            SCOPES=$2
            shift 2
            ;;
        -oos|--out-of-scope)
            OUT_OF_FSCOPES=$2
            shift 2
            ;;
        -l|--level)
            LEVEL=$2
            if ! [[ $LEVEL =~ ^[1-3]$ ]]; then
                echo "Error: Level must be 1, 2, or 3."
                exit 1
            fi
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Invalid option: $1" >&2
            show_help
            ;;
    esac
done

# Functions for each subcommand
function castle {
    echo "Subcommand: castle"

    case $LEVEL in
        1)
            echo "Level 1: Basic subdomain enumeration and analysis..."
            if [[ -z "$SCOPES" ]]; then
                echo "Error: -s or --scopes (scopes file) is required for Level 1."
                show_help
            fi
            if [[ ! -f "$SCOPES" ]]; then
                echo "Error: File '$SCOPES' does not exist."
                exit 1
            fi

            # Subdomain enumeration
            gates.sh -s "$SCOPES" -oos "$OUT_OF_FSCOPES" # gates.txt
            cat gates.txt | dnsx -silent -resp -nc | tee doors-full.txt
            cat doors-full.txt | awk '{print $1}' | sort -u | tee doors.txt

            # Httpx
            echo "Gathering httpx..."
            httpx.sh doors.txt
            httpx-filter.sh httpx.txt

            # httpx FFF analysis
            echo "Running Hosts FFF analysis..."
            fff.sh httpx.txt

            # doors categorize
            awk '{print $1}' httpx-full.txt | sed -E 's#https?://##' | cut -d'/' -f1 | sort -u > doors-httpx.txt
            grep -Fvxf doors-httpx.txt doors.txt > posterns.txt
            rm httpx-full.txt
            rm doors-httpx.txt
            ;;
        2)
            # Screenshot httpx
            echo "Taking screenshots of httpx..."
            screenshot.sh httpx.txt
            ;;
        3)
            # Port recon
            mkdir nmaps
            echo "Running nmap on main domains..."
            for postern in $(cat posterns.txt); do
                nmap "$postern" -o nmaps/"$postern"
            done
            ;;
    esac

    echo "Castle Level $LEVEL completed!"
}

function door {
    echo "Subcommand: door"

    case $LEVEL in
        1)
            echo "Level 2: Advanced URL and JavaScript analysis..."
    
            # URLs
            echo "Extracting URLs..."
            url.sh -l "$SCOPES"
            cat urls.txt | grep "?" > urls-params.txt
            url-filter.sh urls.txt
            url-js.sh urls.txt

            # Download JavaScript files
            echo "Downloading JavaScript files..."
            download.sh urls-js.txt

            # URLs FFF analysis
            echo "Running URLs FFF analysis..."
            fff.sh urls.txt
            ;;
        2)
            echo "Level 3: Advanced URL and JavaScript analysis..."
    
            # Paramspider
            echo "Running ParamSpider..."
            paramspider -l "$SCOPES"
            mv results/ paramspider/

            # Screenshot URLs
            echo "Taking screenshots of URLs..."
            screenshot.sh urls.txt
            ;;
        3)
            echo "Level 3: Placeholder for advanced features and ParamSpider analysis..."
            ;;
    esac

    echo "Door Level $LEVEL completed!"
}

# Execute the appropriate subcommand
case $SUBCOMMAND in
    castle)
        castle
        ;;
    door)
        door
        ;;
    *)
        echo "Invalid subcommand: $SUBCOMMAND" >&2
        show_help
        ;;
esac
