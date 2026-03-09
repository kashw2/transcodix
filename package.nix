{
  pkgs,
  watchDirectory,
  watchExtension,
  outputDirectory,
  transcodingPackage,
}:
pkgs.writeShellApplication {
  name = "transcodix";

  runtimeInputs =
    [
      pkgs.coreutils
      pkgs.inotify-tools
      pkgs.bash
    ]
    ++ (
      if transcodingPackage == "ffmpeg" then
        [ pkgs.ffmpeg ]
      else
        [ pkgs.handbrake ]
    );

  text = ''
    echo "Watching ${watchDirectory}"
    echo "Outputting to ${outputDirectory}"
    echo "Using ${transcodingPackage}"

    process_file() {
      local file="$1"
      local output_file
      output_file="${outputDirectory}/$(basename "$file" ".${watchExtension}").mp4"
      echo "Processing: $file"

      if ${
        if transcodingPackage == "ffmpeg" then
          ''ffmpeg -i "$file" -c:v libx264 -c:a aac -b:v 1M -b:a 128k "$output_file"''
        else
          ''HandBrakeCLI -i "$file" -o "$output_file" --preset="Very Fast 1080p30"''
      }; then
        echo "Successfully processed: $file"
      else
        echo "Failed to process: $file"
      fi
    }

    export -f process_file

    inotifywait -m -r -e create --format '%w%f' "${watchDirectory}" --include ".*\.${watchExtension}" | while IFS= read -r file; do
      echo "Detected: $file"
      bash -c 'process_file "$@"' _ "$file" &
    done
  '';
}
