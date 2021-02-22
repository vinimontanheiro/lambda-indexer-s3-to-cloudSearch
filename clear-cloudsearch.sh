#!/bin/bash

CS_DOMAIN=""
TMP_DELETE_FILE=/tmp/delete-all-cloudsearch-documents.json
TMP_RESULTS_FILE=/tmp/delete-all-cloudsearch-documents-tmp-results.json

while [ 1 -eq 1 ]; do
   aws cloudsearchdomain search \
      --endpoint-url=$CS_DOMAIN \
      --size=10000 \
      --query-parser=structured \
      --search-query="matchall" > ${TMP_RESULTS_FILE}

   cat ${TMP_RESULTS_FILE} | jq '[.hits.hit[] | {type: "delete", id: .id}]' > ${TMP_DELETE_FILE}

   CNT_TOTAL=$(cat ${TMP_RESULTS_FILE} | jq '.hits.found')
   CNT_DOCS=$(cat ${TMP_DELETE_FILE} | jq '. | length')

   if [[ $CNT_DOCS -gt 0 ]]; then
      echo "About to delete ${CNT_DOCS} documents of ${CNT_TOTAL} total in index"

      aws cloudsearchdomain upload-documents \
         --endpoint-url=$CS_DOMAIN \
         --content-type='application/json' \
         --documents=${TMP_DELETE_FILE}
   else
      echo "No more docs to delete"
      exit 0
   fi
done