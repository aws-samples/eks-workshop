---
title: "Deploy the eksdemo Chart"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

#### Use the dry-run flag to test our templates

To test the syntax and validity of the Chart without actually deploying it, we'll use the dry-run flag.

The following command will build and output the rendered templates without installing the Chart:

```sh
helm install --debug --dry-run --name workshop ~/environment/eksdemo
```
Confirm that the values created by the template look correct.


#### Deploy the chart
Now that we have tested our template, lets install it.

```
helm install --name workshop ~/environment/eksdemo
```

Similar to what we saw previously in the [NGINX Helm Chart example](/helm_root/helm_nginx/index.html), an output of the Deployment, Pod, and Service objects are output, similar to:

```
NAME:   workshop
LAST DEPLOYED: Fri Nov 16 21:42:00 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME              AGE
ecsdemo-crystal   0s
ecsdemo-frontend  0s
ecsdemo-nodejs    0s

==> v1/Deployment
ecsdemo-crystal   0s
ecsdemo-frontend  0s
ecsdemo-nodejs    0s

==> v1/Pod(related)

NAME                               READY  STATUS             RESTARTS  AGE
ecsdemo-crystal-764b9cb9bc-4dwqt   0/1    ContainerCreating  0         0s
ecsdemo-crystal-764b9cb9bc-hcb62   0/1    ContainerCreating  0         0s
ecsdemo-crystal-764b9cb9bc-vl7nr   0/1    ContainerCreating  0         0s
ecsdemo-frontend-67876457f6-2xrtb  0/1    ContainerCreating  0         0s
ecsdemo-frontend-67876457f6-bfnc5  0/1    ContainerCreating  0         0s
ecsdemo-frontend-67876457f6-rb6rg  0/1    ContainerCreating  0         0s
ecsdemo-nodejs-c458bf55d-994cq     0/1    ContainerCreating  0         0s
ecsdemo-nodejs-c458bf55d-9qtbm     0/1    ContainerCreating  0         0s
ecsdemo-nodejs-c458bf55d-s9zkh     0/1    ContainerCreating  0         0s

```
