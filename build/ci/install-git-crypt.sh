#!/bin/bash

set -e

EX_OSFILE=72

PWD="$(pwd)"
export PWD

cd "/tmp/" || exit $EX_OSFILE

git clone https://github.com/AGWA/git-crypt.git

cd git-crypt || exit $EX_OSFILE

make
make install

cd "${PWD}" || exit $EX_OSFILE
