#!/bin/bash

set -euo pipefail
version=$(cat rootfs-version/version)
digest=$(cat postfacto-docker-image/digest)

echo "Creating postfacto package tarball with digest ${digest}..."
image_name="postfacto-package-${version}-${digest}.tar"
mkdir -p ./output
tar -cf "./output/${image_name}" /package