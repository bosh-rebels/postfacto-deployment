#!/bin/bash

set -euo pipefail
version=$(cat postfacto-version/version)

echo "Creating postfacto tarball with version ${version}..."
image_name="postfacto-package-${version}.tgz"
mkdir -p ./output
tar -czf "./output/${image_name}" /package
