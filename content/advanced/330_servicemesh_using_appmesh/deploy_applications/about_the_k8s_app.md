---
title: "About Product Catalog Application"
date: 2020-01-27T08:30:11-07:00
weight: 30
---

#### Application Architecture

The example application architecture we'll walk you through creating on App Mesh is called `Product Catalog` and is used in any eCommerce Application. We have attempted to pick different technology framework for building applications to include the polyglot nature of microservices-based applications.

This application is composed of three microservices:

![Product Catalog App without App Mesh](/images/app_mesh_fargate/no-appmesh-arch.png)

* Frontend
    * Frontend service `frontend-node` shows the UI for the Product Catalog functionality
    * Developed in Nodejs with ejs templating
    * Deployed to `EKS Managed Nodegroup`
* Product Catalog Backend
    * Backend service `prodcatalog` is a Rest API Service that performs following operations:
        * Add a Product into Product Catalog
        * Get the Product from the Product Catalog
        * Calls Catalog Detail backend service `proddetail` to get Product Catalog Detail information like vendors
        * Get all the products from the Product Catalog
{{< output >}}
/products

{
    "products": {
        "1": "Table",
        "2": "Chair"
    },
    "details": {
        "version": "2",
        "vendors": [
            "ABC.com",
            "XYZ.com"
        ]
    }
}
{{< /output >}}
    * Developed in Python Flask Restplus with Swagger UI for Rest API
    * Deployed to `EKS Fargate`
* Catalog Detail Backend
    * Backend service `proddetail` is a Rest API Service that performs following operation:
        * Get catalog detail which includes version number and vendor names
{{< output >}}
/catalogDetail

{
    "version": "2",
    "vendors": [
        "ABC.com",
        "XYZ.com"
    ]
}
{{< /output >}}
    * Developed in Nodejs
    * Deployed to `EKS Managed Nodegroup`


From the above diagram, the service-call relationship between the services in `Product Catalog` application can be summarized as:

* Frontend `frontend-node` >>>>> calls >>>>> Product Catalog backend `prodcatalog`.
* Product Catalog backend `prodcatalog` >>>>> calls >>>>> Catalog Detail backend `proddetail`.

