#!/bin/bash

DIRECTORY_TO_WATCH="$1"
OUTPUT_DIRECTORY="$2"
WATCH_EXTENSION="$3"
TRANSCODING_PACKAGE="$4"

echo "Watching ${DIRECTORY_TO_WATCH}"
echo "Outputting to ${OUTPUT_DIRECTORY}"
echo "Extension set to ${WATCH_EXTENSION}"
echo "Using ${TRANSCODING_PACKAGE}"

process_file() {
  local file="$1"
  local output_file="${OUTPUT_DIRECTORY}/$(basename "$file" .${WATCH_EXTENSION}).mp4"
  echo "Processing: $file"
  if [ "${TRANSCODING_PACKAGE}" == "handbrake" ]; then
    process_file_with_handbrake "$file" "$output_file"
  else
    process_file_with_ffmpeg "$file" "$output_file"
  fi
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
inotifywait -m -r -e create --format '%w%f' "${DIRECTORY_TO_WATCH}" --include ".*\.${WATCH_EXTENSION}" | while read file; do
  echo "Detected: $file"
  bash -c 'process_file "$@"' _ "$file" &
done
