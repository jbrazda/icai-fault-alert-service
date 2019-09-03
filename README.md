# Uncaught Fault Alert Service Implementation

This project contains Informatica IICS CAI Fault alert Service Implementation.
Provided Service allows to apply declarative Alert Rules and flexible framework to use any of the built-in or custom Actions

## Features

- Declarative extensible configuration providers (currently supports github gist, http(s) get, local file)
- Declarative rules to route message to specific actions with flexibility to add custom actions (event triggers via JMS,AWS SQS, Kafka)
- Declarative Actions currently supported
    - ignore
    - alert-email
- Ability to  Save/read configuration in xml on simple http get provider or github gist  or similar snippet storage
- Other configuration storage and action providers should be possible to develop via ICAI Service Connectors
- Guide based configuration manager

## Components
