---
title: "Continuous Delivery with Spinnaker"
chapter: true
weight: 265
draft: false
tags:
  - intermediate
  - cd
  - spinnnaker
  - devops
---

# Continuous Delivery with Spinnaker
[Spinnaker](https://spinnaker.io/concepts/) is an open-source, multi-cloud continuous delivery platform, originally developed by Netflix, that helps you release software changes rapidly and reliably. Development team can focus on just application development and leave ops provisioning to Spinnaker for automating reinforcement of business and regulatory requirements. Spinnaker supports several CI systems and build tools like CodeBuild, Jenkins. You can integrate Spinnaker for configuring Artifacts from Git, Amazon S3, Amazon ECR etc.

In this workshop, we will focus on Application Deployment using Spinnaker:

1. How to install Spinnaker and configure Spinnaker services using Kubernetes Operator in EKS
2. Build simple Spinnaker CD pipeline
	- Stage - Add Ngnix deployment artifact manifest
	- Testing -
		- Manually trigger the pipeline
		- Test the deployment
3. Build Helm-based Spinnaker CD Pipeline
	- Configuration
	 	- Trigger: Continuous Delivery will be triggered automatically based on new image upload into ECR 
	- Stage 1 - Bake the manifest from GitHub repo for deployment using Helm
	- Stage 2 - Deploy the Helm artifact to EKS
	- Testing - 
		- Upload container image to ECR to trigger the deployment pipeline
		- Test the deployment 

![Spinnaker](/images/spinnnaker/architecture-s.png)


