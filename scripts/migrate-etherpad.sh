#!/bin/sh

# migrate-etherpad.sh
#
# Description: Migrate pads from etherpad to HedgeDoc
# Author: Daan Sprenkels <hello@dsprenkels.com>

# This script uses the HedgeDoc command line script[1] to import a list of pads from
# [1]: https://github.com/hedgedoc/cli/blob/master/bin/hedgedoc

DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
ENV="$DIR/../.env"
LOG_FILE="hedgedoc_errors.log"

echo "Loading environment variables from $ENV"

if [ -f "$ENV" ]; then
    . "$ENV"
    export HEDGEDOC_SERVER
    export HEDGEDOC_CONFIG_DIR
    export HEDGEDOC_COOKIES_FILE
fi

echo "ETHERPAD_SERVER is $ETHERPAD_SERVER"
echo "HEDGEDOC_SERVER is $HEDGEDOC_SERVER"

# Write a list of pads and the urls which they were migrated to
REDIRECTS_FILE="redirects.txt"

# Fail if not called correctly
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 PAD_NAMES_FILE"
    exit 2
fi

hedgedoc login --email "$HEDGEDOC_EMAIL" "$HEDGEDOC_PASSWORD"

PAD_NAMES_FILE="$1"
TOTAL_PADS=$(grep -v '^\s*$' "$PAD_NAMES_FILE" | grep -v '^#' | wc -l)
i=1

# Do the migration
while IFS= read -r PAD_NAME; do
    # Skip empty lines and comments
    [ -z "$PAD_NAME" ] && continue
    case "$PAD_NAME" in \#*) continue ;; esac

    printf "%s/%s: %s (exporting)\r" "$i" "$TOTAL_PADS" "$PAD_NAME"

    START_TIME=$(date +%s)

    # Download the pad
    PAD_FILE="$(mktemp)"
    URL="$ETHERPAD_SERVER/$PAD_NAME/export/txt"
    curl "$URL" -sSf >"$PAD_FILE"

    printf "%s/%s: %s (importing)\r" "$i" "$TOTAL_PADS" "$PAD_NAME"

    if OUTPUT=$(hedgedoc import "$PAD_FILE" "$PAD_NAME" 2>>"$LOG_FILE"); then
        END_TIME=$(date +%s)
        DURATION=$(expr "$END_TIME" - "$START_TIME")
        printf "%s/%s: %s (done in %ss)\n" "$i" "$TOTAL_PADS" "$PAD_NAME" "$DURATION"
        echo "$PAD_NAME -> $OUTPUT" >>"$REDIRECTS_FILE"
    else
        END_TIME=$(date +%s)
        DURATION=$(expr "$END_TIME" - "$START_TIME")
        printf "%s/%s: %s (failed in %ss)\n" "$i" "$TOTAL_PADS" "$PAD_NAME" "$DURATION"
    fi

    i=$(expr "$i" + 1)
done < "$PAD_NAMES_FILE"
