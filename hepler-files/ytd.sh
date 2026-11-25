#!/usr/bin/env bash

# add -euxo to show all
set -euo pipefail

export GREEN='\033[1;32m'
export NC='\033[0m' # No Color (Reset)

echoG() {
  echo -e "${GREEN}${1}${NC}"
}

SR="" # default youtube, m - Music
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
    -sr=*)
      SR="${1#*=}"
      shift
      ;;
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
      echoG "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

echoG "-sr=$SR \n-av=$AV \n-th=$TH \n-aq=$AQ \n-vq=$VQ \n-id=$ID \n-aSS=$ASS \n-aTO=$ATO  \n-vSS=$VSS \n-vTO=$VTO \n-artist=$ARTIST \n-title=$TITLE"

FULL_AUDIO="${ID}_A.webm"
FULL_VIDEO="${ID}_V.webm"
THUMBNAIL_FOR_YTD="${ID}_T" # no .jpg extension
THUMBNAIL="${ID}_T.jpg"
CUT_OPUS="${ID}_CUT.opus"
CUT_AUDIO="${ID}_CUT_A.webm"
CUT_VIDEO="${ID}_CUT_V.webm"
OUTPUT_AUDIO="${ARTIST} - ${TITLE}.opus"
OUTPUT_VIDEO="${ARTIST} - ${TITLE}.mkv"

Y_SOURCE="https://www.youtube.com/watch?v="
# $SR is not zero length
if [ $SR='m' ]; then
  Y_SOURCE="https://music.youtube.com/watch?v="
fi


checkParamErrors() {
  # $ASS not zero
  if [ -n "${ASS}" ]; then
    # $ATO zero
    if [ -z "${ATO}" ]; then
      echoG "parameter -aSS has to be specified."
      exit 1
     fi
  fi
  # check parameter av for youtube music
  if [ $SR='m' ]; then
    # $AV zero
    if [ -z "${AV}" ]; then
        echoG "parameter -AV has to be 'a'"
        exit 1
    fi
  fi
}

downloadThumbnail() {
  if [[ ! -f "${THUMBNAIL}" ]]; then
    echoG "Download thumbnail: ${THUMBNAIL}"
    ./yt-dlp --js-runtimes node --skip-download --write-thumbnail --convert-thumbnails jpg \
             -o "${THUMBNAIL_FOR_YTD}" "${Y_SOURCE}${ID}"
  else
    echoG "Thumbnail already downloaded: ${THUMBNAIL}"
  fi
}

downloadAudio() {
  if [[ ! -f "${FULL_AUDIO}" ]]; then
    echoG "Download audio AQ: ${AQ}: ${FULL_AUDIO}"
    ./yt-dlp --js-runtimes node -f ${AQ} -o ${FULL_AUDIO} "${Y_SOURCE}${ID}"
  else
    echoG "Audio already downloaded: ${FULL_AUDIO}"
  fi
}

downloadVideo() {
  if [[ ! -f "${FULL_VIDEO}" ]]; then
    echoG "Download video VQ: ${VQ}: ${FULL_VIDEO}"
    ./yt-dlp --js-runtimes node -f ${VQ} -o ${FULL_VIDEO} "${Y_SOURCE}${ID}"
  else
    echoG "Video already downloaded: ${FULL_VIDEO}"
  fi
}

makeTHUMBNAIL() {
  # get thumbnail from full video
  # $TH is not zero length
  if [[ -n "${TH}" && -f "${FULL_VIDEO}" ]]; then
    echoG "===== MAKE THUMBNAIL from VIDEO ======"
    ffmpeg -ss ${TH} -i ${FULL_VIDEO} -frames:v 1 -update 1 -y "${THUMBNAIL}"
  fi
}

makeAUDIO() {
  echoG "===== MAKE AUDIO ======"
  # full audio or cut
  # $ATO is zero length
  if [ -z ${ATO} ]; then
    ffmpeg -i ${FULL_AUDIO} -map 0:a -c:a copy -metadata ARTIST="${ARTIST}" -metadata TITLE="${TITLE}" -y ${CUT_OPUS}
  else
    ffmpeg -i ${FULL_AUDIO} -ss $ASS -to $ATO -map 0:a -c:a copy -metadata ARTIST="${ARTIST}" -metadata TITLE="${TITLE}" -y ${CUT_OPUS}
  fi
  # set thumbnail
  opustags --set-cover ${THUMBNAIL} ${CUT_OPUS} -o "${OUTPUT_AUDIO}" -y
  echoG "===== AUDIO created: ${OUTPUT_AUDIO} ======"
}

makeVIDEO() {
  echoG "===== MAKE VIDEO ======"
  # full video or cut
  # $VTO is zero length
  if [ -z ${VTO} ]; then
    ffmpeg -i ${FULL_VIDEO} -map 0:v -c:v copy -avoid_negative_ts make_zero -y ${CUT_VIDEO}
    ffmpeg -i ${FULL_AUDIO} -map 0:a -c:a copy -avoid_negative_ts make_zero -y ${CUT_AUDIO}
  else
    ffmpeg -i ${FULL_VIDEO} -ss ${VSS} -to ${VTO} -map 0:v -c:v copy -avoid_negative_ts make_zero -y ${CUT_VIDEO}
    ffmpeg -i ${FULL_AUDIO} -ss ${ASS} -to ${ATO} -map 0:a -c:a copy -avoid_negative_ts make_zero -y ${CUT_AUDIO}
  fi

  ffmpeg -i ${CUT_VIDEO} -i ${CUT_AUDIO} -map 0:v -map 1:a -c:v copy -c:a copy \
         -attach "${THUMBNAIL}" \
         -metadata:s:t filename="${THUMBNAIL}" \
         -metadata:s:t mimetype="image/jpeg" \
         -metadata ARTIST="${ARTIST}" -metadata TITLE="${TITLE}" \
         -shortest \
         -avoid_negative_ts make_zero -y "${OUTPUT_VIDEO}"
  echoG "===== VIDEO created: ${OUTPUT_VIDEO} ======"
}


checkParamErrors

if [ "${AV}" = "v" ]; then
  downloadThumbnail
  downloadAudio
  downloadVideo
  makeTHUMBNAIL
  makeVIDEO
elif [ "${AV}" = "a" ]; then
  downloadThumbnail
  # download video for thumbnail
  # if $TH not zero length
  if [ -n "${TH}" ]; then
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
