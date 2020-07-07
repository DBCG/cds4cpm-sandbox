# CDS4CPM Sandbox

## Overview

The [Clinical Decision Support for Chronic Pain Management and Shared Decision-Making IG](https://github.com/cqframework/cds4cpm) (CDS4CPM) is a specification for services and operations that, taken together, allow patients and practitioners collaboratively make decision about chronic pain management.

The repository contains documentation and scripts that allow a functioning sandbox demonstrating the overall solution to be stood up. There are several services involved:

* The [MyPain](https://github.com/cqframework/cds4cpm-mypain) application, which is a patient facing portal
* The [PainManager](https://github.com/cqframework/cds4cpm-mypain) application, which is a provider facing portal
* The [CQF-Ruler](https://github.com/DBCG/cqf-ruler), which functions as a FHIR database.
* The [Smart-Launcher](https://github.com/cqframework/smart-launcher) application, which simulates a launch from an EHR

Site-specific configuration for the solution may vary. This repository servers as a reference for where those configuration points are.

## Prerequisites

[Docker](https://docs.docker.com/get-docker/) version 19+

## Services

The sandbox uses docker-compose to set up several containers and link them all together to represent the complete system, as shown in the diagram below:

![Services](assets/architecture.drawio.svg)

The [docker-compose.yml](docker/docker-compose.yml) file documents how each of those containers are configured to make the overall system work. Certain elements may not be required in each deployment. Specifically, the Smart Launcher will typically be replaced with an EHR's Smart Launch capability, the CQF-Ruler may be replaced with a site-specific FHIR server or facade, and the Traefik reverse proxy container would be replaced by a given site's networking solution.

The various services are available at:

[http://smart-launcher.localhost](http://smart-launcher.localhost)

[http://my-pain.localhost](http://my-pain.localhost)

[http://pain-manager.localhost](http://pain-manager.localhost)

[http://cqf-ruler.localhost](http://pain-manager.localhost)

The relevant configuration options that are used for each service are documented below.

## Usage

### Starting the Sandbox

This project uses a docker-compose file to do all of the above configuration for you automatically. The file is located [here](docker/docker-compose.yml) and demonstrates the usage of the various options.

From the /docker directory, run:

```bash
docker-compose pull
docker-compose up
```

The appropriate docker containers will be downloaded and started. It may take a several minutes for all the containers to download and start.

***NOTE:*** On Windows Docker may ask to access your local hard-drive due to sample data and configuration being shared with the cqf-ruler from this repository. Please give Docker permissions to access the drive.

You can then browse the smart-launcher to select the correct applications and FHIR server by browsing

[http://smart-launcher.localhost](http://smart-launcher.localhost)

When you're done with the sandbox, the services can be stopped by pressing `Ctrl+C`. The services can then be deleted.

```bash
docker-compose down
```

Detailed information on the `docker-compose` command can be found on the [Docker website](https://docs.docker.com/compose/)

### Using the Sandbox

***NOTE:*** These steps require the use of the Chrome browser at the present time.

#### Selecting a Patient

Browse to [http://smart-launcher.localhost](http://smart-launcher.localhost)

Open the Patient Selector by clicking the arrow as shown in the following image

![Launch Patient Selector](assets/patient-selector-launch.png)

The Patient Selector will open. The Sandbox has been pre-populated with Brenda Jackson. Select a patient from the list and click "Ok" as shown in the following image

![Select Patient](assets/patient-select.png)

#### Launching MyPain or PainManager

Enter the launch url of MyPain or PainManager into the "Launch" box and click Launch as shown in the image below

![Launch App](assets/app-launch.png)

The launch urls are as follows:

MyPain

`http://my-pain.localhost/launch.html`

PainManager

`http://pain-manager.localhost/launch.html`

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

Working examples of the configurations files for the cqf-ruler are located in the [docker/config/cqf-ruler](docker/config/cqf-ruler) folder.

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

This configuration is demonstrated in the in the [docker-compose.yml](docker/docker-compose.yml) file.

### Smart Launcher

#### FHIR Servers

The FHIR servers available are set with environment variables as demonstrated in the [docker-compose.yml](docker/docker-compose.yml) file.

```yaml
environment:
  - "FHIR_SERVER_R4=http://cqf-ruler.localhost/cqf-ruler-r4/fhir"
  - "FHIR_SERVER_R3=http://cqf-ruler.localhost/cqf-ruler-dstu3/fhir"
```

The base urls expected for the launcher are set with the BASE_URL and CDS_SANDBOX_URL environment variables:

```yaml
  environment: 
    - "CDS_SANDBOX_URL=http://smart-launcher.localhost"
    - "BASE_URL=http://smart-launcher.localhost"
```

## License

Apache 2.0
