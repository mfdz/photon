#!/bin/bash

if [ "$1" = 'photon' ]; then
	shift 
	
	if [ ! -d "/photon/photon_data/elasticsearch" ]; then
		java -Xmx256m -jar photon-$PHOTON_VERSION.jar -nominatim-import -host $NOMINATIM_PORT_5432_TCP_ADDR -port $NOMINATIM_PORT_5432_TCP_PORT -languages $PHOTON_LANGUAGES

		echo
		echo 'Photon init process complete; ready for start up.'
		echo
	fi

	exec java -jar photon-$PHOTON_VERSION.jar -languages $PHOTON_LANGUAGES "$@"
fi

exec "$@"
