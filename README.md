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

Open new empty Eclipse Workspace in `{USER_HOME}/workspace/icai-fault-alert-service`
Switch to Process Developer Perspective

![Eclipse_PD_Perspective](./doc/images/Eclipse_PD_Perspective.png)

Import Cloned repository project as an existing project (assuming you cloned the project to your {USER_HOME}/git folder)

![Eclipse_Import_Existing](./doc/images/Eclipse_Import_Existing.png)

Select Your Exported Git Repo root  folder and finish import

![Eclipse_Import_Project](./doc/images/Eclipse_Import_Project.png)

Open the Ant View using `Window > Show View > Other`

![Open Ant View](./doc/images/IPD_Show_View_Other.png)

Reposition Ant View to a tab below Project Explorer and drag build.xml to Ant runner View

![Eclipse_Ant_Build](./doc/images/Eclipse_Ant_Build.png)

Run The package.src Target, Select the Release configuration from conf directory and Confirm

![Ant_Package_Input_Release_Config](./doc/images/Ant_Package_Input_Release_Config.png)

Select target Environment

![Ant_Package_Input_Environment](./doc/images/Ant_Package_Input_Environment.png)

Select Package Configuration. This step allows to select configuration file that drives what's included/excluded  in the target deployment package.
Use the `all_designs.package.txt` for initial import only (it includes connections and connectors)
Use the `all_exclude_connections.package.txt` for Subsequent builds and updates (it excludes connections and connectors)

![Ant_Package_Input_PackageConf](./doc/images/Ant_Package_Input_PackageConf.png)

Script will generate Package using an iics tool downloaded from github

