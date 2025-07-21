#!/bin/sh

# migrate-etherpad.sh
#
# Description: Migrate pads from etherpad to HedgeDoc
# Author: Daan Sprenkels <hello@dsprenkels.com>

# This script uses the HedgeDoc command line script[1] to import a list of pads from
# [1]: https://github.com/hedgedoc/cli/blob/master/bin/hedgedoc

if [ ! -f .env ]; then
    echo "Error: .env file not found!" >&2
    exit 1
fi

set -a
. .env
set +a

echo "ETHERPAD_SERVER is $ETHERPAD_SERVER"
echo "HEDGEDOC_SERVER is $HEDGEDOC_SERVER"

# Write a list of pads and the urls which they were migrated to
REDIRECTS_FILE="redirects.txt"


# Fail if not called correctly
if (( $# != 1 )); then
    echo "Usage: $0 PAD_NAMES_FILE"
    exit 2
fi

# Do the migration
for PAD_NAME in $1; do
    # Download the pad
    PAD_FILE="$(mktemp)"
    curl "$ETHERPAD_SERVER/p/$PAD_NAME/export/txt" >"$PAD_FILE"

    # Import the pad into HedgeDoc
    OUTPUT="$(hedgedoc import "$PAD_FILE" "$PAD_NAME")"
    echo "$PAD_NAME -> $OUTPUT" >>"$REDIRECTS_FILE"
done
