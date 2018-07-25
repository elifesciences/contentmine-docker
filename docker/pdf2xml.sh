#!/usr/bin/env sh

set -e

mkdir -p target/svg
mkdir -p target/xml

java -classpath "${CONTENTMINE_HOME}/lib/*" org.xmlcml.svg2xml.pdf.PDFAnalyzer $@

find target
