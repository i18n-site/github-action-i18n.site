#!/usr/bin/env bash

set -ex

APP=$1

REPO=https://github.com/i18n-site/rust/releases/download/
CURL="curl --retry 9 -L --connect-timeout 6"
ver=$(curl -sSL ${REPO}v/$APP)

# exist_ver=$([[ -x ./bin/$APP ]] && ./bin/$APP -v 2>/dev/null || echo "")
# [[ "$ver" == "$exist_ver" ]] && exit 0

get_libc() {
  local os=$(uname -s)
  case $os in
  Darwin) echo "apple-darwin" ;;
  Linux)
    if ldd --version 2>&1 | grep -q 'musl'; then
      echo "unknown-linux-musl"
    else
      echo "unknown-linux-gnu"
    fi
    ;;
  CYGWIN* | MINGW* | MSYS*)
    echo "pc-windows-msvc"
    ;;
  *)
    throw unknown libc
    ;;
  esac
}

libc=$(get_libc)

get_arch() {
  if [[ "$libc" == "pc-windows-msvc" ]]; then
    local winarch=$(wmic os get osarchitecture | sed -n '2p')
    if [[ $winarch == "ARM 64"* ]]; then
      echo "aarch64"
    else
      echo "x86_64"
    fi
  else
    case $(uname -m) in
    aarch64 | arm64) echo "aarch64" ;;
    x86_64) echo "x86_64" ;;
    *)
      echo "unknown arch"
      ;;
    esac
  fi
}

arch=$(get_arch)

name="${arch}-${libc}"

url="${REPO}${APP}/${ver}/${name}.tar"

mkdir -p bin
cd bin
$CURL -C - -OL "$url"

tarRm() {
  tar -xf $@
  rm -rf $1
}

tarRm ${name}.tar
tarRm $ver.txz
rm $ver.txz.hsc
