#!/bin/bash

# this clears mongo dbs
mongo superdesk --eval "db.dropDatabase()"
mongo legal_archive --eval "db.dropDatabase()"
mongo superdesk_e2e --eval "db.dropDatabase()"
mongo superdesk_e2e_legal_archive --eval "db.dropDatabase()"

# this clears redis ALL dbs
redis-cli flushall

# this clears elastic search indexes
curl -XDELETE 'http://localhost:9200/superdesk'
curl -XDELETE 'http://localhost:9200/superdesk_e2e'
