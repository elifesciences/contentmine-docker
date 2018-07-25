# -------------------
# build builder image
# -------------------
FROM maven:3.5-jdk-8 as builder

ENV CONTENTMINE_HOME=/opt/contentmine

COPY docker/fetch-repo.sh /tmp/

ARG EUCLID_TAG=EUCLID_TAG
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/euclid/archive/${EUCLID_TAG}.zip \
  ${CONTENTMINE_HOME}/euclid && \
  cd ${CONTENTMINE_HOME}/euclid && mvn install -DskipTests

ARG CM_POM_TAG=master
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/cm-pom/archive/${CM_POM_TAG}.zip \
  ${CONTENTMINE_HOME}/cm-pom && \
  cd ${CONTENTMINE_HOME}/cm-pom && mvn install

ARG SVG_TAG=master
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/svg/archive/${SVG_TAG}.zip \
  ${CONTENTMINE_HOME}/svg && \
  cd ${CONTENTMINE_HOME}/svg && mvn install -DskipTests

ARG HTML_TAG=master
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/html/archive/${HTML_TAG}.zip \
  ${CONTENTMINE_HOME}/html && \
  cd ${CONTENTMINE_HOME}/html && mvn install

ARG PDF2SVG_TAG=master
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/pdf2svg/archive/${PDF2SVG_TAG}.zip \
  ${CONTENTMINE_HOME}/pdf2svg && \
  cd ${CONTENTMINE_HOME}/pdf2svg && mvn install

ARG SVG2XML_TAG=master
RUN /tmp/fetch-repo.sh \
  https://github.com/ContentMine/svg2xml/archive/${SVG2XML_TAG}.zip \
  ${CONTENTMINE_HOME}/svg2xml && \
  cd ${CONTENTMINE_HOME}/svg2xml && mvn package -DskipTests

# collect all of the jars and copy them into the lib directory
RUN mkdir -p ${CONTENTMINE_HOME}/lib && \
  cd ${CONTENTMINE_HOME}/pdf2svg && \
  mvn -DoutputDirectory=${CONTENTMINE_HOME}/lib dependency:copy-dependencies && \
  cd ${CONTENTMINE_HOME}/svg2xml && \
  mvn -DoutputDirectory=${CONTENTMINE_HOME}/lib dependency:copy-dependencies && \
  cp -a ${CONTENTMINE_HOME}/svg2xml/target/*.jar ${CONTENTMINE_HOME}/lib/ && \
  rm ${CONTENTMINE_HOME}/lib/*-jar-with-dependencies.jar && \
  ls -l ${CONTENTMINE_HOME}/lib/

# -------------------
# build runtime image
# -------------------
FROM python:3.6-stretch

ENV CONTENTMINE_HOME=/opt/contentmine
ENV CONTENTMINE_HOST=0.0.0.0
ENV CONTENTMINE_PORT=8080

RUN apt-get update && \
  apt-get install -y unzip && \
  apt-get install -y default-jre

COPY --from=builder ${CONTENTMINE_HOME}/lib ${CONTENTMINE_HOME}/lib

WORKDIR ${CONTENTMINE_HOME}

COPY docker/pdf2svg.sh docker/pdf2xml.sh ./
ENV PATH=${CONTENTMINE_HOME}:${PATH}

COPY requirements.txt ./requirements.server.txt
RUN pip install -r requirements.server.txt

COPY contentmine_server/ ./contentmine_server
COPY docker/healthcheck.sh requirements.dev.txt ./

CMD python -m contentmine_server.server

HEALTHCHECK --interval=10s --timeout=10s --retries=5 CMD ./healthcheck.sh
