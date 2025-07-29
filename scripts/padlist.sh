#!/bin/sh

# SSH target and database info
SSH_TARGET="root@padm.us"
DB_USER="root"
DB_NAME="etherpad"
LIMIT_NUM=100

# SQL query to list pad slugs and their counts
SQL_QUERY=$(cat <<EOF
SELECT
    REPLACE(
        SUBSTRING_INDEX(
            REGEXP_SUBSTR(
                store.key,
                '^pad(2readonly)?:[^:]+'
            ),
            ':',
            -1
        ),
        'pad:',
        ''
    ) AS padname
FROM store
GROUP BY padname
ORDER BY padname DESC
LIMIT $LIMIT_NUM;
EOF
)

# Run the query via SSH
ssh "$SSH_TARGET" "mysql -u $DB_USER $DB_NAME -N -e \"$SQL_QUERY\""
