#!/bin/bash

if [ $# -eq 0 ]; then
    echo Not enough args
    exit 1
fi

# Default values w/o args
STEMS=2
KHZ=11
HELP=false
FILE=false
YOUTUBE=false
KEEP=false
VERBOSE=false
PERMISSIONS=false
INSTALL=false
VERSION=1.1.1

# Parse script args
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -f|--file)
            FILEPATH=$(dirname "$2")
            FILEPATH=$(realpath "$FILEPATH")
            FILENAME=$(basename "$2")

            if [ -f "$FILEPATH/$FILENAME" ]; then
                echo [DONE] Check file exists
                FILE=true
            else
                echo [FAIL] Check file exists
                exit 1
            fi
            shift # past argument
            shift # past value
            ;;
        -s|--stems)
            if [ $2 -eq 4 ]; then
                STEMS=4
            elif [ $2 -eq 5 ]; then
                STEMS=5
            fi
            shift # past argument
            shift # past value
            ;;
        -y|--youtube)
            YOUTUBE=$2
            shift # past argument
            shift # past value
            ;;
        -c|--cutoff)
            if [ $2 -eq 16 ]; then
                KHZ=16
            fi
            shift # past argument
            shift # past value
            ;;
        -h|--help)
            HELP=true
            shift # past argument
            ;;
        -k|--keep)
            KEEP=true
            shift # past argument
            ;;
        -p|--fix-permissions)
            PERMISSIONS=true
            shift # past argument
            ;;
        -v|--verbose)
            VERBOSE=true
            shift # past argument
            ;;
        -i|--install)
            INSTALL=true
            shift
            ;;
        --default)
            DEFAULT=YES
            shift # past argument
            ;;
            *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL[@]}"

# Man page
if [ $HELP == "true" ]; then
    echo "This script is a wrapper for the spleeter (https://github.com/deezer/spleeter) docker image."
    echo Version: $VERSION
    echo
    echo Usage: spleeter -f \<filename\> [options]
    echo 
    echo Options:
    echo "  -c --cutoff             Frequency cutoff (takes 11 or 16 default: 11)"
    echo "  -f --file               Path to the desired file"
    echo "  -h --help               Show this screen"
    echo "  -i --install            Install this script for the current user"
    echo "  -p --fix-permissions    Fix permissions from docker output (requires sudo)"
    echo "  -s --stems              The number of stems to split the file into (takes 2, 4 or 5 default: 2)"
    echo "  -v --verbose            Enable verbose output"
    echo "  -y --youtube            Specify a YouTube URL to download source audio for"
    echo "      -k --keep           Keep the source audio from YouTube downloaded audio"
    exit 0
fi

# Install onto system
if [ $INSTALL == "true" ]; then
    echo -n "[    ] Installing"
    mkdir -p /home/$(whoami)/.local/bin/
    SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cp "$SCRIPT"/"$(basename $0)" /home/$(whoami)/.local/bin/ 2> /dev/null
    alias spleeterd >/dev/null 2>&1 && echo "alias spleeterd='bash /home/$(whoami)/.local/bin/$(basename $0)'" >> /home/$(whoami)/.bashrc
    echo -ne "\r[DONE] Installing"
    echo
    echo
    echo "Run \"spleeterd -h\" to get started"
    exit 0
fi
    

# Check that file var is set
if [ $FILE == "false" ] && [ $YOUTUBE == "false" ]; then
    echo You must supply a filename by using -f
    echo If you need help, run "spleeter -h"
    exit 1
fi

mkdir -p ${PWD}/spleeter

if [ $YOUTUBE != "false" ]; then
    FOLDER=$(date +%s)
    mkdir -p /tmp/$FOLDER
    FILEPATH="/tmp/$FOLDER"
    echo -n "[    ] Downloading YouTube audio"
    CD=$(pwd)
    cd /tmp/$FOLDER/
    if [ $VERBOSE == 'true' ]; then
        youtube-dl --extract-audio --audio-format mp3 --output "%(title)s.%(ext)s" $YOUTUBE
    else
        youtube-dl --extract-audio --audio-format mp3 --output "%(title)s.%(ext)s" $YOUTUBE > /dev/null
    fi
    cd $CD
    FILENAME=$(ls /tmp/$FOLDER/ | head -n 1)
    echo -ne "\r[DONE] Downloading YouTube audio"
    echo
fi

#Pull latest spleeter image
echo -n "[    ] Pulling latest spleeter image"
if [ $VERBOSE == 'true' ]; then
    docker pull researchdeezer/spleeter:latest
else
    docker pull researchdeezer/spleeter:latest > /dev/null
fi
echo -ne "\r[DONE] Pulling latest spleeter image"
echo

echo -n "[    ] Splitting \"$FILENAME\" into $STEMS stems with a $KHZ kHz cutoff"
echo
if [ $KHZ -eq 11 ]; then
    STEMS="$STEMS"stems
elif [ $KHZ -eq 16 ]; then
    STEMS="$STEMS"stems-16kHz
fi

if [ $VERBOSE == "true" ]; then
    docker run -v "$FILEPATH":/input -v $(pwd)/spleeter:/output researchdeezer/spleeter separate -i "/input/$FILENAME" -o /output -p spleeter:$STEMS --mwf --verbose
else
    docker run -v "$FILEPATH":/input -v $(pwd)/spleeter:/output researchdeezer/spleeter separate -i "/input/$FILENAME" -o /output -p spleeter:$STEMS --mwf
fi

echo -ne "\r[DONE] Splitting \"$FILENAME\" into $STEMS stems with a $KHZ kHz cutoff"
echo

if [ $PERMISSIONS == "true" ] || [ $KEEP == "true" ]; then
    echo
    echo -n "[    ] Fixing permissions"
    sudo chown -R $(whoami):$(whoami) $(pwd)/spleeter
    echo -ne "\r[DONE] Fixing permissions"
    echo
fi

if [ $KEEP == "true" ]; then
    echo -n "[    ] Moving original audio"
    mv "$FILEPATH/$FILENAME" "$(pwd)/spleeter/$(basename -s ".mp3" "$FILENAME")/original.mp3"
    echo -ne "\r[DONE] Moving original audio"
    echo
fi
