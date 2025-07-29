#!/bin/sh

# SSH target and database info
SSH_TARGET="root@padm.us"
DB_USER="root"
DB_NAME="etherpad"

COUNT_QUERY=$(cat <<EOF
SELECT COUNT(DISTINCT
    SUBSTRING(
        store.key,
        LOCATE(':', store.key) + 1,
        CASE
            WHEN LOCATE(':', store.key, LOCATE(':', store.key) + 1) > 0
            THEN LOCATE(':', store.key, LOCATE(':', store.key) + 1) - LOCATE(':', store.key) - 1
            ELSE LENGTH(store.key)
        END
    )
) AS unique_pad_count
FROM store
WHERE store.key LIKE 'pad:%' OR store.key LIKE 'pad2readonly:%';
EOF
)

ssh "$SSH_TARGET" "mysql -u $DB_USER $DB_NAME -N -e \"$COUNT_QUERY\""
