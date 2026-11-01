#!/usr/bin/env bash

set -o errexit # This flag is a MUST HAVE!

FUNCTION_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
LAMBDA_BUCKET_NAME="lambda-cur-iroco2-local"

start_containers() {
  echo "Starting local stack containers..."
  if command -v podman; then
    podman compose up -d
  else
    docker compose up -d
  fi

}

deploy_lambda() {
  # Build Python dependencies and zip sources in a temporary directory,
  # removed on exit, so that each run packages only the current sources
  BUILD_DIR=$(mktemp -d)
  trap 'rm -rf "$BUILD_DIR"' EXIT
  python3 -m venv venv
  . venv/bin/activate
  mkdir "$BUILD_DIR/cur_processor"
  cp -r src "$BUILD_DIR/cur_processor/"
  pip install --platform manylinux2014_x86_64 --target "$BUILD_DIR/cur_processor/" -r requirements.txt --only-binary=:all:
  (cd "$BUILD_DIR/cur_processor" && zip -r ../src.zip .)

  aws --endpoint-url="$AWS_ENDPOINT_URL" --region="$AWS_REGION" s3 cp "$BUILD_DIR/src.zip" s3://$LAMBDA_BUCKET_NAME/lambda/cur/iroco2/cur_processor --checksum-algorithm SHA256

  aws --endpoint-url="$AWS_ENDPOINT_URL" --region="$AWS_REGION" lambda update-function-code \
      --function-name lambda-cur-processor-iroco2 \
      --s3-bucket $LAMBDA_BUCKET_NAME \
      --s3-key lambda/cur/iroco2/cur_processor \
      --no-cli-pager
  deactivate
}

# Moves to the lambda function directory
pushd "$FUNCTION_DIR"

echo "Setting environment variables"
export AWS_REGION="eu-west-3"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_ENDPOINT_URL="http://localhost:4566"

# Start docker compose stack
start_containers

pushd "$FUNCTION_DIR/tf"
terraform init -reconfigure
terraform apply -var-file="tfvars/local.tfvars" -var-file="env-configs/local.tfvars" -auto-approve

popd

deploy_lambda

# Reset for the user
popd

