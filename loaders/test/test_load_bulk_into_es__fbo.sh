#!/bin/bash

cd "$(dirname "$0")"
source ./setup.sh

echo "test_load_bulk_into_es__fbo.sh"; echo
echo "Recreating a test index"
curl -q -XDELETE localhost:9200/fbopen_test; curl -q -XPUT localhost:9200/fbopen_test; echo

echo "Indexing sample/fbo.bulk in ElasticSearch"
curl -q -s -XPOST 'http://localhost:9200/fbopen_test/_bulk' --data-binary @sample/fbo.bulk; echo

echo "Waiting for indexing..."; echo
sleep 2

# query ES via the multi get API
# http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/docs-multi-get.html
# actually, let's just do a query for everything for now.
# the multi get API wants us to specify all ids to bring back. we could write that into the test but let's be lazy.

echo "Querying the ES API for what we just indexed"
curl -s 'localhost:9200/fbopen_test/_search?size=50&pretty=true&q=*:*&fields=id&sort=_id:asc' > /tmp/fbopen_output

echo "Parsing out just the \"hits\" portion of the JSON"
cat /tmp/fbopen_output | json -ag hits > /tmp/fbopen_output.tmp
cat sample/output/fbo.json | json -ag hits > sample/output/fbo.json.tmp

# assert return contents
echo "Asserting output (/tmp/fbopen_output.tmp) equals expected (sample/output/fbo.json.tmp)"
assert "diff -q /tmp/fbopen_output.tmp sample/output/fbo.json.tmp"

curl -q -XDELETE 'http://localhost:9200/fbopen_test'; echo
assert_end load_bulk_fbo
