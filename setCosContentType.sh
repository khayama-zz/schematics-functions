#!/bin/bash
ARGS=$@

BUCKET_NAME=`echo "$ARGS" | jq -r '."bucket"'`
ENDPOINT=`echo "$ARGS" | jq -r '."endpoint"'`
OBJECT_NAME=`echo "$ARGS" | jq -r '."notification"."object_name"'`

OBJECT_DOT_EXT=${OBJECT_NAME/*./.}
CONTENT_TYPE=`echo "$ARGS" | jq -r '."notification"."content_type"'`

REFERENCE=$(curl https://gist.githubusercontent.com/khayama/7b73a2863a8f92c2ae4faca4ce2769d7/raw/27c8b1e28ce4c3aff0c0d8d3d7dbcb099a22c889/file-extension-to-mime-types.json | jq -c)
REF_CONTENT_TYPE=`echo "$REFERENCE" | jq -r '."'$OBJECT_DOT_EXT'"'`

ACCESS_TOKEN=`curl -k -X POST \
--header "Content-Type: application/x-www-form-urlencoded" \
--header "Accept: application/json" \
--data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
--data-urlencode "apikey=$__OW_IAM_NAMESPACE_API_KEY" \
"$__OW_IAM_API_URL" \
| jq -r .access_token`

if [ -n "$REF_CONTENT_TYPE" ]; then
  if [ $CONTENT_TYPE != $REF_CONTENT_TYPE ]; then
    curl -i -v -X PUT "https://$BUCKET_NAME.$ENDPOINT/$OBJECT_NAME" \
    -H "x-amz-copy-source: /$BUCKET_NAME/$OBJECT_NAME" \
    -H "x-amz-metadata-directive: REPLACE" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: $REF_CONTENT_TYPE" > /tmp/result.txt
    STATUS="replaced with reference content type"
  else
    touch /tmp/result.txt
    STATUS="not replaced (already correct content type)"
  fi
else
  touch /tmp/result.txt
  STATUS="not replaced (no reference content type is found)"
fi

RESULT=$(cat /tmp/result.txt)

echo "{ \
\"args\": $ARGS, \
\"bucket_name\": \"$BUCKET_NAME\", \
\"endpoint\": \"$ENDPOINT\", \
\"object_name\": \"$OBJECT_NAME\", \
\"object_dot_ext\": \"$OBJECT_DOT_EXT\", \
\"content_type\": \"$CONTENT_TYPE\", \
\"ref_content_type\": \"$REF_CONTENT_TYPE\", \
\"status\": \"$STATUS\", \
\"result\": $(RESULT="$RESULT" jq -n 'env.RESULT') \
}"
