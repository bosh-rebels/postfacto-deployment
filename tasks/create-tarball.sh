#!/bin/bash

set -euo pipefail
version=$(cat postfacto-version/version)
digest=$(cat postfacto-docker-image/digest)

echo "Creating postfacto package tarball with digest ${digest}..."
image_name="postfacto-package-${version}-${digest}.tgz"
mkdir -p ./output
tar -czf "./output/${image_name}" /package