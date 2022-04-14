---
title: "Porting Product Catalog to App Mesh"
date: 2020-01-27T08:30:11-07:00
weight: 30
draft: false
---

#### Challenge

Today, Product Catalog frontend `frontend-node` is hardwired to make requests to `prodcatalog` and `prodcatalog` is hardwired to make requests to `proddetail`.

Each time there is a new version of `proddetail` release, we also need to release a new version of `prodcatalog` to support both the new and the old version to point to its version-specific endpoints. It works, but it's not an optimal configuration to maintain for the long term.  

`prodcatalog` backend service is deployed to Fargate, and rest of the services `frontend-node` and `proddetail` are deployed to Managed Nodegroup, we need to add all these services into the App Mesh and ensure these microservices can communicate with each other.

#### Solution

We're going to demonstrate how `AWS App Mesh` can be used to simplify this architecture; by virtualizing the `proddetail` service, we can add dynamic configuration and route traffic to the versioned endpoints of our choosing, minimizing the need for complete re-deployment of the `prodcatalog` service each time there is a new `proddetail` service release.  

We're also going to demonstrate how all the microservices in Nodegroup and Fargate can communicate with each other via App Mesh. 

When we're done with porting the application in this chapter, our app will look more like the following.

![Product Catalog App with App Mesh](/images/app_mesh_fargate/appmeshv1-1.png)

Now that the App Mesh Controller and CRDs are installed, we're ready to define the App Mesh components required for our mesh-enabled version of the app.
