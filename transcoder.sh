#!/bin/bash

WATCH_DIRECTORY="$1"
WATCH_EXTENSION="$2"
OUTPUT_DIRECTORY="$3"
TRANSCODING_PACKAGE="$4"

echo "Watching ${WATCH_DIRECTORY}"
echo "Outputting to ${OUTPUT_DIRECTORY}"
echo "Using ${TRANSCODING_PACKAGE}"

process_file() {
  local file="$1"
  local output_file="${OUTPUT_DIRECTORY}/$(basename "$file" .${WATCH_EXTENSION})"
  echo "Processing: $file"

  # Determine method to use
  if [ $TRANSCODING_PACKAGE == "handbrake" ]; then
    echo "Using HandBrakeCLI"
  else
    echo "Using ffmpeg"
  fi

  # Output completion status
  if [ $? -eq 0 ]; then
    echo "Successfully processed: $file"
  else
    echo "Failed to process: $file"
  fi
}

process_file_with_handbrake() {
  local file="$1"
  local output_file="$2"
  HandBrakeCLI -i "$file" -o "$output_file" --preset="Very Fast 1080p30"
}

process_file_with_ffmpeg() {
  local file="$1"
  local output_file="$2"
  ffmpeg -i "$file" -c:v libx264 -c:a aac -b:v 1M -b:a 128k "$output_file"
}

export -f process_file
export -f process_file_with_handbrake
export -f process_file_with_ffmpeg
export OUTPUT_DIRECTORY

# Watch for new files
inotifywait -m -r -e create --format '%w%f' "${WATCH_DIRECTORY}" --include ".*\.${WATCH_EXTENSION}" | while read file; do
  echo "Detected: $file"
  bash -c 'process_file "$@"' _ "$file" &
done
