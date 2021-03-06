FROM maven:3.6.3-jdk-11 as build

COPY ./pom.xml ./pom.xml

RUN mvn dependency:go-offline -B

COPY ./src ./src
COPY ./es ./es

RUN mvn package
RUN ls -l ./target

FROM openjdk:11-slim

MAINTAINER Holger Bruch <holger.bruch@mitfahrdezentrale.de>

ARG PHOTON_LANGUAGES
ENV PHOTON_LANGUAGES ${PHOTON_LANGUAGES:-"de,en,fr"}

# If photon-db does not exist in /photon/photon_data, the following properties
# will be used to import json dump file (if existant) or create index from nominatim
ENV NOMINATIM_DB_HOST nominatim
ENV NOMINATIM_DB_PORT 5432
ENV NOMINATIM_DB_USER nominatim
ENV NOMINATIM_DB_PASSWORD ""
ENV JSON_DUMP_FILE /photon/photon_data/photon_db.json

# run the update every day at 5 o'clock
ADD docker/nominatim-update /usr/local/bin/nominatim-update
RUN chmod g+w,o-rw,a+x /usr/local/bin/nominatim-update
ADD docker/crontab /etc/cron.d/nominatim-update
RUN chmod 0644 /etc/cron.d/nominatim-update
RUN touch /var/log/nominatim-update.log
RUN apt-get update && apt-get -y --no-install-recommends install cron curl && rm -rf /var/lib/apt/lists/*

# Download photon release
RUN mkdir /photon \
	&& cd /photon

WORKDIR /photon

# Expose Photon Webservice and Elastic Search (ES)
EXPOSE 2322 9200

# To mount external folder supply -v /path/on/host:/photon/photon_data to docker run
VOLUME /photon/photon_data
COPY --from=build target/photon-*.jar photon.jar
ADD docker/docker-entrypoint.sh /photon/docker-entrypoint.sh
RUN chmod ugo+x /photon/docker-entrypoint.sh

ENTRYPOINT ["/photon/docker-entrypoint.sh"]

CMD ["photon"]
