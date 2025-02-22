#!/bin/bash

if [[ -z "${STEAM_USERNAME}" ]]; then
  echo "Environment variable STEAM_USERNAME is required but not provided."
  exit 1
else
  username="${STEAM_USERNAME}"
fi

if [[ -z "${STEAM_PASSWORD}" ]]; then
  echo "Environment variable STEAM_PASSWORD is required but not provided."
  exit 1
else
  password="${STEAM_PASSWORD}"
fi

cat << EOF > /home/steam/workshop.vdf
"workshopitem"
{
  "appid" "${INPUT_APPID}"
  "contentfolder" "${GITHUB_WORKSPACE}/${INPUT_PATH}"
  "changenote" "${INPUT_CHANGENOTE}"
  "publishedfileid" "${INPUT_ITEMID}"
  "previewfile" "${GITHUB_WORKSPACE}/${INPUT_PATH}/${INPUT_PREVIEWFILE}"
  "visibility" "${INPUT_VISIBILITY}"
  "title" "${INPUT_TITLE}"
  "description" "${INPUT_DESCRIPTION}"
  "changenote" "${INPUT_CHANGENOTE}"
}
EOF

echo "$(cat /home/steam/workshop.vdf)"

if [[ -z "${STEAM_TFASEED}" ]]; then
  /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login ${STEAM_USERNAME} ${STEAM_PASSWORD} +workshop_build_item /home/steam/workshop.vdf +quit
else
  code=$(/home/steam/steamcmd-2fa --username ${STEAM_USERNAME} --password ${STEAM_PASSWORD} --seed ${STEAM_TFASEED} --code-only)
  if [[ $? -ne 0 ]]; then
    exit 1 
  fi
  /home/steam/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +login ${STEAM_USERNAME} ${STEAM_PASSWORD} $code +workshop_build_item /home/steam/workshop.vdf +quit
fi

[ $? -eq 0 ] && exit 0 || (
    echo stderr
    echo "$(cat /home/steam/Steam/logs/stderr.txt)"
    echo
    echo workshop_log
    echo "$(cat /home/steam/Steam/logs/workshop_log.txt)"

    exit 1
)
