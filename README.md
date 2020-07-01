# CDS4CPM Sandbox

## Overview

The [Clinical Decision Support for Chronic Pain Management and Shared Decision-Making IG](https://github.com/cqframework/cds4cpm) (CDS4CPM) is a specification for services and operations that, taken together, allow patients and practitioners collaboratively make decision about chronic pain management.

The repository contains documentation and scripts that allow a functioning sandbox demonstrating the overall solution to be stood up. There are several services involved:

* The [MyPain](https://github.com/cqframework/cds4cpm-mypain) application, which is a patient facing portal
* The [PainManager](https://github.com/cqframework/cds4cpm-mypain) application, which is a provider facing portal
* The [CQF-Ruler](https://github.com/DBCG/cqf-ruler), which functions as a FHIR database.

Site-specific configuration for the solution may vary, but this repository servers as a reference for where those configuration points are. Additionally, this sandbox includes:

* The [Smart-launcher](https://github.com/cqframework/smart-launcher), which simulates a launch from an EHR

## Prerequisites

[Docker](https://docs.docker.com/get-docker/) version 19+

## Usage

This project uses a docker-compose file to do all of the above configuration for you automatically. The file is located [here](docker/docker-compose.yml) and demonstrates the usage of the various options.

From the /docker directory, run:

```bash
docker-compose pull
docker-compose up
```

The appropriate docker containers will be downloaded and started. It may take a several minutes for all the containers to download and start.

You can then browse the smart-launcher to select the correct applications and FHIR server by browsing

[http://smart-launcher.localhost](http://smart-launcher.localhost)

When you're done with the sandbox, the services can be terminated with

```bash
docker-compose down
```

Detailed information on the `docker-compose` command can be found on the [Docker website](https://docs.docker.com/compose/)

## Architecture

The docker-compose.yml file sets up several containers and links them all together as shown in the diagram below in order to represent the complete system:

![Architecture](assets/architecture.drawio.svg)

The docker-compose.yml file documents how each of those containers are configured to make the overall system work. Certain elements may not be required in each deployment. Specifically, the Smart Launcher will typically be replaced with an EHR's Smart Launch capability, the CQF-Ruler may be replaced with a site-specific FHIR server or facade, and the Traefik reverse proxy container would be replaced by a given site's networking solution.

The various services will be available at:

[http://smart-launcher.localhost](http://smart-launcher.localhost)

[http://my-pain.localhost](http://my-pain.localhost)

[http://pain-manager.localhost](http://pain-manager.localhost)

[http://cqf-ruler.localhost](http://pain-manager.localhost)

The relevant configuration options that are used for each service are documented below.

## Configuration

### CQF-Ruler

The primary source for documentation of the deployment of CQF-Ruler
 is located at the CQF-Ruler wiki on the [Deployment](https://github.com/DBCG/cqf-ruler/wiki/Deployment) page.

For usage in the CDS4CPM sandbox several specific options need to be enabled:

1. OAuth Redirection to an authorization server
2. Questionnaire Response extraction
3. Server base address

All of these are enabled by setting properties in a configuration file. This configuration file is then mounted into the Docker container where the CQF-Ruler can read and load it.

#### OAuth Redirection

Adding the following lines to the configuration file enables OAuth Redirection

```yaml
##################################################
# OAuth Settings
##################################################
oauth.enabled=true
oauth.securityCors=true
oauth.securityUrl=http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris
oauth.securityExtAuthUrl=authorize
oauth.securityExtAuthValueUri=http://launch.smarthealthit.org/v/r4/auth/authorize
oauth.securityExtTokenUrl=token
oauth.securityExtTokenValueUri=http://launch.smarthealthit.org/v/r4/auth/token
oauth.serviceSystem=http://hl7.org/fhir/restful-security-service
oauth.serviceCode=SMART-on-FHIR
oauth.serviceDisplay=SMART-on-FHIR
oauth.serviceText=OAuth2 using SMART-on-FHIR profile (see http:?/docs.smarthealthit.org)
```

The links in the sample above use the SMART-on-FHIR launch application available at [http://launch.smarthealthit.org](http://launch.smarthealthit.org).

In particular, the `oauth.securityUrl`, `oauth.securityExtAuthValueUri`, and `oauth.securityExtTokenValueUri` values will need to be set appropriately for your environment.

#### QuestionnaireResponse Extraction

Adding the following lines to the configuration file enables QuestionnaireResponse extraction.

```yaml
##################################################
# QuestionnaireResponse Extraction Settings
##################################################
observation.enabled=true
observation.endpoint=https://cds4cpm-develop.sandbox.alphora.com/cqf-ruler-r4/fhir
observation.username=
observation.password=
```

The `observation.endpoint` is where the extracted Observation will be PUT. `observation.username` and `observation.password` are used to configure credentials for that endpoint.

#### Server Address

These properties are inherited from the HAPI FHIR server.

```yaml
##################################################
# Server Address
##################################################
server_address=http://cqf-ruler.localhost/cqf-ruler-dstu3/fhir/
server.base=/cqf-ruler-dstu3/fhir
```

Working examples of the configurations files are located in the [docker/config/cqf-ruler](docker/config/cqf-ruler) folder.

#### Mounting Configuration Files

Docker supports mounting external files into a container. The syntax for this is:

```bash
docker run --v /source:/target fooContainer
```

The directory located on the host at /source will be available in the container at /target.

Docker also supports setting environment variables for a container. The syntax for that is:

```bash
docker run -e ENV_VARIABLE=value fooContainer
```

The CQF-Ruler reads the JAVA_OPTIONS environment variable to determine where it should look for configuration, like so:

```bash
docker run -e JAVA_OPTIONS='-Dhapi.properties.R4=/path/to/custom/r4.properties, -Dhapi.properties.DSTU3=/path/to/custom/dstu3.properties'
```

where `/path/to/custom` is some location inside of the cqf-ruler docker container.

Once you have created the appropriate configuration files you combine both of these options to mount the config files into the container from the host system and have the CQF-Ruler read them.

```bash
docker run \
--v ./config/cqf-ruler:/var/lib/jetty/target \
-e JAVA_OPTIONS='-Dhapi.properties.R4=/var/lib/jetty/target/r4.properties, -Dhapi.properties.DSTU3=/var/lib/jetty/target/dstu3.properties' \
contentgroup/cqf-ruler:develop
```

### Smart Launcher

#### FHIR Servers

The FHIR servers available are set with environment variables as demonstrated in the docker-compose.yml file.

```yaml
    environment: 
      - "FHIR_SERVER_R4=http://cqf-ruler.localhost/cqf-ruler-r4/fhir"
      - "FHIR_SERVER_R3=http://cqf-ruler.localhost/cqf-ruler-dstu3/fhir"
```

## License

Apache 2.0
