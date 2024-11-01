#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
set -ex

$DIR/setup.sh i18n.site
