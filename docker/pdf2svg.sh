#!/usr/bin/env sh

set -e

java -classpath "${CONTENTMINE_HOME}/lib/*" org.xmlcml.pdf2svg.PDF2SVGConverter $@
