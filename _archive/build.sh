#!/bin/bash
set -e  # Exit on error

echo "🔧 Installing libvips..."
apt-get update
apt-get install -y libvips-tools

echo "🔧 Installing yq..."
YQ_VERSION="v4.43.1"
curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o yq
chmod +x yq
mv yq /usr/local/bin/yq

echo "📦 Generating assets..."
chmod +x scripts/generate_assets.sh
./scripts/generate_assets.sh

echo "💎 Installing Jekyll..."
gem install jekyll

echo "🏗️ Building site with config and CDN settings..."
jekyll build --config _config.yml,_config-cdn.yml
