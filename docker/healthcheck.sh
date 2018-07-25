#!/usr/bin/env sh

set -ex

bash -c 'echo > /dev/tcp/localhost/${CONTENTMINE_PORT}'
