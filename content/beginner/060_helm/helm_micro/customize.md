---
title: "Customize Defaults"
date: 2018-08-07T08:30:11-07:00
weight: 20
---

If you look in the newly created **eksdemo** directory, you'll see several files and directories.

The table below outlines the purpose of each component in the Helm chart structure.
| File or Directory | Description |
| ------ | ----------- |
| charts/   | Sub-charts that the chart depends on |
| Chart.yaml | Information about your chart |
| values.yaml | The default values for your templates |
| template/    | The template files |
| template/deployment.yaml | Basic manifest for creating [Kubernetes Deployment objects](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) |
| template/_helpers.tpl | Used to define Go template helpers |
| template/hpa.yaml | Basic manifest for creating [Kubernetes Horizontal Pod Autoscaler objects](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| template/ingress.yaml | Basic manifest for creating [Kubernetes Ingress objects](https://kubernetes.io/docs/concepts/services-networking/ingress/) |
| template/NOTES.txt | A plain text file to give users detailed information about how to use the newly installed chart |
| template/serviceaccount.yaml | Basic manifest for creating [Kubernetes ServiceAccount objects](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) |
| template/service.yaml | Basic manifest for creating [Kubernetes Service objects](https://kubernetes.io/docs/concepts/services-networking/service/) |
| tests/ | Directory of Test files |
| tests/test-connections.yaml | Tests that validate that your chart works as expected when it is installed |

We're actually going to create our own files, so we'll delete these boilerplate files

```sh
rm -rf ~/environment/eksdemo/templates/
rm ~/environment/eksdemo/Chart.yaml
rm ~/environment/eksdemo/values.yaml
```

Run the following code block to create a new Chart.yaml file which will describe the chart

```sh
cat <<EoF > ~/environment/eksdemo/Chart.yaml
apiVersion: v2
name: eksdemo
description: A Helm chart for EKS Workshop Microservices application
version: 0.1.0
appVersion: 1.0
EoF
```

Next we'll copy the manifest files for each of our microservices into the templates directory as *servicename*.yaml

```sh
#create subfolders for each template type
mkdir -p ~/environment/eksdemo/templates/deployment
mkdir -p ~/environment/eksdemo/templates/service

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

All files in the templates directory are sent through the template engine. These are currently plain YAML files that would be sent to Kubernetes as-is.

## Replace hard-coded values with template directives
Let's replace some of the values with `template directives` to enable more customization by removing hard-coded values.

Open ~/environment/eksdemo/templates/deployment/frontend.yaml in your Cloud9 editor.

{{% notice info %}}
The following steps should be completed seperately for **frontend.yaml**, **crystal.yaml**, and **nodejs.yaml**.
{{% /notice %}}

Under `spec`, find **replicas: 1**  and replace with the following:

```yaml
replicas: {{ .Values.replicas }}
```

Under `spec.template.spec.containers.image`, replace the image with the correct template value from the table below:

|Filename | Value |
|---|---|
|frontend.yaml|- image: {{ .Values.frontend.image }}:{{ .Values.version }}|
|crystal.yaml|- image: {{ .Values.crystal.image }}:{{ .Values.version }}|
|nodejs.yaml|- image: {{ .Values.nodejs.image }}:{{ .Values.version }}|

#### Create a values.yaml file with our template defaults

Run the following code block to populate our `template directives` with default values.

```sh
cat <<EoF > ~/environment/eksdemo/values.yaml
# Default values for eksdemo.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# Release-wide Values
replicas: 3
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
