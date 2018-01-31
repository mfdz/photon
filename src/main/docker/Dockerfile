FROM openjdk:8

MAINTAINER Holger Bruch <holger.bruch@mitfahrdezentrale.de>

ARG PHOTON_LANGUAGES
ENV PHOTON_LANGUAGES ${PHOTON_LANGUAGES:-"de,en,fr"}

# If photon-db does not exist in /photon/photon_data, the following properties 
# will be used to create index from nominatim
ENV NOMINATIM_PORT_5432_TCP_ADDR nominatim
ENV NOMINATIM_PORT_5432_TCP_PORT 5432

# Download photon release
RUN mkdir /photon \
	&& cd /photon 
	
WORKDIR /photon

# Expose Photon Webservice and Elastic Search (ES)
EXPOSE 2322 9200

# To mount external folder supply -v /path/on/host:/photon/photon_data to docker run
VOLUME /photon/photon_data

COPY docker-entrypoint.sh /photon/docker-entrypoint.sh
RUN chmod ugo+x /photon/docker-entrypoint.sh

COPY maven/ /photon/
ENV PHOTON_VERSION=@docker.project.version@

ENTRYPOINT ["/photon/docker-entrypoint.sh"]

CMD ["photon"]
