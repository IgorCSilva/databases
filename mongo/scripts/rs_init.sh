#!/bin/bash

DELAY=25

mongosh <<EOF
var config = {
    "_id": "book",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "mongo_rs2_1",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "mongo_rs2_2",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "mongo_rs2_3",
            "priority": 1
        }
    ]
};

rs.initiate(config, { force: true });
rs.status();
EOF

# echo "****** Waiting for ${DELAY} seconds for replicaset configuration to be applied ******"

# sleep $DELAY

# mongo < /scripts/init.js