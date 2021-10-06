---
title: "Test the Application"
date: 2020-01-27T08:30:11-07:00
weight: 70
---

#### Testing the Connectivity between Fargate and Nodegroup pods
 
To test if our ported Product Catalog App is working as expected, we'll first exec into the `frontend-node` container.

```bash
export FE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=frontend-node -o jsonpath='{.items[].metadata.name}') 

kubectl -n prodcatalog-ns exec -it ${FE_POD_NAME} -c frontend-node bash
```

You will see a prompt from within the `frontend-node` container.

{{< output >}}
root@frontend-node-9d46cb55-XXX:/usr/src/app#
{{< /output >}}

curl to Fargate `prodcatalog` backend endpoint and you should see the below response

```bash
curl http://prodcatalog.prodcatalog-ns.svc.cluster.local:5000/products/ 
```
{{< output >}}
{
    "products": {},
    "details": {
        "version": "1",
        "vendors": [
            "ABC.com"
        ]
    }
}
{{< /output >}}

Exit from the `frontend-node` container exec bash. Now, To test the connectivity from Fargate service `prodcatalog` to Nodegroup service `proddetail`, we'll first exec into the `prodcatalog` container.

```bash
export BE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=prodcatalog -o jsonpath='{.items[].metadata.name}') 

kubectl -n prodcatalog-ns exec -it ${BE_POD_NAME} -c prodcatalog bash
```
You will see a prompt from within the `prodcatalog` container.

{{< output >}}
root@prodcatalog-98f7c5f87-xxxxx:/usr/src/app#
{{< /output >}}
curl to Nodegroup `proddetail` backend endpoint and you should see the below response. You can now exit from `prodcatalog` exec bash.
```bash
curl http://proddetail.prodcatalog-ns.svc.cluster.local:3000/catalogDetail
```
{{< output >}}
{"version":"1","vendors":["ABC.com"]}
{{< /output >}}


Congratulations on deploying the initial Product Catalog Application architecture!  

Before we create the App Mesh-enabled versions of Product Catalog App, we'll first install the `AWS App Mesh Controller for Kubernetes` into our cluster.

