# Uncaught Fault Alert Service Implementation

<!-- TOC -->

- [Uncaught Fault Alert Service Implementation](#markdown-header-uncaught-fault-alert-service-implementation)
    - [Features](#markdown-header-features)
    - [Overview](#markdown-header-overview)
    - [Installation](#markdown-header-installation)
        - [Pre-Requisites](#markdown-header-pre-requisites)
        - [Build and Install the Package](#markdown-header-build-and-install-the-package)
        - [Build Package From Source](#markdown-header-build-package-from-source)
            - [In Process Developer](#markdown-header-in-process-developer)
            - [On Command Line](#markdown-header-on-command-line)
        - [Configure Your Org](#markdown-header-configure-your-org)
            - [URN mappings](#markdown-header-urn-mappings)
            - [Set Alert Service](#markdown-header-set-alert-service)
        - [Pre-built Distribution](#markdown-header-pre-built-distribution)
    - [Fault Alert Handler Configuration](#markdown-header-fault-alert-handler-configuration)
    - [Extending Alert Service](#markdown-header-extending-alert-service)
        - [Add Custom Action](#markdown-header-add-custom-action)
        - [Add Custom Configuration Storage Provider](#markdown-header-add-custom-configuration-storage-provider)
        - [Known Issues](#markdown-header-known-issues)
    - [Glossary of Terms used in this Documents](#markdown-header-glossary-of-terms-used-in-this-documents)

<!-- /TOC -->

This project contains Informatica IICS CAI Fault alert Service Implementation.
Provided Service allows to apply declarative Alert Rules and flexible framework to use any of the built-in or custom Actions

![Fault Alert Email Example](./doc/images/Fault_Alert_-_Error_-_Inbox.png)

## Features

- Declarative extensible configuration providers (currently supports github gist, http(s) get, local file)
- Declarative rules to route message to specific actions with flexibility to add custom actions (event triggers via JMS,AWS SQS, Kafka)
- Declarative Actions currently supported
    - ignore
    - alert-email
- Ability to Save/read configuration in xml on simple http get provider or github gist or similar snippet storage
- Other configuration storage and action providers should be possible to develop via ICAI Service Connectors
- Guide based configuration manager

## Overview

The Alert Service is available for processes that run on a Secure Agent or the Cloud Server. Alert Service provides a mechanism
to send alert notifications via built-in email notification service or define custom Alert Handler Process.

this project is a good example how to maintain, build and deploy Informatica IICS project with automation and version control and help of
IICS Asset Management CLI V2 Utility

> See [Alert Service Documentation][alert_service_help]
> See [IICS Asset Management CLI V2 Utility][iics_cli]

## Installation

### Pre-Requisites

It is highly recommend to use the build from source as it allows you to change certain attributes of service deployment such as target Secure agent group, etc.
To build and install from source, you'll need a following set of tools

- git client installed on your system
- Java 1.8 or higher installed on the System
- Apache Ant 1.9 or higher installed on the system or use Informatica Process Developer which includes Ant runtime
- Informatica Process Developer

You can follow this guide [Set Development Environment for IPD Development][development_setup] to setup your environment

> See Guide to [Install Process Developer][ipd_install_guide]

### Build and Install the Package

Fork and clone this repository

Clone example, Youse your own repository url if you forked this one

```shell
git clone git@github.com:jbrazda/icai-fault-alert-service.git
```

Configure credentials file That should look something like this
recommended location is your home directory/iics `~/iics/environment.properties as it will contain sensitive information.
I would also recommend to create Native Service user in each of your orgs that can be used to export/import resources via IICS REST API using the [IICS Asset Management CLI][iics_cli]
This tool will automatically download latest version an use it to import provided service to your target org

```properties
iics.user.dev=deployer-iics-dev@acme.com
iics.password.dev=YOURPWD

iics.user.test=deployer-iics-test@acme.com
iics.password.test=YOURPWD

iics.user.prod=deployer-iics-prod@informatica.com
iics.password.prod=YOURPWD
```

> WARNING Never put these properties into the project folder and keep this property file in a secure location ideally  '~/iics/environment.properties' The iics folder should be accessible only by user running the import/export/publish tasks ('700' type of permission on unix systems)

Update existing or copy [conf/iclab-dev.release.properties](conf/iclab-dev.release.properties) file which defines a key Environment specific parameters

```properties
# define a comma separated list of environment org labels such as
# dev,test,uat,prod
iics.environment.list=dev,test,prod

# This property points to file which contains credentials to login to individual environments
# we recommend to use user home/iics protected directory, never commit this file to version control with this project
# This must contain set of  properties following this naming convention for each environment defined in the iics.environment.list
# iics.user.${environment}=
# iics.password.${environment}=
iics.external.properties=${user.home}/iics/environment.properties

# this query is used by iics list command to retrieve available sources from repository to extract the designs from IICS
# see https://network.informatica.com/docs/DOC-18245#jive_content_id_List_Command
iics.query=-q "location==Alerting"

# Defines the output file for the list command
# the output location will be driven by the ${basedir}/target/${selected.release.basename}
iics.list.output=export_list.txt

# Defines the output file name for iics export command
# the output location will be driven by the ${basedir}/target/${selected.release.basename}
iics.export.output=FaultAlertService.zip

# Defines Output File name without extension
# the package.src will produce file in the following path ${basedir}/target/
iics.package.output=FaultAlertService

# Defines Extract output directory for iics extract command
iics.extract.dir=${basedir}/src/ipd
```

### Build Package From Source

#### In Process Developer

Open the Ant View

#### On Command Line

### Configure Your Org

The process Implementation requires certain system Lever properties configure to be able to send Notification emails

#### URN mappings

Fallowing URN mappings must be defined

| URN                                       | EXAMPLE                                            | Required | Comment                                                                            |
|-------------------------------------------|----------------------------------------------------|----------|------------------------------------------------------------------------------------|
| ae:base-uri                               | https://na1.ai.dm-us.informaticacloud.com          | Yes      | Base URL of Informatica Cloud Pod                                                  |
| urn:environment:name                      | Cloud Server {ENV} or Secure Agent Name            | Yes      | Environment Name                                                                   |
| urn:environment:orgid                     | Your ORG ID                                        | Yes      | Org ID.                                                                            |
| urn:ic:faultAlerts:configuration:provider | gist                                               | No       | Configuration Storage provider (Default is gist and supported values are gist,url) |
| urn:ic:faultAlerts:configuration:url      | URL of Configuration in Gist,File or http location | Yes      | Alert Service Configuration URL                                                    |
| urn:ic:faultAlerts:fallback:email         | iics_alerts@acme.com.com                           | Yes      | Fallback Email for Alert Service                                                   |

> See [URN Mappings][iics_urn_mappings]

#### Set Alert Service

Alert Service must be configured after the Deployment/Import and configuration of this package

Go to each `Application Integration Console > Server Configuration > Secure Agent`
and set the System Service pointing to `UncaughtFaultAlertHandler-{Agent Group Name}` where the `{Agent Group Name}` is Group name matching the process name for A corresponding Agent group where you deployed the

The Setup of Alert Service will be possible only after the UncaughtFaultAlertHandler service is published to the corresponding target environment.

> Note: you should rename the `Alerting/Processes/UncaughtFaultAlertHandler-NA` to match your Secure Agent group name after initial install step,
because currently ICAI does not allow single process to be deployed (published) to multiple target locations, thus requiring to create process copy for Each agent group or Cloud

![Alert Configuration](./doc/images/Application_Integration_Console_Alerts.png)

> [See Known Issues](#markdown-header-known-issues)

### Pre-built Distribution

If you decide to not clone this repository and re-build the package from Sources You can use provided im
for first time Installation to target org manually.

IPD Import Package [Download](./distribution/A;ertService/zip)

## Fault Alert Handler Configuration

This package contains ICAI

## Extending Alert Service

TBD

### Add Custom Action

TBD

### Add Custom Configuration Storage Provider

TBD

### Known Issues

Custom Alert handler Service Works only on Secure Agents, Currently there is an issue on IICS CLoud instances where only built in alert service works as expected , you will have to use built-in Alert Service Email notification on IICS Cloud Servers

## Glossary of Terms used in this Documents

| Term                            | Description                                                                                                                                                        |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| IICS                            | Informatica Intelligent Cloud Services, Informatica Cloud Integration platform                                                                                     |
| ICAI                            | (formerly ICRT) Informatica Cloud Application Integration, see ICRT                                                                                                |
| ICDI                            | (formerly ICS) Informatica Cloud Data Integration is an ETL batch integration component of IICS platform                                                           |
| BPEL                            | Business Process Execution Language                                                                                                                                |
| BPMN                            | Business Process Modeling Notation                                                                                                                                 |
| WSDL                            | Web Service Definition Language                                                                                                                                    |
| API                             | Application Programming Interface                                                                                                                                  |
| REST                            | REpresentational State Transfer                                                                                                                                    |
| IPD                             | Informatica Process Designer                                                                                                                                       |
| Application Integration Console | ICAI Cloud and Secure Agent Runtime Administration Tool                                                                                                            |
| Informatica Secure Agent        | Informatica Data Integration Execution Agent that Provides ability to integrate data on premise and in the Cloud, hybrid data integration both batch and real time |
| DAS                             | Data Access Service                                                                                                                                                |

[alert_service_help]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/index.htm#page/cai-aae-monitor/System_Services.html
[development_setup]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/set_development_environment.md
[iics_cli]: https://network.informatica.com/docs/DOC-18245
[ipd_install_guide]: https://github.com/jbrazda/Informatica/blob/master/Guides/InformaticaCloud/install_process_developer.md
[iics_urn_mappings]: https://network.informatica.com/onlinehelp/IICS/prod/CAI/en/cai-aae-monitor/URN_Mappings.html
