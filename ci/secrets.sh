#!/bin/bash

export_secret() {
	echo "::set-env name=${1}::$(echo $SECRETS | jq -r ".${1}")"
}

case "$PROVIDER" in
aws)
  export_secret AWS_ACCESS_KEY_ID
  export_secret AWS_DEFAULT_REGION
  export_secret AWS_SECRET_ACCESS_KEY
  ;;
azure)
  export_secret ARM_CLIENT_ID
  export_secret ARM_CLIENT_SECRET
  export_secret ARM_SUBSCRIPTION_ID
  export_secret ARM_TENANT_ID
  ;;
do)
  export_secret TF_VAR_access_id
  export_secret TF_VAR_secret_key
  export_secret TF_VAR_token
  ;;
gcp)
  export_secret GOOGLE_CREDENTIALS
  export_secret GOOGLE_PROJECT
  export_secret GOOGLE_REGION
  ;;
esac