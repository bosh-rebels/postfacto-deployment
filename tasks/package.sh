#!/usr/bin/env bash

set -euf -o pipefail

apt update
apt install -y nodejs
wget -O package.zip --no-check-certificate http://github.com/pivotal/postfacto/releases/download/4.3.11/package.zip
unzip package.zip
cd package/assets
rm -rf Gemfile.lock
sed -i "s/ruby '2.7.3'/ruby '2.7.2'/g" Gemfile
gem install bundler -v 2.2.7
bundle _2.2.7_ install
bundle _2.2.7_ package --all-platforms
./bin/rails assets:precompile
