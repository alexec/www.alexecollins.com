#!/bin/sh
set -eux

jpegoptim -o $(find source -name '*.jpg')
pngcrush -brute -ow $(find source -name '*.png')
