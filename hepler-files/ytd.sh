#!/usr/bin/env bash

# add -euxo to show all
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AV="" # a - audio, v - video
TH="" # th=00:01:22 - thumbnail from video, time
AQ=251
VQ=248 #248-1080p, 313-4k
ID=""
ASS=""
ATO=""
VSS=""
VTO=""
TITLE=""
ARTIST=""

# Parse named parameters
# Extract everything after '='
while [[ $# -gt 0 ]]; do
  case "$1" in
    -av=*)
      AV="${1#*=}"
      shift
      ;;
    -th=*)
      TH="${1#*=}"
      shift
      ;;
    -aq=*)
      AQ="${1#*=}"
      shift
      ;;
    -vq=*)
      VQ="${1#*=}"
      shift
      ;;
    -id=*)
      ID="${1#*=}"
      shift
      ;;
    -aSS=*)
      ASS="${1#*=}"
      shift
      ;;
    -aTO=*)
      ATO="${1#*=}"
      shift
      ;;
    -vSS=*)
      VSS="${1#*=}"
      shift
      ;;
    -vTO=*)
      VTO="${1#*=}"
      shift
      ;;
    -artist=*)
      ARTIST="${1#*=}"
      shift
      ;;
    -title=*)
      TITLE="${1#*=}"
      shift
      ;;

    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

echo -e "-av=$AV \n-th=$TH \n-aq=$AQ \n-vq=$VQ \n-id=$ID \n-aSS=$ASS \n-aTO=$ATO  \n-vSS=$VSS \n-vTO=$VTO \n-artist=$ARTIST \n-title=$TITLE"

FULL_AUDIO="${ID}_A.webm"
FULL_VIDEO="${ID}_V.webm"
THUMBNAIL_FOR_YTD="${ID}_T" # no .jpg extension
THUMBNAIL="${ID}_T.jpg"
CUT_OPUS="${ID}_CUT.opus"
CUT_AUDIO="${ID}_CUT_A.webm"
CUT_VIDEO="${ID}_CUT_V.webm"
OUTPUT_AUDIO="${ARTIST} - ${TITLE}.opus"
OUTPUT_VIDEO="${ARTIST} - ${TITLE}.mkv"

checkParamErrors() {
  if [ "$ASS" = "" ]; then
     echo "parameter -aSS have to be spessified."
     exit 1
  fi
}

downloadThumbnail() {
  if [[ ! -f "$THUMBNAIL" ]]; then
    echo "Download thumbnail: ${THUMBNAIL}"
    ./yt-dlp --js-runtimes node --skip-download --write-thumbnail --convert-thumbnails jpg \
             -o "$THUMBNAIL_FOR_YTD" "https://www.youtube.com/watch?v=$ID"
  else
    echo "Thumbnail aledy downloaded: ${THUMBNAIL}"
  fi
}

downloadAudio() {
  if [[ ! -f "$FULL_AUDIO" ]]; then
    echo "Download audio AQ: ${AQ}: ${FULL_AUDIO}"
    ./yt-dlp --js-runtimes node -f $AQ -o $FULL_AUDIO "https://www.youtube.com/watch?v=$ID"
  else
    echo "Audio aledy downloaded: ${FULL_AUDIO}"
  fi
}

downloadVideo() {
  if [[ ! -f "$FULL_VIDEO" ]]; then
    echo "Download video VQ: ${VQ}: ${FULL_VIDEO}"
    ./yt-dlp --js-runtimes node -f $VQ -o $FULL_VIDEO "https://www.youtube.com/watch?v=$ID"
  else
    echo "Video aledy downloaded: ${FULL_VIDEO}"
  fi
}

makeTHUMBNAIL() {
  # get thumbnail from full video
  if [[ -n "$TH" && -f "$FULL_VIDEO" ]]; then
    ffmpeg -ss $TH -i $FULL_VIDEO -frames:v 1 -update 1 -y "$THUMBNAIL"
  fi
}

makeAUDIO() {
  # full audio or cut
  if [ -z $ATO ]; then
    ffmpeg -i $FULL_AUDIO -map 0:a -c:a copy -metadata ARTIST="$ARTIST" -metadata TITLE="$TITLE" -y $CUT_OPUS
  else
    ffmpeg -i $FULL_AUDIO -ss $ASS -to $ATO -map 0:a -c:a copy -metadata ARTIST="$ARTIST" -metadata TITLE="$TITLE" -y $CUT_OPUS
  fi
  # set thumbnail
  opustags --set-cover $THUMBNAIL $CUT_OPUS -o "${OUTPUT_AUDIO}" -y
  echo "===== AUDIO created: $OUTPUT_AUDIO ======"
}

makeVIDEO() {
  # full video or cut
  if [ -z $VTO ]; then
    ffmpeg -i $FULL_VIDEO -map 0:v -c:v copy -avoid_negative_ts make_zero -y $CUT_VIDEO
    ffmpeg -i $FULL_AUDIO -map 0:a -c:a copy -avoid_negative_ts make_zero -y $CUT_AUDIO
  else
    ffmpeg -i $FULL_VIDEO -ss $VSS -to $VTO -map 0:v -c:v copy -avoid_negative_ts make_zero -y $CUT_VIDEO
    ffmpeg -i $FULL_AUDIO -ss $ASS -to $ATO -map 0:a -c:a copy -avoid_negative_ts make_zero -y $CUT_AUDIO
  fi

  ffmpeg -i $CUT_VIDEO -i $CUT_AUDIO -map 0:v -map 1:a -c:v copy -c:a copy \
         -attach "$THUMBNAIL" \
         -metadata:s:t filename="$THUMBNAIL" \
         -metadata:s:t mimetype="image/jpeg" \
         -metadata ARTIST="$ARTIST" -metadata TITLE="$TITLE" \
         -shortest \
         -avoid_negative_ts make_zero -y "${OUTPUT_VIDEO}"
  echo "===== VIDEO created: ${OUTPUT_VIDEO} ======"
}


checkParamErrors

if [ "$AV" = "v" ]; then
  downloadThumbnail
  downloadAudio
  downloadVideo
  makeTHUMBNAIL
  makeVIDEO
elif [ "$AV" = "a" ]; then
  downloadThumbnail
  # download video for thumbnail
  if [ -z "$TH" ]; then
    downloadVideo
  fi
  downloadAudio
  makeTHUMBNAIL
  makeAUDIO
else
  downloadThumbnail
  downloadAudio
  downloadVideo
  makeTHUMBNAIL
  makeAUDIO
  makeVIDEO
fi
