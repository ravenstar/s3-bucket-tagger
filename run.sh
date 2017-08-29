#!/usr/bin/env bash

function check_aws_creds()
{
  $(aws sts get-caller-identity &>/dev/null)

  if [ $? -ne 0 ]; then
    echo " Unable to validate AWS credentials! Aborting!"
    exit 1;
  fi
}

function tagBucket()
{
  zBucket="${1}"
  _TagFile="tags.json"
  _successMsg="\033[1;32mAdded tag!\033[0m"

  zTagFile=$(mktemp /tmp/s3-tag.XXXXXX)
  cat "${_TagFile}" > ${zTagFile}
  sed -i "s/%_BucketName%/${zBucket}/g" ${zTagFile}

  echo -n "Checking ${zBucket} : "

  zBucketTags=$(aws s3api get-bucket-tagging --bucket "${zBucket}" --output text 2>/dev/null)
  zBucketNameTagExists=$(echo ${zBucketTags} | grep -q "BucketName")

  if [ $? -eq 0 ]
  then
    # Tag 'BucketName' was already found/defined...
    zOldTag=$(echo ${zBucketTags} | tr '[:blank:]' ' ' | rev | cut -d' ' -f1 | rev)

    if [ "${zOldTag}" == "${zBucket}" ]
    then
      _successMsg="\033[1;34mTag already exact same\033[0m"
    else
      _successMsg="\033[1;33mChanged from ${zOldTag}!\033[0m"
    fi

  fi


  zAddTags=$(aws s3api put-bucket-tagging --bucket "${zBucket}" --tagging "file://${zTagFile}" --output text)

  if [ $? -ne 0 ]
  then
    echo -e "\033[1;31mFAIL\033[0m"
  else
    echo -e ${_successMsg}
  fi

  rm -f "${zTagFile}"
}


check_aws_creds

pushd `dirname $0` > /dev/null

zBuckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text | tr '[:blank:]' ' ' | tr ' ' '\n')

while read -r line; do
  zBucket="${line}"
  [ "${zBucket: -1}" == "/" ] && { zBucket=${zBucket: : -1}; } # Remove trailing slash

  tagBucket "${zBucket}"

done <<< "${zBuckets}"

popd > /dev/null
