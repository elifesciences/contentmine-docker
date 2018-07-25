# ContentMine Docker

A docker image for [ContentMine's svg2xml](https://github.com/ContentMine/svg2xml).

## Pre-requistes

* [Docker](https://www.docker.com/)

## Build Container

```bash
docker-compose build
```

## Run Container

```bash
docker-compose up --build
```

or:

```bash
docker run -p 8076:8080 elifesciences/contentmine
```

## Server

```bash
curl -X POST --show-error --form \
  "file=@test.pdf;filename=test.pdf" \
  http://localhost:8076/api/convert
```

Note: the API only accepts PDF files (`application/pdf`).

## CLI

```bash
docker-compose run --rm contentmine pdf2xml.sh /data/36356.pdf
```
