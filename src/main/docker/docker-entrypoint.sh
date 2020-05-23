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

  if [ "$AUTOMATIC_UPDATES" = true ] ; then
    # if you start photon with the credentials for the nominatim db you still have to call the /nominatim-endpoint manually
    # in this docker image this happens through a cron job at 5am every day
    exec java -jar photon-$PHOTON_VERSION.jar -host $NOMINATIM_PORT_5432_TCP_ADDR -port $NOMINATIM_PORT_5432_TCP_PORT -languages $PHOTON_LANGUAGES "$@"
  else
    exec java -jar photon-$PHOTON_VERSION.jar -languages $PHOTON_LANGUAGES "$@"
  fi

fi

exec "$@"
