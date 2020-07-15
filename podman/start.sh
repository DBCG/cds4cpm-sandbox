#!/bin/bash

podman run -dt --name my-pain  contentgroup/painmanager:develop
podman run -dt --name pain-manager  contentgroup/painmanager:develop

podman run -dt --name traefik -p 8888:80 -p 8080:8080 \
-v ../services/traefik/traefik.yaml:/traefik.yaml \
-v ../services/traefik/config:/config \
traefik:v2.2

podman run -dt --name cqf-ruler \
-e "JAVA_OPTIONS=-Dhapi.properties.R4=/var/lib/jetty/target/config/r4.properties -Dhapi.properties.DSTU3=/var/lib/jetty/target/config/dstu3.properties" \
-v ../services/cqf-ruler/config:/var/lib/jetty/target/config:ro \
-v ../services/cqf-ruler/h2:/var/lib/jetty/target/database/h2:rw \
contentgroup/cqf-ruler:develop

podman run -dt --name smart-launcher \
-e "FHIR_SERVER_R4=http://cqf-ruler.localhost:8888/cqf-ruler-r4/fhir" \
-e "FHIR_SERVER_R3=http://cqf-ruler.localhost:8888/cqf-ruler-dstu3/fhir" \
-e "FHIR_SERVER_R4_INTERNAL=http://cqf-ruler:8080/cqf-ruler-r4/fhir" \
-e "FHIR_SERVER_R3_INTERNAL=http://cqf-ruler:8080/cqf-ruler-dstu3/fhir" \
-e "CDS_SANDBOX_URL=http://smart-launcher.localhost" \
-e "BASE_URL=http://smart-launcher.localhost" \
contentgroup/smart-launcher:develop