#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

# Meaning of exit codes:
# 0: success | 1: no preview | 2: plain text | 6: image | 7: image (direct)

# Script arguments
FILE_PATH="${1}"
PV_WIDTH="${2}"
IMAGE_CACHE_PATH="${4}"
PV_IMAGE_ENABLED="${5}"

# Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
DEFAULT_SIZE="800x600"     # Resolution for previews

handle_image() {
    local mimetype="${1}"
    case "${mimetype}" in
        image/svg+xml|image/svg)
            rsvg-convert --width "${DEFAULT_SIZE%x*}" --keep-aspect-ratio \
                -- "${FILE_PATH}" > "${IMAGE_CACHE_PATH}" && exit 6
            exit 1;;

        image/*)
            # EXIF rotation
            local orientation
            orientation="$(identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}" 2>/dev/null)"
            if [[ -n "$orientation" && "$orientation" != 1 ]]; then
                convert -- "${FILE_PATH}" -auto-orient -depth 8 -quality 75 "${IMAGE_CACHE_PATH}" && exit 6
            fi
            # Signal Ranger to use its native displayer (Sixel) for all other images
            exit 7;;

        video/*)
            ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" -s 0 && exit 6
            exit 1;;

        application/pdf)
            pdftoppm -f 1 -l 1 -scale-to-x "${DEFAULT_SIZE%x*}" -scale-to-y -1 \
                -singlefile -jpeg -tiffcompression jpeg -- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" \
                && exit 6 || exit 1;;
    esac
}

handle_extension() {
    case "${FILE_PATH##*.}" in
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip|rar|7z)
            atool --list -- "${FILE_PATH}" && exit 5
            bsdtar --list --file "${FILE_PATH}" && exit 5
            exit 1;;
        torrent)
            transmission-show -- "${FILE_PATH}" && exit 5
            exit 1;;
        odt|ods|odp|sxw|xlsx|docx)
            pandoc -s -t markdown -- "${FILE_PATH}" && exit 5
            exit 1;;
        htm|html|xhtml)
            w3m -dump "${FILE_PATH}" && exit 5
            lynx -dump -- "${FILE_PATH}" && exit 5
            ;;
        json)
            jq --color-output . "${FILE_PATH}" && exit 5
            ;;
    esac
}

handle_mime() {
    local mimetype="${1}"
    case "${mimetype}" in
        text/* | */xml)
            if [[ "$(stat --printf='%s' -- "${FILE_PATH}")" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
                exit 2
            fi
            # Use `bat` for syntax highlighting if available, otherwise fall back.
            if command -v bat >/dev/null; then
                bat --color=always --style="plain" -- "${FILE_PATH}" && exit 5
            fi
            pygmentize -f terminal256 -O "style=gruvbox-dark" -- "${FILE_PATH}" && exit 5
            exit 2;;

        image/*|video/*|audio/*)
            # Show media info as a fallback
            exiftool "${FILE_PATH}" && exit 5
            exit 1;;
    esac
}

MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"

if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
    handle_image "${MIMETYPE}"
fi

handle_extension
handle_mime "${MIMETYPE}"

exit 1
