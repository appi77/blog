# OpenText Content Management

[Content Management](https://www.opentext.com/products-and-solutions/products/enterprise-content-management/extended-ecm-platform) is the market leading Enterprise Content Management platform that integrates content and content management in leading business applications such as SAP, Salesforce and Microsoft.

This Helm chart supports the deployment of Content Management on Kubernetes platforms. It packages the Content Management chart (Content Server) and all necessary components (Archive Center, Core Archive Connector, Directory Services, Intelligent Viewing and PowerDocs)

Please, refer to the product release notes in OpenText My Support to make sure to only use supported environments for production use.

## TLDR

Untar the helm chart. Provide the imageSource for your docker registry.

```console
--set global.imageSource=example.com/path/toyour/container \
```

If you do not have a domain/DNS created and are using kubernetes load balancers for testing purposes, use the following helm values for any components you are using.

```console
--set global.ingressEnabled=false \
--set global.otacPublicUrl="" \
--set global.otcsPublicUrl="" \
--set global.otdsPublicUrl="" \
--set global.otpdPublicUrl="" \
```

If you have a domain/DNS, provide the various `xxxxPublicUrl` fields and ingressDomainName.

```console
--set global.ingressDomainName=example.com \
--set global.otcsPublicUrl="https://otcs.example.com" \
--set global.otdsPublicUrl="https://otds.example.com" \
--set global.otacPublicUrl="https://otac.example.com" \
--set global.otaccPublicUrl="https://otacc.example.com" \
--set global.otpdPublicUrl="https://otpd.example.com" \
```

If you are deploying on an IPv6 Environment, the folowing values will need to be provided.

```console
--set otcs.config.socketIPFamilyHint=2 \
--set 'global.ingressAnnotations.alb\.ingress\.kubernetes\.io/ip-address-type'='dualstack' \
```

You will need to create a kubernetes secret for your TLS certificate following the detailed instructions below in this document. You will need to enable a nginx controller and include a static IP for it.

If you are using an ingress, use annotations for the platform you are deploying on. The ingressClass, storageClassName, and storageClassNameNFS may also be different depending on the platform, and depending on your requirements. Note the single quotes to wrap value names, and the backslash (\\) to escape periods (.) and commas (,) . global.ingressAnnotations are a default set of annotations that can be overridden or added to. They are ignored if global.ingressAnnotationsCustom values are supplied.

AWS (Amazon)

```console
--set global.ingressClass=alb \
--set global.storageClassName=gp2 \
--set global.storageClassNameNFS=nfs \
--set 'global.ingressAnnotations.alb\.ingress\.kubernetes\.io/certificate-arn'='<YOUR  arn:aws:acm CERTIFICATE>' \
```

Azure (Microsoft)

```console
--set global.storageClassName=default \
--set global.storageClassNameNFS=azurefile \
```

CFCR (OpenText)

```console
--set global.storageClassName=trident-nfs \
--set global.storageClassNameNFS=trident-nfs \
```

GCP (Google)

```console
--set global.storageClassName=standard \
--set global.storageClassNameNFS=nfs \
```

OpenShift (Red Hat)

```console
--set global.ingressClass=openshift-default \
--set global.ingressEnabled=false \
--set global.storageClassName="" \
--set global.storageClassNameNFS=nfs \
```

Deploy the helm chart. The database host may be the same, but each component needs a different database name and user. Values surrounded in <> must be supplied.

Below is a simple GCP deploy using database storage with no domain specified (uses static IP). otac and otiv are disabled. The 'helm upgrade -i' command is used since the install flag allows the command to work for both new helm deploys and upgrades.

```console
helm upgrade -i <RELEASE_NAME> otxecm \
--set global.imageSource=<DOCKER REGISTRY PATH> \
--set global.masterPassword='<PASSWORD>' \
--set global.otac.enabled=false \
--set global.otcsPublicUrl="" \
--set global.otdsPublicUrl="" \
--set global.otiv.enabled=false \
--set global.storageClassName=standard \
--set otcs.config.database.hostname=<DATABASE HOSTNAME> \
--set otcs.config.database.name=<OTCS DATABASE NAME> \
--set otcs.config.database.username=<OTCS DATABASE USER> \
--set otcs.config.documentStorage.type=database \
--set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
--set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
--set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
--set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
```

Below is a GCP deploy including otpd (OpenText PowerDocs), otac and otiv. If you are using otpd, you must copy a otpd license file into the otxecm/otpd subchart folder, and specify it with the otpd.otpdLicense value, like below.

```console
helm upgrade -i <RELEASE_NAME> otxecm \
--set global.imageSource=<DOCKER REGISTRY PATH> \
--set global.ingressDomainName=<DOMAIN NAME> \
--set global.ingressSSLSecret=<KUBERNETES SECRET NAME FOR TLS> \
--set global.masterPassword='<PASSWORD>' \
--set global.otacPublicUrl="https://<OTAC URL PATH>" \
--set global.otcsPublicUrl="https://<OTCS URL PATH>" \
--set global.otdsPublicUrl="https://<OTDS URL PATH>" \
--set global.otpd.enabled=true \
--set global.otpdPublicUrl="https://<OTPD URL PATH>" \
--set global.storageClassName=standard \
--set global.storageClassNameNFS=nfs \
--set otac.database.hostname=<DATABASE HOSTNAME> \
--set otac.database.name=<OTAC DATABASE NAME> \
--set otac.database.username=<OTAC DATABASE USER> \
--set otcs.config.database.hostname=<DATABASE HOSTNAME> \
--set otcs.config.database.name=<OTCS DATABASE NAME> \
--set otcs.config.database.username=<OTCS DATABASE USER> \
--set otcs.config.documentStorage.type=otac \
--set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
--set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
--set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
--set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
--set otpd.database.hostname=<DATABASE HOSTNAME> \
--set otpd.database.name=<OTPD DATABASE NAME> \
--set otpd.database.username=<OTPD DATABASE USER> \
--set otpd.otpdLicense=otpdlicense.lic
--set otpd.technicalUserPassword='<PASSWORD>' \
```

**NOTE:** In 23.4 the otcs-db, otac-db, and otpd-db subcharts were removed. The corresponding services must connect to an existing database. Also, otds.otdsws.otdsdb.automaticDatabaseCreation.enabled default value has been changed to false meaning the OTDS database will not be automatically created. For database details, please refer to the Database Servers section of the help.

## Introduction

This chart bootstraps a [Content Management](https://www.opentext.com/products-and-solutions/products/enterprise-content-management/extended-ecm-platform) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Install [Docker](https://docs.docker.com/get-started) (to push and pull Container images)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) CLI in your local environment
- Install [Helm](https://helm.sh/docs/using_helm/#installing-helm) toolset on local environment (use 3.02 or newer)
- Create Kubernetes cluster in your cloud infrastructure. Minimum of 3 nodes with 4 CPU and 15GB storage each is required for a non-production setup.
- A certificate for installations with Archive Server or Archive Core Connector must be created. Click [here](#otacotacc-certificate-secret) for details.
- **We have introduced the ability to set the timezone for the entire deployment. It is strongly recommended that you keep the entire deployment in the same time zone (regardless of whether it is completely containerized, split into multiple namespaces, a mix of containerized / managed or on-premise) as this could cause undesired side effects with processes going off at unexpected times, incorrect date/time stamping etc.** If you would like to change this, please ensure that you accurately set this value to a known supported value [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). Use the following helm value.**

```console
--set global.timeZone=Etc/UTC \
```

- A supported database must be available before Helm deployment

## Validating the Chart

> **Tip**: List all releases using `helm list`

To test and check the chart use similar helm values from [TLDR](#tldr) with the following helm flags.

```console
helm template otxecm \
--set <HELM VALUES>
```

```console
helm upgrade -i \
--set <HELM VALUES> \
--dry-run \
--debug
```

## Installing the Chart

You need to be in the folder that includes the `otxecm` chart folder. Use similar helm values from [TLDR](#tldr).

```console
helm install <RELEASE_NAME> otxecm \
--set <HELM VALUES> \
```

The command deploys OpenText Content Management on the Kubernetes cluster together with necessary components (Directory Services, Archive Center, Core Archive Connector, Intelligent Viewing and PowerDocs). The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Deploying with an existing kubernetes secret

The use of kubernetes secret file is intended for production deployments. Edit otxecm/example-secret.yaml and provide password values for any components you are using. For example, if you are not using otac (Archive Center) for storage, then you can ignore those passwords. Provided values must be base64 encoded, per kubernetes requirements. If you are encoding in Linux with the base64 command, make sure you do not include new line characters. For example:

```console
echo -n 'aBigLongStringToEncode' | base64 -w 0
```

Create the kubernetes secret with the following command:

```console
kubectl create -f otxecm/example-secret.yaml
```

Provide the secret name as a helm value when you install. By default, the secret name in example-secret.yaml is otxecm-secrets, so the value would look like below.

```console
--set global.existingSecret=otxecm-secrets \
```

You do not need these values when using an existing kubernetes secret.

```console
--set global.masterPassword='<PASSWORD>' \
--set otds.otdsws.cryptKey='<OTDS CRYPT KEY>' \
--set otpd.technicalUserPassword='<PASSWORD>' \
```

The command to deploy the helm chart is otherwise the same as [TLDR](#tldr).

> **Important:** When deploying using secrets, all keys specified in the example-secret.yaml must be set for the containers that you are using. The exception to this is optional components that you are not using. For example, if you are using an otxecm container in your deployment, but not otacc (Core Archive Connector) as storage, then you do not need the AC_CORE_PASSWORD key under the ##otcs section.

## Optionally deploying with the Master password

Intended for non-production environments, where you can set a unique password across all components. To set the Master password, use the following value.

```console
--set global.masterPassword='<PASSWORD>' \
```

A new secret 'otxecm-default-secrets' is created and used.

You can overwrite the password for a specific component based on the tables below:

### OTDS

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set otds.otdsws.adminPassword=\<password>                               | Define the password for the otadmin@otds.admin user for the OTDS        |
| --set otds.otdsws.otdsdb.password=\<password>                               | Define the password for the otds-db                                     |
| --set otds.otdsws.adminEmail=\<email>                                       | Define the name of the OTDS Admin user (otadmin@otds.admin by default)  |

### OTCS

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set otcs.passwords.adminUserPassword=\<password>                              | Define the Content Server Administration User Password                       |
| --set otcs.passwords.adminServerPassword=\<password>                              | Define the Content Server Administration Server Password                       |
| --set otcs.passwords.appMonitorPassword=\<password>                         | Define the password for the appmonitor user for the Content Server      |
| --set otcs.passwords.database.adminPassword=\<password>                     | Define the password for the admin user for the Content Server database  |
| --set otcs.passwords.database.password=\<password>                          | Define the password for the user that owns the Content Server database  |

### OTACC

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set otcs.passwords.otacc.corePassword=\<password>                         | Define the password for the  otacc user, if otacc is being used for storage|
| --set otacc.cloud.baPassword=\<password>                                    | Define the password for the Business Administrator in Core Archive         |
| --set otacc.connector.Password=\<password>                                  | Define the password for the internal  Core Archive Connector user          |

### OTAC

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set otac.database.adminPassword=\<password>                               | Define the password for the admin user for the Archive Center database     |
| --set otac.database.password=\<password>                                    | Define the password for the user that owns the Archive Center database     |
| --set otac.otds.password=\<password>                                        | Define the password for the administrator user for the OTDS                |

### OTIV

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set global.passwords.database.adminPassword=\<password>                   | Define the password for the database admin user used by the config, publication, publisher, and markup services  |
| --set global.masterPassword=\<password>                                     | Define the master password for all the otiv services                       |
| --set global.amqp.password=\<password>                                      | Define the password for the messaging user for otiv-amqp                   |

### OTPD

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| --set otpd.adminPassword=\<password>                                        | Define the password for the admin user for the PowerDocs                   |
| --set otpd.userPassword=\<password>                                         | Define the password for the PowerDocs user                 |
| --set otpd.monitorUserPassword=\<password>                                  | Define the password for the monitorUser User for the PowerDocs             |
| --set otpd.apiUserPassword=\<password>                                      | Define the password for the apiUser User for the PowerDocs                 |
| --set otpd.technicalUserPassword=\<password>                                | Define the password for the technicalUser for the PowerDocs. This is always required.  |
| --set otpd.database.adminPassword=\<password>                               | Define the password for the admin user for the PowerDocs database          |
| --set otpd.database.password=\<password>                                    | Define the password for the user that owns the PowerDocs database          |
| --set otpd.otcs.password=\<password>                                        | Define the password for the administrator user for the OTCS                |
| --set otpd.otds.password=\<password>                                        | Define the password for the administrator user for the OTDS                |

### Databases

| Command Line Parameter                                                 | Description                                                         |
|------------------------------------------------------------------------|---------------------------------------------------------------------|

## Sample Command Line Parameters

These are common command line parameters that can be used. Please view the specific chart `values.yaml` file for all available options. For example, look in otxecm/charts/otcs/values.yaml for all values to be used with the otcs chart.

| Command Line Parameter                                                 | Description                                                         | Example Values                            |
|------------------------------------------------------------------------|---------------------------------------------------------------------|-------------------------------------------|
| --set otcs.image.name=\<name>                                           | Define the name of the Content Management Docker image   | otxecm, otxecm-documentum-sap        |
| --set otcs.image.tag=\<version>                                         | Define the Docker image tag / version of the Content Management image   | 22.2.0                                    |
| --set otac.image.tag=\<version>                                         | Define the Docker image / tag version of the Archive Center image   | 22.4.0                                    |
| --set otds.otdsws.image.tag=\<version>                                         | Define the Docker image / tag version of the Directory Services image             | 22.3.0                                    |
| --set otds.otdsws.otdsdb.url=\<url>                                         | Define the url to connect to the DB for the Directory Services             | jdbc:postgresql://\<db-hostname>:5432/otdsdb                                    |
| --set otds.otdsws.otdsdb.username=\<name>                                         | Define the username for the otds-db             | postgres                                    |
| --set global.otac.enabled=\<boolean>                                           | Define if Archive Center gets deployed as container or not  (enabled by default)        | false, true                               |
| --set global.otiv.enabled=\<boolean>                                           | Define if Intelligent Viewing services are deployed (enabled by default)         | false, true                               |
| --set otcs.config.documentStorage.type=\<store>                                        | Define where the content gets stored (needed if otac.enabled=false) | database, otac, otacc, efs      |
| --set otcs.config.database.hostname=<host/IP>                                          | Define the hostname of the DB server (if it is outside the cluster) | IP address or fully qualified domain name |
| --set otcs.config.database.adminUsername=\<database admin>                                     | Define the admin username of the DB server  | postgres |
| --set otcs.config.port=\<port number>                                    | Defines the external port for the otcs kubernetes service. Cannot be changed after initial deployment. | 45312 |
| --set otcs.config.enableMultiProcessMode=\<boolean>                                    | Defines if MultiProcessMode should be enabled or disabled. | false, true |
| --set otcs.config.ual.enabled=\<boolean>                                    | Defines if ual should be enabled or disabled. | false, true |
| --set otcs.config.ual.certFilename=\<string>                                    | Defines the pem certificate file name. | string |
| --set otds.port=\<port number>                                    | Defines the external port for the otds kubernetes service. Cannot be changed after initial deployment. | 16254 |
| --set otds.otcsPort=\<port number>                                    | Defines the external port for the otcs kubernetes service. Cannot be changed after initial deployment. This must match the otcs port defined for the otds helm chart. | 45312 |
| --set global.otpd.enabled=\<boolean>                                           | Define if PowerDocs container is deployed          | false, true  |
| --set otpd.technicalUserPassword=\<password>                            | Define the password for the technicalUser for the PowerDocs. This is always required | password
| --set otcs.contentServerFrontend.replicas=\<num>                        | Number of Content Server Frontend instances to start. If set to 0 the admin pod will receive the traffic from the otcs-frontend service, when running a helm install or upgrade command              | 0-n                                       |
| --set otcs.contentServerFrontend.resources.requests.cpu=\<num>          | Number of CPU to be requested for Content Server Frontend           | 1                                         |
| --set otcs.contentServerFrontend.resources.requests.memory=\<gigabytes> | Compute memory to be requested for Content Server frontend          | 1.5Gi                                     |
| --set otcs.contentServerFrontend.limits.requests.cpu=\<num>             | CPU limit for Content Server Frontend                               | 2                                         |
| --set otcs.contentServerFrontend.limits.requests.memory=\<gigabytes>    | Compute memory limit for Content Server frontend                    | 4Gi                                       |
| --set otcs.contentServerAdmin.resources.requests.cpu=\<num>             | Number of CPU to be requested for Content Server Frontend           | 1                                         |
| --set otcs.contentServerAdmin.resources.requests.memory=\<gigabytes>    | Compute memory to be requested for Content Server frontend          | 1.5Gi                                     |
| --set otcs.contentServerAdmin.limits.requests.cpu=\<num>                | CPU limit for Content Server Frontend                               | 2                                         |
| --set otcs.contentServerAdmin.limits.requests.memory=\<gigabytes>       | Compute memory limit for Content Server frontend                    | 4Gi                                       |
| --set otcs.containerLogLevel=\<string>                       | Define how much information is logged by the container setup. 'DEBUG' will also enable Content Server logs during and after the deployment. | DEBUG, INFO, WARNING, ERROR, CRITICAL                                       |
| --set otcs.sharedAddressSpaceNat.enabled=\<boolean>                             | Define whether to allow Tomcat internalProxies to accept 100.64.0.0/10 IP range(Carrier-grade NAT) | false, true                                       |
| --set otpd.emailServerSettings.enabled=\<boolean>                       | Define if email server settings should be updated during deployment| false, true                               |
| --set otpd.emailServerSettings.server=\<string>                         | A valid email server                                               | smtp.office365.com                        |
| --set otpd.emailServerSettings.port=\<port number>                      | A valid email server port                                          | 587                                       |
| --set otpd.emailServerSettings.user=\<string>                           | A valid email server user                                          | username                                  |
| --set otpd.emailServerSettings.password=\<password>                     | A valid email server password                                      | password                                  |

### Install without Archive Center

To install the chart without the OpenText Archive Center container but use database content store use these parameters:

```console
--set global.otac.enabled=false \
--set otcs.config.documentStorage.type=database \
```

To use external filesystem as content store (in fact these are volumes on the Kubernetes platform) you can do so by setting the `otcs.config.documentStorage.type` variable to `efs`. You may also need to adjust the `otcs.config.documentStorage.efsStorageClassName` variable (`gcp-nfs` is just an example from Google Cloud Platform).

```console
--set global.otac.enabled=false \
--set otcs.config.documentStorage.type=efs \
--set otcs.config.documentStorage.efsStorageClassName=gcp-nfs \
```

### Install with existing Archive Center outside the Cluster

You may already have a central instance of Archive Center to use, or when using OTK you can use Core Archive (Archive Server cloud storage). To install the chart without the OpenText Archive Center container use these helm values:

```console
--set global.otac.enabled=false \
--set otcs.config.otac.url=<URL>
```

To install the chart without the OpenText Archive Center container and use otacc (OpenText hosted platform only):

1. Install the Core Archive connector helm chart. Make sure to edit the values.yaml with your archive connection details.

```console
helm install \
otxecm otxecm \
--set global.storageClassName=trident-nfs \
--set global.storageClassNameNFS=trident-nfs \

--set otcs.config.documentStorage.type=otacc \
--set otcs.config.otacc.archiveName=<desired unique archive name> \
--set otcs.config.otacc.collectionName=<desired unique collection name> \
--set otcs.passwords.otacc.corePassword=<core archive cloud password> \
--set otcs.config.otacc.coreUser=<core archive cloud username> \
--set global.otac.enabled=false \
--set global.otacc.enabled=true  \
--set otacc.cloud.baUser=<core archive cloud username> \
--set otacc.cloud.baPassword=<core archive cloud password> \
--set otacc.connector.password=<core archive connector password> \
--set otacc.cloud.url=https://otacc-cloud.example.com \
--set otacc.connector.reregister=true
--set global.imageSource=<DOCKER REGISTRY PATH> \
--set global.ingressDomainName=<DOMAIN NAME> \
--set global.ingressSSLSecret=<KUBERNETES SECRET NAME FOR TLS> \
--set global.masterPassword='<PASSWORD>' \
--set global.otcsPublicUrl="https://<OTCS URL PATH>" \
--set global.otdsPublicUrl="https://<OTDS URL PATH>" \
--set otcs.config.database.hostname=<DATABASE HOSTNAME> \
--set otcs.config.database.name=<OTCS DATABASE NAME> \
--set otcs.config.database.username=<OTCS DATABASE USER> \
--set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
--set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
--set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
--set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
```

Replace fields marked in angle brackets `<>` with values for your deployment.

### Install with existing OpenText Directory Services outside the Cluster

To install the chart without the OpenText Directory Services container (because you have a central instance of Directory Services already deployed):

```console
--set global.otds.enabled=false \
--set global.otdsPublicUrl="https://<OTDS URL PATH>" \
--set otcs.config.otds.serverUrl="https://your-otds-url.com" \
--set otcs.config.otds.signInUrl="https://your-otds-sign-in.com" \
```

Both serverUrl and signInUrl are defaulted to the global.otdsPublicUrl when using an external OTDS.

### Install PostgreSQL database as container

For testing purposes, you may deploy a PostgreSQL database as a container for Content Server and/or Archive Center. It is not recommended for production use. Prior to 23.4, this ability was part of the Content Management helm charts.

```console
helm install otxecm-db oci://registry-1.docker.io/bitnamicharts/postgresql \
--set auth.postgresPassword=<password> \
--set image.registry=docker.io \
--set image.repository=postgres \
--set image.tag=13 \
--set fullnameOverride=otxecm-db
```

### Install with MSSQL Database

There are a few parameters that need to be set to deploy with an MSSQL database

Set the database type to mssql:\
`--set otcs.config.database.type=mssql`

Set the hostname and port to the values for the MSSQL database:\
`--set otcs.config.database.hostname=example.com`\
`--set otcs.config.database.port=1433`

If mssql server does not require a port use:\
`--set otcs.config.database.port=null`\
`--set global.database.port=""`

Set the path for the database file and the log file, as well as their sizes:\
`--set otcs.config.database.mssql.dbDataFileSpec=/var/tmp/data`\
`--set otcs.config.database.mssql.dbLogFileSpec=/var/tmp/log`


Finally set MSSQl's master database and admin username:\
`--set otcs.config.database.adminUsername=SA`

***Note: Default mssql values are shown below. These parameters should be added to the install command if values other than the defaults are required***\
`--set otcs.config.database.mssql.master_database_name=master`\
`--set otcs.config.database.mssql.dbDataFileSize=500`\
`--set otcs.config.database.mssql.dbLogFileSize=500`


### Install with Oracle Database

#### Extending the base image

To use an Oracle database, the base Content Management docker image needs to be extended. As an example, Dockerfile_extend_oracle is provided.

To extend the image, go to the folder where the Dockerfile_extend_oracle is located and run:\
`docker build -f Dockerfile_extend_oracle -t DESIRED_IMAGE_NAME:TAG --build-arg base_image=OTXECM_IMAGE:TAG .`

#### Deploying with an Oracle Database

There are a few parameters that need to be set to deploy with an Oracle database

Set the database type to oracle:\
`--set otcs.config.database.type=oracle`

Set the hostname and port to the values for the Oracle database:\
`--set otcs.config.database.hostname=example.com`\
`--set otcs.config.database.port=1521`

When using Oracle, the service name must be set to the service name of the pluggable database to be used:\
`--set otcs.config.database.oracle.serviceName=CS`

When setting the admin user do not use the sys user. Instead, the system user must be used:\
`--set otcs.config.database.adminUsername=system`

The path for the database file and its size must be set. Its path must exist on the system where the database is running, but the .dbf file cannot:\
`--set otcs.config.database.oracle.dbDataFileSpec=/opt/oracle/cs.dbf`\
`--set otcs.config.database.oracle.dbDataFileSize=100`

#### Using a Tnsnames file

If using a tnsnames.ora file to connect to the database, the parameter must be enabled and the file must be added to the otcs subchart folder:\
`--set otcs.config.database.oracle.loadTnsnames.enabled=true`\
`--set otcs.config.database.oracle.loadTnsnames.filename=tnsnames.ora`

The connection alias of the connection to be used in the tnsnames.ora file must also be set:\
`--set otcs.config.database.oracle.tnsnamesConnectionAlias=ORCL`
For example, in the provided tnsnames.ora file the tnsnamesConnectionAlias would be ORCL.

Note: the hostname, port, and service name will not need to be set in your deployment when using a tnsnames.ora file.

#### Deploying with Oracle Data Guard
Both primary and secondary instances must be setup before the deployment.\
The configured instances need to be passed through tnsnames.ora file\
For more details refer oracle dataguard documentation.

#### Deploying custom modules using Init Containers

To install custom modules, it is necessary to build a Docker Init container.

Please, refer to the Content Management Cloud Deployment Guide published at OpenText My Support for details on how to build a Docker Init container for your custom module.

There are a few parameters that need to be set before deployment<br>
Set extensions enabled to true <br>
`--set otcs.config.extensions.enabled=true`<br>

If the containers inside kubernetes cluster don't have access to the internet then set includeManifestInitContainer value to true and provide init container details of manifest file as shown below<br>
`--set otcs.config.extensions.includeManifestInitContainer=true`<br>

> **Note**: Steps for building manifest file init container are provided in the [Cloud Deployment Guide](https://webapp.opentext.com/piroot/sulccd/v220300/sulccd-igd/en/html/_manual.htm) on My Support

Repeat the below 4 lines for each init container image, by incrementing index of initContainers

```console
--set otcs.initContainers[0].name='DESIRED_NAME_FOR_INIT_CONTAINER' \
--set otcs.initContainers[0].image.source='IMAGE_SOURCE' \
--set otcs.initContainers[0].image.name='IMAGE_NAME' \
--set otcs.initContainers[0].image.tag='IMAGE_TAG'
```

#### Add custom labels to the otcs pvc's
To add labels for otcs csPersist pvc, use the below helm parameter,
```console
--set otcs.pvc.csPersist.labels[0]="<sample-label-key>: <sample-label-value>" \
```
To add labels for otcs cs-logs pvc, use the below helm parameter,
```console
--set otcs.pvc.logs.labels[0]="<sample-label-key>: <sample-label-value>" \
```
To add the labels for otcs sftp-volume, use the below helm parameter,
```console
--set otcs.pvc.sftpVolume.labels[0]="<sample-label-key>: <sample-label-value>" \
```

#### Add custom annotations to the otcs services
To add annotations for otcs admin service, use the below helm parameter,
```console
--set otcs.service.admin.annotations[0]="<sample-annotation-key>: <sample-annotation-value>" \
```
To add annotations for otcs frontend service, use the below helm parameter,
```console
--set otcs.service.frontend.annotations[0]="<sample-annotation-key>: <sample-annotation-value>"  \
```
To add annotations for otcs backendSearch service, use the below helm parameter,
```console
--set otcs.service.backendSearch.annotations[0]="<sample-annotation-key>: <sample-annotation-value>"  \
```

#### Add custom annotations to the otpd service
To add annotations for otpd service, use the below helm parameter,
```console
--set otpd.service.annotations[0]="<sample-annotation-key>: <sample-annotation-value>" \
```

#### Add custom annotations to the otac service
To add annotations for otac service, use the below helm parameter,
```console
--set otac.service.annotations[0]="<sample-annotation-key>: <sample-annotation-value>" \
```

#### Add Custom labels to the otcs pods
To add labels for otcs pods, use the below helm parameter,
```console
--set otcs.podLabels.app\\.kubernetes\\.io/app_name=<app_name> \
--set otcs.podLabels.app\\.kubernetes\\.io/app_version='<app_version>' \
```
#### Add Custom annotations to the otcs pods
To add annotations for otcs pods, use the below helm parameter,
```console
--set otcs.podAnnotations.backup\\.velero\\.io/backup-volumes-excludes=otcs-admin-index-shared \
```
#### Add custom storage volumes to the otcs pods
To add custom storage volumes to the otcs pods use the below helm parameters,
```console
--set otcs.additionalVolumes[0].name=azure-mount \
--set otcs.additionalVolumes[0].mountPath='/opt/opentext/azureMount' \
--set otcs.additionalVolumes[0].volumeOptions.azureFile.secretName=azure-secret \
--set otcs.additionalVolumes[0].volumeOptions.azureFile.shareName=azure-shared \
--set otcs.additionalVolumes[0].mountOptions.subPath=azureMount \
--set otcs.additionalVolumes[1].name=pvc \
--set otcs.additionalVolumes[1].mountPath='/opt/opentext/pvc' \
--set otcs.additionalVolumes[1].volumeOptions.persistentVolumeClaim.claimName=pvc \
```
**Note** Each volume must have a name and a mountPath.

#### Set custom pvc storage class for otcs log pvcs
To set a custom otcs pvc log storage class use the below helm parameter. 
```console
--set otcs.csPersist.logStorageClassName=<storage-class-name> \
```
If the pvc storage class update is being performed on upgrade to the same otxecm version or a patch upgrade the below parameter must be added.
```console
--set preUpgradeJob.otxecm.forceRestart=true \
```
**Note** Changing the pvc storage class will cause the old log pvc to be deleted along with the previous logs

#### Create a synchronizedPartition in otds
To create a synchronizedPartition in otds the following values need to be set.
```console
--set global.otxecmctrl.enabled=true \
--set otcs.config.enableSynchronizedPartition=true \
--set otcs.passwords.synchronizedPartition.ldapBindPassword=password \
```
We need to pass the payload file.
```
Create a sample customvalues.yaml as mentioned below
otcs:
  otxecmctrl:
    customPayload:
      payloadConfig:
        payloadSections:
        - enabled: true
          name: synchronizedPartitions
        synchronizedPartitions:
```
#### Deploying Transport Packages
To deploy transport packages "deployTransportPackage" parameter must be set to true (it is false by default).
`--set otcs.config.deployTransportPackage=true`
Next to that we need to provide the list of package url's that need to be deployed into CS. Make sure that the url's accessible(URL's need to be public) if not packages will not deploy.
```console
--set otcs.config.transportPackagesUrlList[0]='<url>' \
--set otcs.config.transportPackagesUrlList[1]='<url>' \
--set otcs.config.transportPackagesUrlList[2]='<url>' \
```
you can add N number of URL's list by increasing the index count.
In case of any dependencies the packages will not deploy into CS, we must deploy it manually by resolving the dependencies.
If the URL's are duplicated the packages are deployed only once.

#### enabling IPA module
To create a PVC for IPA, please set the below parameters
`--set otcs.config.contentProtection.enabled=true `
`--set otcs.config.contentProtection.storage=1Gi `
`--set otcs.config.contentProtection.path=<path of the volume> `
**Note** Manual steps, 6.6.4 in the Content Management Cloud Deployment Guide, are required to fully configure IPA.

#### enabling storageProviderCache
To enable storageProviderCache and configure Video Conversion Settings please set the below parameters
```console
--set otcs.config.storageProviderCache.enabled=true \
--set otcs.config.storageProviderCache.dmtshost=<dmts-host> \
--set otcs.config.storageProviderCache.storage=<storage_size> \
--set otcs.config.storageProviderCache.storageClassName=<RWX_StorageClassName> \
```
**Note** When storageProviderCache is enabled, the IPA module must be enabled as well (see section above)

#### enabling awsStorageProvider
To enable awsStorageProvider please set the below parameters
```console
--set otcs.config.documentStorage.type=aws \
--set otcs.config.awsStorageProvider.region=<region where your bucket is created> \
--set otcs.config.awsStorageProvider.bucketName=<your S3 Bucket name> \
--set otcs.passwords.awsSecretKey=<aws secret key> \
--set otcs.passwords.awsAccessId=<aws access id> \
```

#### enabling gcpStorageProvider
To enable gcpStorageProvider please set the below parameters
```console
--set otcs.config.documentStorage.type=gcp \
--set otcs.config.gcpStorageProvider.serviceAccountJson=<service account json file of your GCP storage provider> \
--set otcs.config.gcpStorageProvider.bucketName=<your GCP Bucket name> \
```

#### Install CSAPPS
To install CSAPPS, it is necessary to build a Docker Init container.<br>
Please, refer to the Content Management Cloud Deployment Guide published at OpenText My Support for details on how to build a Docker Init container for CSAPPS.<br>

To install only default apps that comes from content server, please set defaultAppsInstall as true (it is false by default)<br>
`--set otcs.config.defaultAppsInstall=true`,<br>

To install default apps that comes from content server and apps you built on your own, set defaultAppsInstall as true and
add the below 4 lines for init container image<br>

```console
--set otcs.config.defaultAppsInstall=true \
--set otcs.initContainers[0].name='DESIRED_NAME_FOR_INIT_CONTAINER' \
--set otcs.initContainers[0].image.source='IMAGE_SOURCE' \
--set otcs.initContainers[0].image.name='IMAGE_NAME' \
--set otcs.initContainers[0].image.tag='IMAGE_TAG'
```

To install the apps you built on your own, add the below 4 lines for init container image<br>

```console
--set otcs.initContainers[0].name='DESIRED_NAME_FOR_INIT_CONTAINER' \
--set otcs.initContainers[0].image.source='IMAGE_SOURCE' \
--set otcs.initContainers[0].image.name='IMAGE_NAME' \
--set otcs.initContainers[0].image.tag='IMAGE_TAG'
```

#### Upgrade CSAPPS
To upgrade CSAPPS, it is necessary to build a Docker Init container.<br>
Please, refer to the Content Management Cloud Deployment Guide published at OpenText My Support for details on how to build a Docker Init container for CSAPPS.<br>

To upgrade only default apps that comes from content server, please set defaultAppsUpgrade as true (it is false by default)<br>
`--set otcs.config.defaultAppsUpgrade=true`,<br>

To upgrade default apps that comes from content server and apps you built on your own, set defaultAppsUpgrade as true and
add the below 4 lines for init container image<br>

```console
--set otcs.config.defaultAppsUpgrade=true \
--set otcs.initContainers[0].name='DESIRED_NAME_FOR_INIT_CONTAINER' \
--set otcs.initContainers[0].image.source='IMAGE_SOURCE' \
--set otcs.initContainers[0].image.name='IMAGE_NAME' \
--set otcs.initContainers[0].image.tag='IMAGE_TAG'
```

To upgrade the apps you built on your own, add the below 4 lines for init container image<br>

```console
--set otcs.initContainers[0].name='DESIRED_NAME_FOR_INIT_CONTAINER' \
--set otcs.initContainers[0].image.source='IMAGE_SOURCE' \
--set otcs.initContainers[0].image.name='IMAGE_NAME' \
--set otcs.initContainers[0].image.tag='IMAGE_TAG'
```

####  To enable Secretlink for Content Server
To use the vault secret we can enable Secretlink.
The values can be set through the global level or by otcs subcharts. Service account name should match with the service account name given for vault configuration.

```console
--set otcs.serviceAccountName='SERVICE_ACCOUNT_NAME' \
--set otcs.secretlink.enabled=true \
--set otcs.secretlink.vault.address='VAULT_ADDRESS' \
--set otcs.secretlink.vault.mountpoint='MOUNT_PATH' \
--set otcs.secretlink.vault.namespace='VAULT_NAMESPACE' \
--set otcs.secretlink.vault.path='VAULT_SECRET_PATH' \
--set otcs.secretlink.vault.authpath='VAULT_AUTH_PATH' \
--set otcs.secretlink.vault.role='VAULT_ROLE' \
```
```console
--set global.serviceAccountName='SERVICE_ACCOUNT_NAME' \
--set global.secretlink.enabled=true \
--set global.secretlink.vault.address='VAULT_ADDRESS' \
--set global.secretlink.vault.mountpoint='MOUNT_PATH' \
--set global.secretlink.vault.namespace='VAULT_NAMESPACE' \
--set global.secretlink.vault.path='VAULT_SECRET_PATH' \
--set global.secretlink.vault.authpath='VAULT_AUTH_PATH' \
--set global.secretlink.vault.role='VAULT_ROLE' \
```

####  To configure Syndication feature in Content Server

To configure Syndication feature in primary Content Server, set below parameters

```console
--set otcs.config.syndication.enabled='true' \(parameter must be set to true, it is false by default)
--set otcs.config.syndication.isPrimary=true \("isPrimary" parameter must be set to true, it is false by default)
--set otcs.config.syndication.siteid='' \ (set it 0 when configuring primary, set it to other than 0 when configuring remote)
--set otcs.config.syndication.sitename='<sitename>' \
```

To configure Syndication feature in remote Content Server set below parameters

```console
--set otcs.config.syndication.enabled='true' \(parameter must be set to true, it is false by default)
--set otcs.config.syndication.isPrimary=false \(set to false for remote)
--set otcs.config.syndication.sitename='<sitename that been passed in manage syndication sites in primary setup>' \
--set otcs.config.syndication.siteid=<siteid must not be zero> \
```

### Enabling object importer in otxecm
Documents can be ingested into Content Server by using the Object Import feature
To enable object importer in content server please enable below helm paratmeter
```console
--set otcs.objectimporter.enabled=true
```
### Applying default adminsettings
To apply adminSettings only in the fresh, place the xml files in the otcs/adminSettings/initial folder. To apply adminSettings in both fresh and upgrade, place the xml files in the otcs/adminSettings/recurrent folder. Please set the below parameter to true to apply the admin settings
```console
-- set otcs.loadAdminSettings.enabled=true
```
### Applying custom path adminsettings
To apply admin settings only in fresh using custom path,create any folder in the otcs folder like otcs/<custompath>/initial.
To apply admin settings in both fresh and upgrade using custom path, create any folder in the otcs folder like otcs/<custompath>/recurrent
Please set the below parameter to the location of adminsettings folder
```console
--set otcs.adminSettingsFolder='<custom path>'(Ex: test/adminSettings) (path should be after otcs subchart folder and before initial/recurrent )
-- set otcs.loadAdminSettings.enabled=true
```

### Using existing helm assets

#### <b> Admin settings configmaps </b>
To apply externalized admin settings first create the configmaps for the recurrent or initial admin settings.
```console
kubectl create configmap <initial/recurrent-configmap-name> --from-file=<path to adminsettings xml>
```
Then when deploying add the parameter that corresponds with your configmap
```console
--set otcs.loadAdminSettings.enabled=true \
--set loadAdminSettings.initialConfigmap=<initial-configmap-name>
```
or
```console
--set otcs.loadAdminSettings.enabled=true \
--set loadAdminSettings.recurrentConfigmap=<recurrent-configmap-name>
```

#### <b>OTAC/OTACC certificate secret</b>
To use an existing secret for the otac or otacc certificate create a secret as such
```console
kc create secret generic <certificate-secret-name> --from-file=<PATH-TO-CERTIFICATE>
```
Then add the corresponding set command to the helm deploy
```console
--set otcs.config.otac.certSecret=<certificate-secret-name> \
--set otcs.config.otac.certFilename=<certificate-filename>
```
or
```console
--set otcs.config.otacc.certSecret=<certificate-secret-name> \
--set otcs.config.otacc.certFilename=<certificate-filename>
```

#### <b>OTXECM license secrets</b>
To use an existing secret for the otxecm licenses create a secret as such
```console
kc create secret generic <license-secret-name> --from-file=<PATH-TO-LICENSE>
```
Then add the corresponding set command to the helm deploy
```console
--set global.existingLicenseSecret=<license-secret-name> \
--set otcs.loadLicense.enabled=true \
--set otcs.loadLicense.filename=<otcs-license-filename>
```

### Enabling Fluentbit log outputs
Content Server connect, dcs, search, security, system monitoring, thread, or timings logs can be outputed to fluentbit

To enable the fluentbit container, you need to add the following set command

```console
--set otcs.fluentbit.enabled=true
```

The command to enable system monitoring logs is:
```console
--set otcs.fluentbit.logsToMonitor[0]="sysmon" \
--set otcs.config.enableSysmonLogs=true
```
The command to enable security logs is:
```console
--set otcs.fluentbit.logsToMonitor[0]="security" \
--set otcs.config.enableSecurityLogs=true
```
The command to enable connect, dcs, search, thread, and timings logs is:
```console
--set otcs.fluentbit.logsToMonitor[0]=connect \
--set otcs.fluentbit.logsToMonitor[1]=dcs \
--set otcs.fluentbit.logsToMonitor[2]=search \
--set otcs.fluentbit.logsToMonitor[3]=thread \
--set otcs.fluentbit.logsToMonitor[4]=timings
```
The command to enable customOutput to export logs to SIEM (Security Information and Event Management) application is:
```console
--set otcs.fluentbit.customOutput.enabled=true \
--set otcs.fluentbit.customOutput.customOutputFilePath=<custom_output_filepath> \
```
To enable HTTP you need to provide the following command.
```console
--set otcs.fluentbit.proxy.enabled=true \
--set otcs.fluentbit.proxy.host=<proxy_host> \
--set otcs.fluentbit.proxy.port=<proxy_port> \
```
To authenticate with proxy set the below commands.
```console
--set otcs.fluentbit.proxy.enableauthentication=true \
--set otcs.fluentbit.proxy.username=<username> \
--set otcs.fluentbit.proxy.password=<password> \
```

>**Note**: logsToMonitor is an array and will need to be incremented if both security and system monitoring logs are enabled

When the fluentbit container is enabled, it will be running in the same pod as the otcs pods. To view the fluentbit output you need to run the following command:
```console
kubectl logs [-f] <otcs-pod-name> -c fluentbit-container
```
Alternatively, to view the log file of the otcs container

```console
kubectl logs [-f] <otcs-pod-name> -c otcs-<admin,frontend,backend-search>-container
```

## Upgrading the Chart

Upgrade deployment with Helm:

```console
helm list
helm upgrade <RELEASE_NAME> otxecm
```

Replace `<RELEASE_NAME>` with your Helm chart release name (shown by `helm list`).

Note that if you're upgrading from 21.3 or earlier and the Intelligent Viewing chart has also been installed, first delete the Intelligent Viewing chart (e.g., helm delete otiv) prior to upgrading to the 21.4 since the otiv chart has been added as an otxecm subchart.

## Scaling the Deployment

Scaling can be done with either helm values or the kubectl scale command. Changes with helm will be persisted the next time you run a helm upgrade command. Changes done with kubectl scale will be lost the next time you run a helm upgrade command, since helm does not recognize those changes.

The Content Server frontend deployment can be scaled to cover different load levels. By default one replica is started for the Kubernetes stateful set `otcs-frontend`. To scale it to 2, use your original 'helm install' command with this additional line:

```console
helm upgrade <RELEASE_NAME> otxecm \
--set otcs.contentServerFrontend.replicas=2
```

Scaling with kubectl is also supported:

```console
kubectl scale sts otcs-frontend --replicas=2
```

Content Server admin (search) instances can be scaled up, but not down. This is a limitation of Content Server. Similar to frontends, use your original 'helm install' command with this additional line:

```console
helm upgrade <RELEASE_NAME> otxecm \
--set otcs.contentServerBackendSearch.replicas=2
```

Scaling with kubectl is also supported:

```console
kubectl scale sts otcs-backendsearch --replicas=2
```

## Uninstalling the Chart

To check the name of existing charts:

```console
helm ls
```

To completely uninstall/delete the `my-release` deployment including all persisted data:

```console
helm delete my-release
kubectl delete pvc --all
```
To delete an existing otxecm-default-secrets use the following command

```console
kubectl delete secret otxecm-default-secrets
```
If OTAC was deployed remove configMap and job related to otac upgrade

```console
kubectl delete configmap otac-pre-upgrade-configmap

kubectl delete jobs otac-pre-upgrade-job
```

If OTIV was deployed remove all secrets and service accounts related to otiv

```console
kubectl delete sa otiv-job-sa otiv-pvc-sa

kubectl delete secret otiv-cs-secrets otiv-highlight-secrets otiv-job-sa-token otiv-publication-secrets otiv-publisher-secrets otiv-pvc-sa-token otiv-resource-secret
```

> **Important**: `kubectl delete pvc --all` will delete all the persistent data of your deployment (including database storage if deployed as a container). Do this only if you want to start from scratch!

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

See [TLDR](#tldr) examples for minimal helm values that are required.

For more advanced settings you can also review the `values.yaml` file in the Helm chart directory to adjust parameters for Content Management (Content Server) and its components (e.g., Archive Center, Directory Services, etc). The better alternative may be to pass changed values with the help of the `--set` option in the `helm install` command (and not modify the `values.yaml` directly).

Some examples:

```console
--set otcs.image.name=otxecm \

--set otcs.image.name=otxecm-sap-o365-sfdc \

--set otcs.contentServerFrontend.replicas=2 \
```

### Example Installation and Configuration for Google Cloud Platform

This example creates a cluster named `xecm-cluster` and uses SSL (HTTPS). You need to create the `fullchain.pem` certificate file and the private key file `privkey.pem` before (e.g., with certbot and Let's encrypt). Also you need to create a container registry in GCP and push the Content Management Docker image and its components ( e.g., Archive Center, Directory Services, Intelligent Viewing).

1. Login to GCP and set GCP Project and Compute/Zone

    ```console
    gcloud auth login --no-launch-browser
    gcloud config set project <YOUR PROJECT ID>
    gcloud config set compute/zone <YOUR COMPUTE ZONE>
    ```

1. Create Cluster

    ```console
    gcloud container clusters create xecm-cluster \
    --machine-type n1-standard-4 \
    --num-nodes 3 \
    --cluster-version <set-a-supported-version> \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias
    ```

1. Configure `kubectl` for the created cluster

    ```console
    gcloud container clusters get-credentials xecm-cluster --zone <YOUR COMPUTE ZONE> --project <YOUR PROJECT ID>
    ```

1. Create a static IP address in GCP

    ```console
    gcloud compute addresses create xecm-ip --region <YOUR COMPUTE ZONE>
    ```

1. Create DNS Entries

    Now we register a DNS zone in GCP and create three records for Content Management, Archive Server and Directory Services that will all point to the static IP adress you have created in GCP in the step before (if you deploy without Archive Center you don't need a DNS record for it).

    Replace `xecm-cloud.com` with your registered Internet domain (DNS name). Also replace the Internet addresses below with the static IP you created before.

    ```console
    gcloud dns managed-zones create xecm-cloud \
    --dns-name="xecm-cloud.com" \
    --description="DNS Zone for Content Management Deployment" \
    --visibility=public

    gcloud dns record-sets transaction start --zone="xecm-cloud"

    gcloud dns record-sets transaction add 10.2.3.4 \
    --name="otac.xecm-cloud.com" \
    --ttl="5" \
    --type="A" \
    --zone="xecm-cloud"
    gcloud dns record-sets transaction add 10.2.3.4 \
    --name="otcs.xecm-cloud.com" \
    --ttl="5" \
    --type="A" \
    --zone="xecm-cloud"
    gcloud dns record-sets transaction add 10.2.3.4 \
    --name="otds.xecm-cloud.com" \
    --ttl="5" \
    --type="A" \
    --zone="xecm-cloud"

    gcloud dns record-sets transaction execute --zone="xecm-cloud"
    ```

1. Prepare Helm Chart Deployment

    ```console
    kubectl create secret tls xecm-secret --cert fullchain.pem --key privkey.pem
    ```

1. Deploy Ingress Controller

    You need to replace the IP address with the one you created before. The `proxy-body-size` parameter controls the maximum allowable request size. You may need to increase it to upload larger files.

    ```console
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm install otxecm ingress-nginx/ingress-nginx \
    --set rbac.create=true \
    --set controller.service.loadBalancerIP=<PUBLIC FACING IP> \
    --set controller.config.proxy-body-size=1024m
    ```

1. Deploy Helm Chart

    ```console
    helm upgrade -i <RELEASE_NAME> otxecm \
    --set global.imageSource=<DOCKER REGISTRY PATH> \
    --set global.ingressDomainName=<DOMAIN NAME> \
    --set global.ingressSSLSecret=xecm-secret \
    --set global.masterPassword='<PASSWORD>' \
    --set global.otacPublicUrl="https://<OTAC URL PATH>" \
    --set global.otcsPublicUrl="https://<OTCS URL PATH>" \
    --set global.otdsPublicUrl="https://<OTDS URL PATH>" \
    --set global.storageClassName=standard \
    --set global.storageClassNameNFS=nfs \
    --set otac.database.hostname=<DATABASE HOSTNAME> \
    --set otac.database.name=<OTAC DATABASE NAME> \
    --set otac.database.username=<OTAC DATABASE USER> \
    --set otcs.config.database.hostname=<DATABASE HOSTNAME> \
    --set otcs.config.database.name=<OTCS DATABASE NAME> \
    --set otcs.config.database.username=<OTCS DATABASE USER> \
    --set otcs.config.documentStorage.type=otac \
    --set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
    --set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
    --set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
    --set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
    ```

Access Directory Services and Content Server frontends with the URLs provided by the global.otcsPublicUrl and global.otdsPublicUrl.

To shutdown the deployment and delete the cluster do the following (replace the `<RELEASE_NAME>` with the release names `helm list` returns):

```console
helm list
helm delete <RELEASE_NAME>
kubectl delete pvc --all
gcloud container clusters delete xecm-cluster --zone <YOUR COMPUTE ZONE>
gcloud compute addresses delete xecm-ip --region <YOUR COMPUTE ZONE>
```

> **Important**: `kubectl delete pvc --all` will delete all the persistent data of your deployment (including database storage). Do this only if you want to start from scratch!

### Example Installation and Configuration for Amazon AWS

This example creates a cluster named <AWS_CLUSTER_NAME> and uses TLS (SSL). You need to create the TLS certificate on the AWS web portal using the `Certificate Manager` service. You need to create a docker container registry either on AWS or elsewhere that is accessible to AWS. Make sure the docker images you are using are pushed and available.

1. Create Cluster

    ```console
    eksctl create cluster \
    --name <AWS_CLUSTER_NAME> \
    --version <set-a-supported-version> \
    --region <YOUR COMPUTE ZONE> \
    --nodegroup-name <AWS_CLUSTER_NAME>-workers \
    --node-type t3.xlarge \
    --nodes 3 \
    --nodes-min 1 \
    --nodes-max 4 \
    --alb-ingress-access \
    --external-dns-access \
    --full-ecr-access \
    --managed
    ```

1. Configure `kubectl` for the created cluster

    If not done before: set AWS Credentials (you need AWS Access Key ID, and AWS Secret Access Key for this):

    ```console
    aws configure
    ```

    If you have not created the cluster with `eksctl` on the same computer before you need to manually create a kubeconfig entry:

    ```console
    aws eks --region <AWS_REGION> update-kubeconfig --name <AWS_CLUSTER_NAME>
    ```

    Check that your new cluster is registered with `kubectl`:

    ```console
    kubectl config get-contexts
    ```

    If you have multiple contexts for your local `kubectl` you may need to switch to the one for your AWS cluster:

    ```console
    kubectl config use-context <AWS_CLUSTER_NAME>
    ```

    Check if kubectl can communicate with the Kubernetes Cluster in AWS:

    ```console
    kubectl version
    ```

1. Prepare Helm Chart Deployment

    Switch to the directory that includes your certificate files.

    ```console
    kubectl create secret tls xecm-secret --cert fullchain.pem --key privkey.pem
    ```

1. Deploy Ingress Controller

    The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster

    [Installing the AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)


1. Create EBS CSI driver IAM role for service accounts(Required for EKS 1.23 and above)


    The Amazon EBS CSI plugin requires IAM permissions to make calls to AWS APIs on your behalf.

    [Creating the Amazon EBS CSI driver IAM role for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html)

1. Deploy Helm Chart

    Now we can install the `otxecm` Helm chart:

    ```console
    helm upgrade -i <RELEASE_NAME> otxecm \
    --set global.ingressClass=alb \
    --set global.storageClassName=gp2 \
    --set global.storageClassNameNFS=nfs \
    --set 'global.ingressAnnotations.alb\.ingress\.kubernetes\.io/certificate-arn'='<YOUR  arn:aws:acm CERTIFICATE>' \
    --set global.imageSource=<DOCKER REGISTRY PATH> \
    --set global.ingressDomainName=<DOMAIN NAME> \
    --set global.ingressSSLSecret=xecm-secret \
    --set global.masterPassword='<PASSWORD>' \
    --set global.otacPublicUrl="https://<OTAC URL PATH>" \
    --set global.otcsPublicUrl="https://<OTCS URL PATH>" \
    --set global.otdsPublicUrl="https://<OTDS URL PATH>" \
    --set otac.database.hostname=<DATABASE HOSTNAME> \
    --set otac.database.name=<OTAC DATABASE NAME> \
    --set otac.database.username=<OTAC DATABASE USER> \
    --set otcs.config.database.hostname=<DATABASE HOSTNAME> \
    --set otcs.config.database.name=<OTCS DATABASE NAME> \
    --set otcs.config.database.username=<OTCS DATABASE USER> \
    --set otcs.config.documentStorage.type=otac \
    --set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
    --set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
    --set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
    --set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
    ```

   The deployment of the Helm Chart triggers the creation of an ALB loadbalancer for the Kubernetes Ingress.

1. Configure DNS

    At this point you have to go to [AWS Route 53 DNS zone management](https://console.aws.amazon.com/route53/home) and create the DNS entries for OTDS, OTCS and OTAC and point them to the created load balancer (Alias)

    You can list hosted zones with this command:

    ```console
    aws route53 list-hosted-zones

    aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID>
    ```

    Replace `<ZONE_ID>` with the zone ID `aws route53 list-hosted-zones` returned.

    We need three DNS record sets:
    - OTDS (use name "otds")
    - Content Server frontend (use name "otcs")
    - Archive Center (use name "otac")

    For all choose the type "A - IPv4 address" and set "Alias" to yes. Select the ALB loadbalancer as "Alias Target".

Access Directory Services and Content Server frontends with the URLs provided by the global.otcsPublicUrl and global.otdsPublicUrl.

To shutdown the deployment follow these steps:

1. Remove the DNS entries that have aliases to the load balancer

    > **Important**: To shutdown the deployment you first have to remove the Aliases in the DNS records in AWS Route 53. Go to AWS Route 53 and delete the Record Sets for otac, otcs, and otds you have created during deployment.

1. Delete the otxecm Helm chart

    > **Important**: delete first the otxecm Helm Chart - then the ALB Helm Chart - otherwise the ALB loadbalancer will not be deleted and you will run into issues if you delete the cluster.

    You can delete the otxecm Helm Chart like this (replace `<RELEASE_NAME>` with the release name `helm list` returns):

    ```console
    helm list

    helm delete <RELEASE_NAME>
    ```

1. Delete persistent storage (if you want to start from scratch)

    ```console
    kubectl delete pvc --all
    ```

    > **Important**: `kubectl delete pvc --all` will delete all the persistent data of your deployment (including database storage). Do this only if you want to start from scratch!

1. Delete the ALB Helm Chart

    You can delete the ALB Helm Chart like this (replace `<ALB_RELEASE_NAME>` with the release name `helm list` returns):

    ```console
    helm list -n kube-system

    helm delete -n kube-system <ALB_RELEASE_NAME>
    ```

1. Delete the Kubernetes Cluster

    > **Important**: Remove everything you have created manually in AWS as this otherwise will not be deleted by `eksctl` and thus the deletion of the cluster will fail and you will end up with stale AWS resources you have to delete manually!
    > **Important**: Check if all Kubernetes resources are really freed up before deleting the cluster: `kubectl get pv` and `kubectl get pvc` should not list any resources. In doubt wait some time.

    Then you can delete the cluster with this command:

    ```console
    eksctl delete cluster --name <AWS_CLUSTER_NAME> --region <AWS_REGION> --wait
    ```

Using EFS (external file system):

```console
aws efs create-file-system \
--creation-token <AWS_CLUSTER_NAME>  \
--performance-mode generalPurpose \
--throughput-mode bursting \
--region <AWS_REGION>
```

Take note of the file system ID that is output by the command above.

Then install Amazon EFS CSI driver:

The Amazon EFS Container Storage Interface (CSI) driver provides a CSI interface that allows Kubernetes clusters running on AWS to manage the lifecycle of Amazon EFS file systems.

[Installing the Amazon EFS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)

Check that a new Kubernetes storage class `aws-efs` has been created:

```console
kubectl get storageclasses
```

The storage class `aws-efs` should be listed.

To delete the external file system:

```console
aws efs delete-file-system --file-system-id <YOUR FILE SYSTEM ID>
```

### Example Installation and Configuration for Azure AKS

This example creates a cluster named `xecm-cluster` and uses TLS (SSL). You need to create the TLS certificate with Let's Encrypt, or some other method that makes available fullchain.pem and privatekey.pem files. You need to create a docker container registry either on Azure or elsewhere that is accessible to Azure. Make sure the docker images you are using are pushed and available.

1. Create Resource Group

    Replace `myresourcegroup` with your own resource group name and `westeurope` with your preferred Azure location.

    ```console
    az group create --name myresourcegroup --location westeurope
    ```

1. Create Cluster

    Alternately, you can create a kubernetes cluster with the Azure web portal.

    Replace `myresourcegroup` with the resource group name your created before and `westeurope` with your preferred Azure location. Also replace `myregistry` with the name of your container registry in Azure.

    ```console
    az aks create \
    --name xecm-cluster \
    --resource-group myresourcegroup \
    --kubernetes-version <set-a-supported-version> \
    --node-count 3 \
    --node-vm-size Standard_B4ms \
    --attach-acr myregistry \
    --dns-name-prefix xecm \
    --location westeurope
    ```

1. Configure `kubectl` for the created cluster

    Replace `xecm-cluster` with the name of the cluster you created in the step before and `myresourcegroup` with the resource group name your created before.

    ```console
    az aks get-credentials \
    --name xecm-cluster \
    --resource-group myresourcegroup
    ```

1. Connect Azure Kubernetes cluster with the Azure container repository

    ```console
    az aks update \
    --name xecm-cluster \
    --resource-group myresourcegroup \
    --attach-acr extendedecm
    ```

1. Create a static IP address in Azure

    Replace `xecm-cluster` with the name of the cluster you created in the step before and `myresourcegroup` with the resource group name your created before. After the IP is created, you will need to point your dns for any domains being used to this IP.

    ```console
    az network public-ip create \
    --name xecm-ip \
    --resource-group MC_myresourcegroup_xecm-cluster_westeurope \
    --allocation-method static \
    --query publicIp.ipAddress \
    --sku Standard \
    -o tsv
    ```

1. Prepare Helm Chart Deployment

    Create a kubernetes secret from your TLS certificate files.

    ```console
    kubectl create secret tls xecm-secret --cert fullchain.pem --key privkey.pem
    ```

1. (Optional) Create a custom storage class if you are using shared storage across multiple Content Server Admin (search) servers.

    The Content Server Admin server requires the ability to change file timestamps. A custom storage class must be created to allow the mounted files to be owned by the user running the container. The following yaml file is only an example, and may be out of date for syntax. You may also need to modify the 'skuName' if you have different storage requirements. Please see this url for full options:

    [Azure - Create a custom storage class](https://docs.microsoft.com/en-us/azure/aks/azure-files-csi#create-a-custom-storage-class)

    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: shared-azurefile
    provisioner: file.csi.azure.com
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
      - dir_mode=0777
      - file_mode=0777
      - uid=1000
      - gid=1000
      - mfsymlinks
    parameters:
      skuName: Standard_LRS
    ```

    Copy the above yaml to a filename of your choice and create the storage class:

    ```console
    kubectl create -f my_storage_class.yaml
    ```

    When deploying the helm chart below, you must specify this parameter to use your storage class:

    ```console
    --set otcs.config.search.sharedSearch.storageClassName=shared-azurefile
    ```

1. Deploy Ingress Controller

    Replace the IP address with the one created previously.

    ```console
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm install otxecm-ingress ingress-nginx/ingress-nginx \
    --set rbac.create=true \
    --set controller.service.loadBalancerIP=<YOUR STATIC IP ADDRESS>
    ```

1. Deploy Helm Chart

    ```console
    helm upgrade -i <RELEASE_NAME> otxecm \
    --set global.storageClassName=default \
    --set global.storageClassNameNFS=azurefile \
    --set global.imageSource=<DOCKER REGISTRY PATH> \
    --set global.ingressDomainName=<DOMAIN NAME> \
    --set global.ingressSSLSecret=xecm-secret \
    --set global.masterPassword='<PASSWORD>' \
    --set global.otacPublicUrl="https://<OTAC URL PATH>" \
    --set global.otcsPublicUrl="https://<OTCS URL PATH>" \
    --set global.otdsPublicUrl="https://<OTDS URL PATH>" \
    --set otac.database.hostname=<DATABASE HOSTNAME> \
    --set otac.database.name=<OTAC DATABASE NAME> \
    --set otac.database.username=<OTAC DATABASE USER> \
    --set otcs.config.database.hostname=<DATABASE HOSTNAME> \
    --set otcs.config.database.name=<OTCS DATABASE NAME> \
    --set otcs.config.database.username=<OTCS DATABASE USER> \
    --set otcs.config.documentStorage.type=otac \
    --set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
    --set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
    --set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
    --set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
    ```

Access Directory Services and Content Server frontends with these URLs:

- Content Server: `https://<OTCS_DOMAIN_NAME>/cs/cs`
- Directory Services: `https://<OTDS_DOMAIN_NAME>/otds-admin`

To shutdown the deployment and delete the cluster do the following (replace the `<RELEASE_NAME>` with the release names `helm list` returns):

```console
helm list
helm delete <RELEASE_NAME>
helm delete otxecm-nginx
kubectl delete pvc --all
az aks delete --name xecm-cluster --resource-group myresourcegroup
```

> **Important**: `kubectl delete pvc --all` will delete all the persistent data of your deployment (including database storage). Do this only if you want to start from scratch!


### Example Installation and Configuration for RedHat Code Ready Container

Download CRC and the pull secret from the [RedHat CRC website](https://cloud.redhat.com/openshift/install/crc/installer-provisioned).

You may need to create a (free) account to get access.

1. Check to Code Ready Container (crc) is properly installed

    ```console
    crc version
    ```

1. Setup and Start crc

    Depending on the size of your machine you can tweak the parameters for memory (`-m`) and number of CPUs (`-c`).

    ```console
    crc setup

    crc start -c 6 -m 32768 -p ~/Downloads/pull-secret
    ```

    > **Important**: Take note of the output of the `crc start` command - it shows you the **admin password** for the cluster you need in the next steps.

1. Setup OpenShift and login

    You need to provide the admin user with `-u` and the admin password with `-p`.

    ```console
    eval $(crc oc-env)

    oc login -u kubeadmin -p <YOUR ADMIN PASSWORD> https://api.crc.testing:6443
     ```

    To check versions and see which nodes got created you can use these commands (this is optional):

    ```console
    oc version

    kubectl cluster-info

    kubectl get nodes
    ```

1. Setup OpenShift Project & Policies

    Run your deployment in an own OpenShift project and use `otxecm` as the name of this project. This will also create a Kubernetes namespace with that name. If you have not yet created a project named `otxecm` do so with this command:

    ```console
    oc new-project otxecm
    ```

    Otherwise switch to your existing `otxecm` project with this command:

    ```console
    oc project otxecm
    ```

    Optional you can check the content of the `otxecm` project and that the namespace have been created:

    ```console
    oc get project otxecm -o yaml

    kubectl get namespaces
    ```

    OpenShift also requires your deployment to run in its own **service account** - call it `otxecm-service-account` and use the `-n` option to define the project / namespace you created before:

    ```console
    oc create serviceaccount otxecm-service-account -n otxecm

    kubectl get serviceaccounts
    ```

    Now you have to set appropriate permissions:

    ```console
    oc adm policy add-scc-to-user privileged system:serviceaccount:otxecm:otxecm-service-account
    ```

1. Start CRC Console

    ```console
    crc console
    ```

    Use these login information
    - Login: kubeadmin
    - Password: \<YOUR ADMIN PASSWORD>

    Select Home --> Projects in the menu on the left and select "otxecm".

1. Content Management Deployment

    Create secret for pulling Docker images from Docker Hub:

    ```console
    kubectl create secret docker-registry regcred \
    --docker-server=https://registry.opentext.com/v2/ \
    --docker-username="<OT_ACCOUNT>" \
    --docker-password="<OT_PASSWORD>" \
    --docker-email=<EMAIL>
    ```

    Deploy Helm Chart:

    ```console
    helm upgrade -i <RELEASE_NAME> otxecm \
    --set global.ingressClass=openshift-default \
    --set global.ingressEnabled=false \
    --set global.storageClassName="" \
    --set global.storageClassNameNFS=nfs \
    --set global.imageSource=<DOCKER REGISTRY PATH> \
    --set global.ingressDomainName=<DOMAIN NAME> \
    --set global.ingressSSLSecret=xecm-secret \
    --set global.masterPassword='<PASSWORD>' \
    --set global.otacPublicUrl="https://<OTAC URL PATH>" \
    --set global.otcsPublicUrl="https://<OTCS URL PATH>" \
    --set global.otdsPublicUrl="https://<OTDS URL PATH>" \
    --set otac.database.hostname=<DATABASE HOSTNAME> \
    --set otac.database.name=<OTAC DATABASE NAME> \
    --set otac.database.username=<OTAC DATABASE USER> \
    --set otcs.config.database.hostname=<DATABASE HOSTNAME> \
    --set otcs.config.database.name=<OTCS DATABASE NAME> \
    --set otcs.config.database.username=<OTCS DATABASE USER> \
    --set otcs.config.documentStorage.type=otac \
    --set otds.otdsws.cryptKey=<OTDS CRYPT KEY> \
    --set otds.otdsws.otdsdb.automaticDatabaseCreation.enabled=true \
    --set otds.otdsws.otdsdb.url="jdbc:postgresql://<DATABASE HOSTNAME>:5432/<OTDS DATABASE NAME>" \
    --set otds.otdsws.otdsdb.username=<OTDS DATABASE USER> \
    ```

1. Expose Kubernetes Services as routes in OpenShift

    ```console
    oc expose service otds

    oc expose service otcs-frontend
   ```

1. Access Directory Services and Content Server frontends

    <http://otds-otxecm.apps-crc.testing/otds-admin/>

    <http://otcs-frontend-otxecm.apps-crc.testing/cs/cs?func=llworkspace>

    <http://otcs-frontend-otxecm.apps-crc.testing/cs/cs/app>

1. Stop and Restart CRC

    To (temporarily) stop CRC:

    ```console
    crc stop
    ```

1. Finally delete CRC

    To (finally) delete CRC and the Kubernetes cluster:

    ```console
    crc delete
    ```

    A `crc delete` does not automatically remove the kubectl configurations - you have to do this manually to fully clean things up:

    ```console
    kubectl config delete-context otxecm/api-crc-testing:6443/kube:admin

    kubectl config delete-context default/api-crc-testing:6443/kube:admin
    ```
