#!/bin/bash

# Actualizacion de IP en route53

RUTABASE=/home/ubuntu/route53ssl
PLANTILLA=plantilla_registrodns.json
JSON=registrodns.json

# Zona Hostedada
ZONA=`aws route53 list-hosted-zones-by-name  | jq --arg name "tuzona.delegada.es." -r '.HostedZones | .[] | select(.Name=="\($name)") | .Id'`

# IP del nodo
IPNODO=`curl http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null`

# Nombre corto del nodo
NOMBRE=`hostname -s`

# Copiamos la plantilla para el Json
cp ${RUTABASE}/${PLANTILLA} ${RUTABASE}/${JSON}

# Modificamos la IP publica y el nombre del nodo
sed -i 's/IPPUBLICA/'"${IPNODO}"'/g' ${JSON}
sed -i 's/NOMBREHOST/'"{NOMBRE}"'/g' ${JSON}

# Creamos o actualizamos el registro (upsert)
aws route53 change-resource-record-sets --hosted-zone-id ${ZONA} --change-batch file://${JSON}
