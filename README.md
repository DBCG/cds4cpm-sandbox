# CDS4CPM Sandbox

## Overview

The [Clinical Decision Support for Chronic Pain Management and Shared Decision-Making IG](https://github.com/cqframework/cds4cpm) (CDS4CPM) is a specification for services and operations that, taken together, allow patients and practitioners collaboratively make decision about chronic pain management.

The repository contains documentation and scripts that allow a functioning sandbox demonstrating the overall solution to be stood up. There are 3 main components involved:

* The MyPain application, which is a patient facing portal
* The PainManager application, which is a provider facing portal
* The Cqf-Ruler, which functions as a FHIR database.

Site-specific configuration for the solution may vary, but this repository servers as a reference for where those configuration points are.

**NOTE:** Currently this document only contains information on the Cqf-Ruler - The other services are WIP

## Prerequisites

[Docker](https://docs.docker.com/get-docker/) version 19+

## Usage

From the /docker directory, run:

```bash
docker-compose pull
docker-compose up
```

The appropriate docker containers will be downloaded and started.

When you're done with the sandbox, the services can be terminated with

```bash
docker-compose down
```

Detailed information on the `docker-compose` command can be found on the [Docker website](https://docs.docker.com/compose/)

## Configuration

### Cqf-Ruler

The primary source for documentation of the deployment of cqf-ruler
 is located at the Cqf-Ruler wiki on the [Deployment](https://github.com/DBCG/cqf-ruler/wiki/Deployment) page.

For usage in the CDS4CPM sandbox several specific options need to be enabled:

1. OAuth Redirection to an authorization server
2. Questionnaire Response extraction

Both of these are enabled by setting properties in a configuration file. This configuration file is then mounted into the Docker container where the cqf-ruler can read and load it.

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

The cqf-ruler reads the JAVA_OPTIONS environment variable to determine where it should look for configuration, like so:

```bash
docker run -e JAVA_OPTIONS='-Dhapi.properties.R4=/path/to/custom/r4.properties, -Dhapi.properties.DSTU3=/path/to/custom/dstu3.properties'
```

where `/path/to/custom` is some location inside of the cqf-ruler docker container.

Once you have created the appropriate configuration files you combine both of these options to mount the config files into the container from the host system and have the cqf-ruler read them.

```bash
docker run \
--v ./config/cqf-ruler:/var/lib/jetty/target \
-e JAVA_OPTIONS='-Dhapi.properties.R4=/var/lib/jetty/target/r4.properties, -Dhapi.properties.DSTU3=/var/lib/jetty/target/dstu3.properties' \
contentgroup/cqf-ruler:develop
```

## Docker Compose

This project uses a docker-compose file to do all of the above configuration for you automatically when you run `docker-compose up`. The docker-compose.yml file is located [here](docker/docker-compose.yml) and demonstrates the usage of the various options.

Further information on Docker compose files is available [here](https://docs.docker.com/compose/)

## License

Apache 2.0
