#!/usr/bin/env sh

# This script is used within GitLab CI to create the proper zip files for the layers.
# This should not be ran locally when using localstack since localstack free can't use lambda layers.

set -o errexit

echo "Creating zip file for lambda layers"
mkdir -p ./layers

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Create a single consolidated layer with all dependencies
echo "Creating python directory for the layer"
mkdir -p ./python

echo "Installing all dependencies"
pip install --platform manylinux2014_x86_64 --only-binary=:all: --target ./python -r requirements.txt

echo "Compressing dependencies into a single layer"
python -m zipfile -c "./layers/dependencies.zip" "./python/"

echo "Cleaning up"
rm -Rf "./python"
