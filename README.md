# m2onk8s

[![Build Status](https://travis-ci.org/andrewhowdencom/m2onk8s.svg?branch=master)](https://travis-ci.org/andrewhowdencom/m2onk8s)
[![Maintenance](https://img.shields.io/maintenance/yes/2017.svg)]()
[![Docker Repository on Quay](https://quay.io/repository/littlemanco/magento/status "Docker Repository on Quay")](https://quay.io/repository/littlemanco/magento)

Description should probably go here. But I'm lazy, so not right now.

## Goals

Demonstrate that Kubernetes is a reasonable place to run Magento 2. Magento 2 has it's quirks, particulraaly around needing a full environment to compile and so on. So, it doesn't easily fit into the Kubernetes model. But with some tinkering, it works OK. And I'm still not keen on going back to managing pets.

## Usage

It's mostly here as a demo. I'm slowly refactoring it such that it can be used more generally, but at this point, it's
set up only to be used as a demo.

## Design Notes

### Packaging

All the Kubernetes resources are managed as a helm chart. Principally, this let's us use additional hooks around the
lifecycle of the application such that we can have a single proceedural install event, as well as running jobs that perform DB migrations after ever release. (I'm presuming that the migrations are idempotent)

## Limitations

I'll fix these slowly, depending on how my enthousasm holds up (it's running out)

- No state. 
- No cron.

## Versioning Strategy

The repository follows the follow versioning strategy:

```
${APP_VERSION}-${BUILD_NUMBER}
```

The app version follows the upstream Magnento build version, with all other deployable changes being a simple numeric increment.
For example,

```
2.1.7-1
```

This is inspired by the Debian versioning strategy.
