#!/bin/bash

if [ "$1" = 'photon' ]; then
	shift 
	
	# if index does not yet exist, import from json.dump (if exists) or nominatim
	if [ ! -d "/photon/photon_data/elasticsearch" ]; then
		if [ ! -d $JSON_DUMP_FILE ]; then
			java -Xmx256m -jar photon-$PHOTON_VERSION.jar -json-import -json $JSON_DUMP_FILE -languages $PHOTON_LANGUAGES
		else 
			java -Xmx256m -jar photon-$PHOTON_VERSION.jar -nominatim-import -host $NOMINATIM_PORT_5432_TCP_ADDR -port $NOMINATIM_PORT_5432_TCP_PORT -languages $PHOTON_LANGUAGES
		fi 
		
		echo
		echo 'Photon init process complete; ready for start up.'
		echo
	fi

	exec java -jar photon-$PHOTON_VERSION.jar -languages $PHOTON_LANGUAGES "$@"
fi

exec "$@"
