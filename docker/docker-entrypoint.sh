#!/bin/bash

if [ "$1" = 'photon' ]; then
  shift

  # if index does not yet exist, import from $JSON_DUMP_FILE (if exists) or nominatim
  if [ ! -d "/photon/photon_data/elasticsearch" ]; then
    if [ -f $JSON_DUMP_FILE ]; then
      java -Xmx256m -jar photon.jar -json-import -json $JSON_DUMP_FILE -languages $PHOTON_LANGUAGES
    else
      java -jar photon.jar \
        -nominatim-import \
        -host      $NOMINATIM_DB_HOST \
        -port      $NOMINATIM_DB_PORT \
        -user      $NOMINATIM_DB_USER \
        -password  $NOMINATIM_DB_PASSWORD \
        -extra-tags ref:IFOPT \
        -languages $PHOTON_LANGUAGES
    fi

    echo
    echo 'Photon init process complete; ready for start up.'
    echo
  fi

  if [ "$AUTOMATIC_UPDATES" = true ] ; then
    crontab /etc/cron.d/nominatim-update
    # if you start photon with the credentials for the nominatim db you still have to call the /nominatim-endpoint manually
    # in this docker image this happens through a cron job at 5am every day
    cron && exec java -jar photon.jar \
      -host      $NOMINATIM_DB_HOST \
      -port      $NOMINATIM_DB_PORT \
      -user      $NOMINATIM_DB_USER \
      -password  $NOMINATIM_DB_PASSWORD \
      -extra-tags ref:IFOPT \
      -languages $PHOTON_LANGUAGES "$@"
  else
    exec java -jar photon.jar -extra-tags ref:IFOPT -languages $PHOTON_LANGUAGES "$@"
  fi

fi

exec "$@"
