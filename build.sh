#!/usr/bin/env bash

set -eo pipefail                   # Exit on error
exec > >(tee $HOME/build.log) 2>&1 # Write logs

source functions.sh # Import functions

# Handle errors
trap 'err "Failed to execute scommand $BASH_COMMAND"' ERR

# Create workspace dir
mkdir -p workspace && cd workspace

# Isntall dependencies
log "Installing build dependencies..."
curl -LSs https://raw.githubusercontent.com/akhilnarang/scripts/refs/heads/master/setup/android_build_env.sh | bash -

# Sync TWRP manifest
log "Syncing TWRP Manifest..."

git config --global user.name "tt"
git config --global user.email "ttt@users.noreply.github.com"

mkdir ~/OrangeFox_sync
cd ~/OrangeFox_sync
git clone https://gitlab.com/OrangeFox/sync.git # (or, using ssh, "git clone git@gitlab.com:OrangeFox/sync.git")
cd ~/OrangeFox_sync/sync/
./orangefox_sync.sh --branch 14.1 --path ~/fox_14.1

git config --global user.name "tt"
git config --global user.email "ttt@users.noreply.github.com"

cd ~/fox_14.1

# Clone Device tree
log "Cloning device tree..."
git clone https://github.com/smiley9000/twrp_samsung_a05m_6.6 device/samsung/a05m
git clone https://github.com/smiley9000/twrp_samsung_mt6768-common_6.6 device/samsung/mt6768-common

# Build TWRP
log "Building TWRP..."
export ALLOW_MISSING_DEPENDENCIES=true
. build/envsetup.sh
#lunch twrp_a05m-ap3a-eng
lunch twrp_a05m-ap2a-eng
mka adbd recoveryimage

curl https://bashupload.com -F=@/root/fox_14.1/out/target/product/a05m/OrangeFox-R11.3-Unofficial-a05m.zip
curl https://bashupload.com -F=@/root/fox_14.1/out/target/product/a05m/OrangeFox-R11.3-Unofficial-a05m.img
curl -F "file=@/root/fox_14.1/out/target/product/a05m/OrangeFox-R11.3-Unofficial-a05m.img" https://temp.sh/upload
curl -F "file=@/root/fox_14.1/out/target/product/a05m/OrangeFox-R11.3-Unofficial-a05m.zip" https://temp.sh/upload

# Files
OUT_PATH="out/target/product/a05m"
OUTPUT_FILES=$(realpath "$OUT_PATH"/*.img)

# Create GitHub release
log "Creating GitHub release..."
export GITHUB_TOKEN="$GH_TOKEN"
DATE=$(TZ="$TIMEZONE" date +"%Y%m%d-%H%M")
RELEASE_TAG="twrp-${DEVICE_NAME}-${DATE}"
RELEASE_NAME="TWRP ${DEVICE_NAME} ${DATE}"

# Upload output file to github release
URL=$(
  gh release create "$RELEASE_TAG" \
    $OUTPUT_FILES \
    --title "$RELEASE_NAME" \
    -R "$RELEASE_REPO" \
    2> /dev/null
)


exit 0
