#!/bin/sh

# for use with golang image only

# install manifest-tool from https://github.com/estesp/manifest-tool
cd ${GOPATH}/src
mkdir -p github.com/estesp
cd github.com/estesp
git clone https://github.com/estesp/manifest-tool
cd manifest-tool && make binary

# push manifest list (spec must be provided in docker run command)
./manifest-tool push from-spec