```text
Buildfile: /Users/jbrazda/git/icai-fault-alert-service/build.xml
-init:
-env.info:
     [echo] ========================================
     [echo] ==        IPD Bunde Build             ==
     [echo] ========================================
     [echo] Java Version:    1.8.0_162-b12
     [echo] Java Home:       /Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/jre
     [echo] Ant Version:     Apache Ant(TM) version 1.8.4 compiled on May 22 2012
     [echo] Ant Lib:         /Applications/eclipse_kepler/plugins/org.apache.ant_1.8.4.v201303080030/lib
     [echo] eclipse.home:    ${eclipse.home}
     [echo] shell:           bash
     [echo] os.name:         Mac OS X
     [echo] os.version:      10.14.6
     [echo] os.arch:         x86_64
     [echo] user.name:       jbrazda
     [echo] user.dir:        /Users/jbrazda/git/icai-fault-alert-service
     [echo] user.home:       /Users/jbrazda
     [echo] env.HOME:        /Users/jbrazda
     [echo] env.LANG:        en_US.UTF-8
     [echo] env.SHELL:       /bin/zsh
     [echo] env.PATH:        /usr/bin:/bin:/usr/sbin:/sbin
     [echo] env.JAVA_HOME:   /Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
     [echo] ========================================
-select-release:
     [echo] Available Release Configurations:
     [echo] =================================
     [echo] /Users/jbrazda/git/icai-fault-alert-service/conf/iclab-dev.release.properties
     [echo] =================================
-set-release-properties:
     [echo] Selected Release Configuration: iclab-dev.release
     [echo] Selected File: /Users/jbrazda/git/icai-fault-alert-service/conf/iclab-dev.release.properties
-load.release.properties:
     [echo] Loading /Users/jbrazda/git/icai-fault-alert-service/conf/iclab-dev.release.properties
     [echo] Loading External properties (credentials) from /Users/jbrazda/iics/iclab.properties
     [echo] TODO: Add Inputs Validation
-select-target-environment:
     [echo] Selected Target Environment: dev
-set-target-properties:
-select-package-config:
     [echo] Available Target Package Configurations:
     [echo] ========================================
     [echo] /Users/jbrazda/git/icai-fault-alert-service/conf/all_designs.package.txt
     [echo] /Users/jbrazda/git/icai-fault-alert-service/conf/all_exlude_connections.package.txt
     [echo] ========================================
     [echo] Selected Target Package Configuration: all_designs.package
     [echo] Selected File: /Users/jbrazda/git/icai-fault-alert-service/conf/all_designs.package.txt
iics.package:
    [mkdir] Created dir: /Users/jbrazda/git/icai-fault-alert-service/target/iclab-dev.release/import/dev
     [echo] Running iics package -z "/Users/jbrazda/git/icai-fault-alert-service/target/iclab-dev.release/import/dev/FaultAlertService.zip" -w "/Users/jbrazda/git/icai-fault-alert-service/src/ipd" -f "/Users/jbrazda/git/icai-fault-alert-service/conf/all_designs.package.txt"
     [exec] [36mINFO[0m[0000] IICS CLI Version                              [36mVersion[0m=2.0.0
     [exec] [36mINFO[0m[0000] Reading artifacts from file                   [36mFile[0m=/Users/jbrazda/git/icai-fault-alert-service/conf/all_designs.package.txt
     [exec] [36mINFO[0m[0000] Gathered artifacts                            [36mArtifacts[0m="[Explore/Alerting.Project Explore/Tools.Project]"
     [exec] [36mINFO[0m[0000] Packaging artifacts                           [36mWorkspace Directory[0m=/Users/jbrazda/git/icai-fault-alert-service/src/ipd
     [exec] [36mINFO[0m[0000] Artifact verification complete                [36mResult[0m=true
     [exec] [36mINFO[0m[0000] Copying artifacts to temp folder
     [exec] [36mINFO[0m[0000] Creating checksum fil
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Project Explore/Alerting.Project.json Explore/.Alerting.Project.json Explore/Alerting.Project }" [36mChecksum[0m="Explore/Alerting.Project.json=7BFFC629A0012621C1C69CA78164E64425BE2B78FC303FEEB19E66F5379A2FAF\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Alerting/Connections.Folder.json Explore/Alerting/.Connections.Folder.json Explore/Alerting/Connections.Folder }" [36mChecksum[0m="Explore/Alerting/Connections.Folder.json=F2784716473469144FB23D8924CA1B617711119189CEF67DEC4A5F774FD8C669\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{AI_CONNECTION Explore/Alerting/Connections/AWS-SQS-Alerts.AI_CONNECTION.xml Explore/Alerting/Connections/.AWS-SQS-Alerts.AI_CONNECTION.json Explore/Alerting/Connections/AWS-SQS-Alerts.AI_CONNECTION }" [36mChecksum[0m="Explore/Alerting/Connections/AWS-SQS-Alerts.AI_CONNECTION.xml=A69D2AA73E070569E46F7162067124EADA9E1000957AF99CEFE5BF8C41713AD8\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{AI_CONNECTION Explore/Alerting/Connections/Email-Alerts.AI_CONNECTION.xml Explore/Alerting/Connections/.Email-Alerts.AI_CONNECTION.json Explore/Alerting/Connections/Email-Alerts.AI_CONNECTION }" [36mChecksum[0m="Explore/Alerting/Connections/Email-Alerts.AI_CONNECTION.xml=EF7F629C07FA84D8264B76A108047949B548106C733C404A47E5D6BD899466DB\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{AI_CONNECTION Explore/Alerting/Connections/github-gist-alert-configuration.AI_CONNECTION.xml Explore/Alerting/Connections/.github-gist-alert-configuration.AI_CONNECTION.json Explore/Alerting/Connections/github-gist-alert-configuration.AI_CONNECTION }" [36mChecksum[0m="Explore/Alerting/Connections/github-gist-alert-configuration.AI_CONNECTION.xml=EF6ACE796F14F96BBC642F67BF7F951C208AF066B95BB1F30531D49C64EAE49B\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Alerting/Guides.Folder.json Explore/Alerting/.Guides.Folder.json Explore/Alerting/Guides.Folder }" [36mChecksum[0m="Explore/Alerting/Guides.Folder.json=437C4685A6D5F0E038BBA4A9E5834A121CA51B6F58350E87BF5ABBCEF76FE3B4\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{GUIDE Explore/Alerting/Guides/Alert Configuration Manager.GUIDE.xml Explore/Alerting/Guides/.Alert Configuration Manager.GUIDE.json Explore/Alerting/Guides/Alert Configuration Manager.GUIDE }" [36mChecksum[0m="Explore/Alerting/Guides/Alert\\ Configuration\\ Manager.GUIDE.xml=738F2CB94C551271D6778800D034EC57CFAB37F8B9C2E727EC2D3CF4F0726700\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Alerting/ProcessObjects.Folder.json Explore/Alerting/.ProcessObjects.Folder.json Explore/Alerting/ProcessObjects.Folder }" [36mChecksum[0m="Explore/Alerting/ProcessObjects.Folder.json=0AC3F26AFD1F29AD01F01A9E1E863E841775A7489A1E0AA5A2F8A27D885CBB11\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/FaultAlertConfiguration.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.FaultAlertConfiguration.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/FaultAlertConfiguration.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/FaultAlertConfiguration.PROCESS_OBJECT.xml=BDBA43D49F3FEF597389B9188B8541EF67B64FDB442131B71D33C357A2D24B73\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/action-email.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.action-email.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/action-email.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/action-email.PROCESS_OBJECT.xml=CC6AA1318BD4064EA992832D879C5DF3D6CBE1036DFA0F15E0330EE1F4BC3C99\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/action-ref.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.action-ref.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/action-ref.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/action-ref.PROCESS_OBJECT.xml=3057210CAD08BD2EA097855A6E214BE824C1CC6B7B3E0FDD83C01FA5CDCBA27B\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/action.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.action.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/action.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/action.PROCESS_OBJECT.xml=0481F5D60A70E15C77F308F136B2D98B58673CEDE4C66A56A17E681B4096D1E4\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/actions.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.actions.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/actions.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/actions.PROCESS_OBJECT.xml=3666DE9E95998F8E13105C8D9447D1EC12D56E805052EA1402F07574BDB2300F\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/alert-config.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.alert-config.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/alert-config.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/alert-config.PROCESS_OBJECT.xml=2C409F6423B125F6946D97807EF16FB3EB4F805898A9F757C32B8548177CC98D\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/condition.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.condition.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/condition.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/condition.PROCESS_OBJECT.xml=D5A4F4298552F13F42D940DA2F40D370D6464A1A9A12FA16B8A4EC5B15A55480\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/rule.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.rule.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/rule.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/rule.PROCESS_OBJECT.xml=2B47776C040F3308E4A6573AE1098738711A1ECA2E2A01CDD800B79F9B61C5CC\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Alerting/ProcessObjects/rules.PROCESS_OBJECT.xml Explore/Alerting/ProcessObjects/.rules.PROCESS_OBJECT.json Explore/Alerting/ProcessObjects/rules.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Alerting/ProcessObjects/rules.PROCESS_OBJECT.xml=E4EBBABEBE655FC5BEF0792E2D265DC033C9CCD1AA8AEBE6617D91C1961183E0\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Alerting/Processes.Folder.json Explore/Alerting/.Processes.Folder.json Explore/Alerting/Processes.Folder }" [36mChecksum[0m="Explore/Alerting/Processes.Folder.json=A07C5F502987589258A11853E168B04AB165659E5FC9E305703555EA005B69FB\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS Explore/Alerting/Processes/UncaughtFaultAlertHandler-Cloud.PROCESS.xml Explore/Alerting/Processes/.UncaughtFaultAlertHandler-Cloud.PROCESS.json Explore/Alerting/Processes/UncaughtFaultAlertHandler-Cloud.PROCESS }" [36mChecksum[0m="Explore/Alerting/Processes/UncaughtFaultAlertHandler-Cloud.PROCESS.xml=CE8CB2D0329CE0CCBB04E858F2A9184C01DF61DA65F3EE55E2924DAD2AD78BB0\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS Explore/Alerting/Processes/UncaughtFaultAlertHandler-NA.PROCESS.xml Explore/Alerting/Processes/.UncaughtFaultAlertHandler-NA.PROCESS.json Explore/Alerting/Processes/UncaughtFaultAlertHandler-NA.PROCESS }" [36mChecksum[0m="Explore/Alerting/Processes/UncaughtFaultAlertHandler-NA.PROCESS.xml=6B2271E9EC067BBBDADEFF58A5CCC92AB92FBFA583FFB2E00CBF9798C7594490\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Project Explore/Tools.Project.json Explore/.Tools.Project.json Explore/Tools.Project }" [36mChecksum[0m="Explore/Tools.Project.json=467871ABEF9EC13ABF617CC1D647ED8EE95D9E4E1DE155E2C4EFBDB4EEFBBC43\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Tools/ProcessObjects.Folder.json Explore/Tools/.ProcessObjects.Folder.json Explore/Tools/ProcessObjects.Folder }" [36mChecksum[0m="Explore/Tools/ProcessObjects.Folder.json=94ECF23F8B13EA1F4E61E9AA7F0936C78BFD51864247B7FAFDF05D14622C1720\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS_OBJECT Explore/Tools/ProcessObjects/AttchmentInformation.PROCESS_OBJECT.xml Explore/Tools/ProcessObjects/.AttchmentInformation.PROCESS_OBJECT.json Explore/Tools/ProcessObjects/AttchmentInformation.PROCESS_OBJECT }" [36mChecksum[0m="Explore/Tools/ProcessObjects/AttchmentInformation.PROCESS_OBJECT.xml=EA0036AFEB453064ED998FB172FF3C9920B5308DB999B8518358A65B6FEE8948\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Tools/Processes.Folder.json Explore/Tools/.Processes.Folder.json Explore/Tools/Processes.Folder }" [36mChecksum[0m="Explore/Tools/Processes.Folder.json=E200175169D1F8F83E3B49E0EDE49ED7A2C354EE8704D72A2D5353FA69357380\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{PROCESS Explore/Tools/Processes/SP-ConvertAttachmentToText.PROCESS.xml Explore/Tools/Processes/.SP-ConvertAttachmentToText.PROCESS.json Explore/Tools/Processes/SP-ConvertAttachmentToText.PROCESS }" [36mChecksum[0m="Explore/Tools/Processes/SP-ConvertAttachmentToText.PROCESS.xml=E4619B8500BC4AA808F64BE98B23A6FCFA3E55B3D76F71DA29B2AC257854C6EF\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{Folder Explore/Tools/ServiceConnectors.Folder.json Explore/Tools/.ServiceConnectors.Folder.json Explore/Tools/ServiceConnectors.Folder }" [36mChecksum[0m="Explore/Tools/ServiceConnectors.Folder.json=28F4713ECC03D81EE83F12BF320483C7576BB5AE3200C168715FEC83F6B1AA41\n"
     [exec] [36mINFO[0m[0000] Generated checksum for artifact               [36mArtifact[0m="{AI_SERVICE_CONNECTOR Explore/Tools/ServiceConnectors/github-gist.AI_SERVICE_CONNECTOR.xml Explore/Tools/ServiceConnectors/.github-gist.AI_SERVICE_CONNECTOR.json Explore/Tools/ServiceConnectors/github-gist.AI_SERVICE_CONNECTOR }" [36mChecksum[0m="Explore/Tools/ServiceConnectors/github-gist.AI_SERVICE_CONNECTOR.xml=0AA9C879F389E2811F79D0B3B3B6C6708AAF6D55B596BFF9B50F9A4293886D67\n"
     [exec] [36mINFO[0m[0000] Generated checksum for metadata file          [36mChecksum[0m="exportMetadata.v2.json=E51CF7D22504344C652B950CB185538432B3225EB2E1D0832FECBB4EF296CFAB" [36mFile[0m=/var/folders/hd/q4v90yb52d980_lvj56yxd5c0000gp/T/iics-cli648713486/exportMetadata.v2.json
     [exec] [36mINFO[0m[0000] Creating zip file                             [36mFile[0m=/Users/jbrazda/git/icai-fault-alert-service/target/iclab-dev.release/import/dev/FaultAlertService.zip
package.src:
BUILD SUCCESSFUL
Total time: 10 seconds
```

TODO Describe Import Steps

#### On Command Line

You can run the same as in eclipse from command line using a following command

Build a full package DEV Target

```shell
ant package.src \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=dev \
-Diics.target.package.config=./conf/all_designs.package.txt
```

Build a package without Connections DEV Target

```shell
ant package.src \
-Diics.release=./conf/iclab-dev.release.properties \
-Diics.target.environment=dev \
-Diics.target.package.config=./conf/all_exclude_connections.package.txt
```

TODO Describe Import Steps

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

The Setup of Alert Service will be possible only after the `UncaughtFaultAlertHandler` service is published to the corresponding target environment.

> Note: you should rename the `Alerting/Processes/UncaughtFaultAlertHandler-NA` to match your Secure Agent group name after initial install step,
because currently ICAI does not allow single process to be deployed (published) to multiple target locations, thus requiring to create process copy for Each agent group or Cloud

![Alert Configuration](./doc/images/Application_Integration_Console_Alerts.png)

> [See Known Issues](#markdown-header-known-issues)

### Pre-built Distribution

If you decide to not clone this repository and re-build the package from Sources You can use provided im
for first time Installation to target org manually.

IPD Import Package [Download](./distribution/AlertService.zip)

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
