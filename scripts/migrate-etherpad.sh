#!/bin/sh

# migrate-etherpad.sh
#
# Description: Migrate pads from etherpad to HedgeDoc
# Author: Daan Sprenkels <hello@dsprenkels.com>

# This script uses the HedgeDoc command line script[1] to import a list of pads from
# [1]: https://github.com/hedgedoc/cli/blob/master/bin/hedgedoc

DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
ENV="$DIR/../.env"
PAD_NAMES_FILE="$1"

echo "Loading environment variables from $ENV"

if [ -f "$ENV" ]; then
    . "$ENV"
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

# Do the migration
while IFS= read -r PAD_NAME; do
    # Skip empty lines and comments
    [ -z "$PAD_NAME" ] && continue
    case "$PAD_NAME" in \#*) continue ;; esac

    echo "Migrating pad: $PAD_NAME"

    # Download the pad
    PAD_FILE="$(mktemp)"
    URL="$ETHERPAD_SERVER/p/$PAD_NAME/export/txt"
    curl "$URL" >"$PAD_FILE"

    # Import the pad into HedgeDoc
    OUTPUT="$(hedgedoc import "$PAD_FILE" "$PAD_NAME")"
    echo "$PAD_NAME -> $OUTPUT" >>"$REDIRECTS_FILE"
done < "$PAD_NAMES_FILE"
