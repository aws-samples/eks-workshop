---
title: "Spinnaker Overview"
weight: 10
draft: false
---

### Spinnaker Architecture

You can also see the detailed architecture of spinnaker at [Armory docs](https://docs.armory.io/docs/overview/architecture/).

![architecture](/images/spinnnaker/architecture.png)
Image source:https://docs.armory.io/docs/overview/architecture/

**Deck**: Browser-based UI for Spinnaker.

**Gate**: API callers and Spinnaker UI communicate to Spinnaker server via this API gateway called Gate.

**Orca**: Pipelines and other ad-hoc operations are managed by this orchestration engine called Orca.

**Clouddriver**: Indexing and Caching of deployed resources are taken care by Clouddriver. It also facilitates calls to cloud providers like AWS, GCE, and Azure.

**Echo**: It is responsible for sending notifications, it also acts as incoming webhook.

**Igor**: It is used to trigger pipelines via continuous integration jobs in systems like Jenkins and Travis CI, and it allows Jenkins/Travis stages to be used in pipelines.

**Front50**: It's the metadata store of Spinnaker. It persists metadata for all resources which include pipelines, projects, applications and notifications.

**Rosco**: Rosco bakes machine images (AWS AMIs, Azure VM images, GCE images).

**Rush**: It is Spinnaker's script excution engine.

### Spinnaker Concepts

Spinnaker provides two core sets of features:

- **Application management** (a.k.a. infrastructure management)
You use Spinnaker’s [application management](https://spinnaker.io/concepts/#application-management-aka-infrastructure-management) features to view and manage your cloud resources.

- **Application deployment** 
You use Spinnaker’s application deployment features to construct and manage continuous delivery workflows.

In this workshop, we are only focussing on Application Deployment so lets deep dive into this feature. More details on Spinnaker Nomenclature and Naming Conventions can be found at [Armory docs](https://docs.armory.io/docs/overview/naming-conventions/).

- **Pipeline**: The pipeline is the key deployment management construct in Spinnaker. It consists of a sequence of actions, known as stages. You can pass parameters from stage to stage along the pipeline.
![architecture](/images/spinnnaker/pipelines.png)
Image source:https://spinnaker.io/concepts/pipelines.png

- **Stage**: A Stage in Spinnaker is a collection of sequential Tasks and composed Stages that describe a higher-level action the Pipeline will perform either linearly or in parallel. 

- **Task**: A Task in Spinnaker is an automatic function to perform.

- **Deployment Strategies**: Spinnaker treats cloud-native deployment strategies as first class constructs, handling the underlying orchestration such as verifying health checks, disabling old server groups and enabling new server groups. Spinnaker supports the red/black (a.k.a. blue/green) strategy, with rolling red/black and canary strategies in active development.
