---
title: 'Testing the Application'
date: 2020-01-27T08:30:11-07:00
weight: 80
---

Now it's time to test.
![App Mesh](/images/app_mesh_fargate/meshify.png)

To test if our ported Product Catalog App is working as expected, we'll first exec into the `frontend-node` container.

```bash
export FE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=frontend-node -o jsonpath='{.items[].metadata.name}')

kubectl -n prodcatalog-ns exec -it ${FE_POD_NAME} -c frontend-node -- bash
```

You will see a prompt from within the `frontend-node` container.

{{< output >}}
root@frontend-node-9d46cb55-XXX:/usr/src/app#
{{< /output >}}

Test the confiuration by issuing a curl request to the virtual service `prodcatalog` on port 5000, simulating what would happen if code running in the same pod made a request to the `prodcatalog` backend:

```bash
curl -v http://prodcatalog.prodcatalog-ns.svc.cluster.local:5000/products/
```

Output should be similar to below. You can see that the request to backend service `prodcatalog` is going via envoy proxy.

```
* Trying 10.100.163.192...
* TCP_NODELAY set
* Connected to prodcatalog.prodcatalog-ns.svc.cluster.local (10.100.xx.yyy) port 5000 (#0)
> GET /products/ HTTP/1.1
> Host: prodcatalog.prodcatalog-ns.svc.cluster.local:5000
> User-Agent: curl/7.52.1
> Accept: */*
>
< HTTP/1.1 200 OK
< content-type: application/json
< content-length: 51
< x-amzn-trace-id: Root=1-600925c6-e2c7bec92b824ddc9969d1b5
< access-control-allow-origin: *
< server: envoy
< date: Thu, 21 Jan 2021 06:57:10 GMT
< x-envoy-upstream-service-time: 19
<
{
    "products": {},
    "details": {
        "version": "1",
        "vendors": [
            "ABC.com"
        ]
    }
}
* Curl_http_done: called premature == 0
* Connection #0 to host prodcatalog.prodcatalog-ns.svc.cluster.local left intact
```

Exit from the `frontend-node` exec bash.
Now, To test the connectivity from Fargate service `prodcatalog` to Nodegroup service `proddetail`, we'll first exec into the `prodcatalog` container.

```bash
export BE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=prodcatalog -o jsonpath='{.items[].metadata.name}')

kubectl -n prodcatalog-ns exec -it ${BE_POD_NAME} -c prodcatalog -- bash
```

You will see a prompt from within the `prodcatalog` container.

{{< output >}}
root@prodcatalog-9549fc7b9-7kg2j:/app#
{{< /output >}}

Test the confiuration by issuing a curl request to the virtual service proddetail on port 3000, simulating what would happen if code running in the same pod made a request to the proddetail backend:

```bash
curl -v http://proddetail.prodcatalog-ns.svc.cluster.local:3000/catalogDetail
```

You should see the below response. You can see that the request to backend service `proddetail-v1` is going via envoy proxy. You can exit now from the `prodcatalog` exec bash.

```
.....
.....
< HTTP/1.1 200 OK  
< content-type: application/json  
< content-length: 51  
< x-amzn-trace-id: Root=1-600925c6-e2c7bec92b824ddc9969d1b5  
< access-control-allow-origin: \*  
< server: envoy  
< date: Thu, 21 Jan 2021 06:57:10 GMT  
< x-envoy-upstream-service-time: 19
....
....
{"version":"1","vendors":["ABC.com"]}
```

Congrats! You've migrated the initial architecture to provide the same functionality. Now let's expose the frontend-node to external users to access the UI using App Mesh Virtual Gateway.
