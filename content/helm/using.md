---
title: "Using Helm"
date: 2018-08-07T08:30:11-07:00
weight: 20
---
#### Deploy our Microservices using Helm

Instead of manually deploying our microservices using `kubectl`, we will create a custom Helm Chart. For detailed information on working with chart templates, refer to the [**Helm docs**](https://docs.helm.sh/chart_template_guide/)

Helm charts are structured like this:

```text
mychart/
  Chart.yaml  # a description of the chart
  values.yaml # the default values for the chart. May be overridden during install or upgrade.
  charts/ # May contain subcharts
  templates/ # the template files themselves
  ...
```

We'll start out by creating a new chart called **eksdemo**
```sh
cd ~/environment
helm create eksdemo
```

If you look in the the newly created **eksdemo** directory, you'll see several files and directories. Inside the /templates directory, you'll see these files.

* NOTES.txt: The “help text” for your chart. This will be displayed to your users when they run helm install.
* deployment.yaml: A basic manifest for creating a Kubernetes deployment
* service.yaml: A basic manifest for creating a service endpoint for your deployment
* _helpers.tpl: A place to put template helpers that you can re-use throughout the chart

We're actually going to create our own files, so we'll delete these boilerplate files
```
rm -rf ~/environment/eksdemo/templates/*.*
rm ~/environment/eksdemo/Chart.yaml
rm ~/environment/eksdemo/values.yaml
```
Create a new Chart.yaml file which will describe the chart
```
cat <<EoF > ~/environment/eksdemo/Chart.yaml
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for EKS Workshop Microservices application
name: eksdemo
version: 0.1.0
EoF
```

Now we'll copy the manifest files for each of our microservices into the templates directory as *servicename*.yaml
```
#create subfolders for each template type
mkdir  ~/environment/eksdemo/templates/deployment
mkdir  ~/environment/eksdemo/templates/service

# Copy and rename frontend manifests
cp ~/environment/ecsdemo-frontend/kubernetes/deployment.yaml ~/environment/eksdemo/templates/deployment/frontend.yaml
cp ~/environment/ecsdemo-frontend/kubernetes/service.yaml ~/environment/eksdemo/templates/service/frontend.yaml

# Copy and rename crystal manifests
cp ~/environment/ecsdemo-crystal/kubernetes/deployment.yaml ~/environment/eksdemo/templates/deployment/crystal.yaml
cp ~/environment/ecsdemo-crystal/kubernetes/service.yaml ~/environment/eksdemo/templates/service/crystal.yaml

# Copy and rename nodejs manifests
cp ~/environment/ecsdemo-nodejs/kubernetes/deployment.yaml ~/environment/eksdemo/templates/deployment/nodejs.yaml
cp ~/environment/ecsdemo-nodejs/kubernetes/service.yaml ~/environment/eksdemo/templates/service/nodejs.yaml
```

All files in the templates directory are sent through the template engine. These are currently plain YAML files that would be sent to Kubernetes as-is. Let's replace some of the values with `template directives` to enable more customization and start removing hard-coded values.

Open ~/environment/eksdemo/templates/deployment/frontend.yaml in your Cloud9 editor.
{{% notice info %}}
You will repeat these steps for **crystal.yaml** and **nodejs.yaml**
{{% /notice %}}
Under `spec`, find **replicas: 1**  and replace with the following:
```
replicas: {{ .Values.replica }}
```
Under `metadata`, replace **namespace: default** with the following:
```
namespace: {{ .Values.namespace }}
```
Under `spec.template.spec.containers.image`, replace the image with the correct template value from the table below:

|Filename | Value |
|---|---|
|frontend.yaml|image: {{ .Values.frontend.image }}:{{ .Values.version }}|
|crystal.yaml|image: {{ .Values.crystal.image }}:{{ .Values.version }}|
|nodejs.yaml|image: {{ .Values.nodejs.image }}:{{ .Values.version }}|

#### Create a values.yaml file with our template defaults

This file will populate our `template directives` with default values. 
```
cat <<EoF > ~/environment/eksdemo/values.yaml
# Default values for eksdemo.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# Release-wide Values
replica: 3
version: 'latest'

# Service Specific Values
nodejs:
  image: brentley/ecsdemo-nodejs
crystal:
  image: brentley/ecsdemo-crystal
frontend:
  image: brentley/ecsdemo-frontend
EoF
```

#### Use the dry-run flag to test our templates
The following command will build and output the rendered templates without installing the chart:
```sh
helm install --debug --dry-run --name workshop ~/environment/eksdemo
```
Confirm that the values created by the template look correct.

#### Deploy the chart
Now that we have tested our template, lets install it. 
```
helm install --name workshop ~/environment/eksdemo
```
#### Update demo application chart with a breaking change

Open **values.yaml** and modify the image name under `nodejs.image.repository` to **brentley/ecsdemo-nodejs-non-existing**. This image does not exist, so this will break our deployment. 

Deploy the updated demo application chart:
```sh
helm upgrade workshop ~/environment/eksdemo
```

The rolling upgrade will begin by creating a new nodejs pod with the new image. The new `ecsdemo-nodejs` Pod should fail to pull non-existing image. Run `helm status` command to see the `ImagePullBackOff` error:

```
helm status workshop
```

#### Rollback the failed upgrade

Now we are going to rollback the application to the previous working release revision.

First, list Helm release revisions:

```
helm history workshop
```

Then, rollback to the previous application revision (can rollback to any revision too):

```sh
# rollback to the 1st revision
helm rollback workshop 1
```

Validate `workshop` release status with:

```
helm status workshop
```