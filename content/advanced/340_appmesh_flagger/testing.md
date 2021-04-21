---
title: "Testing Canary Deployment"
date: 2021-03-18T00:00:00-05:00
weight: 50
draft: false
---

#### Automated Canary Promotion

According to the [Flagger](https://docs.flagger.app/tutorials/appmesh-progressive-delivery#automated-canary-promotion) documentation, canary deployment is triggered by changes in any of the following objects:

- Deployment PodSpec (container image, command, ports, env, resources, etc).
- ConfigMaps and Secrets mounted as volumes or mapped to environment variables

We will trigger a canary deployment by updating the container image of `detail` service to **version 2**. Flagger will detect changes to the target deployment and will perform a canary analysis before promoting the new version as primary.

```bash
export APP_VERSION_2=2.0
kubectl -n flagger set image deployment/detail detail=public.ecr.aws/u2g6w7p2/eks-microservice-demo/detail:${APP_VERSION_2}
```
{{< output >}}
deployment.apps/detail image updated
{{< /output >}}

Flagger detects that the deployment revision changed and starts a new rollout. You can see the log events for this deployment

```bash 
kubectl -n appmesh-system logs deploy/flagger --tail 10  -f | jq .msg 
```

{{< output >}}
"New revision detected! Scaling up detail.flagger"
"Starting canary analysis for detail.flagger"
"Pre-rollout check acceptance-test passed"
"Advance detail.flagger canary weight 5"
"Advance detail.flagger canary weight 10"
"Advance detail.flagger canary weight 15"
"Copying detail.flagger template spec to detail-primary.flagger"
"Routing all traffic to primary"
"Promotion completed! Scaling down detail.flagger"
{{< /output >}}

You can also check the events using the below command
```bash
kubectl describe canary detail -n  flagger
```

{{< output >}}
  Normal   Synced  5m38s                flagger  New revision detected! Scaling up detail.flagger
  Normal   Synced  4m38s                flagger  Starting canary analysis for detail.flagger
  Normal   Synced  4m38s                flagger  Pre-rollout check acceptance-test passed
  Normal   Synced  4m38s                flagger  Advance detail.flagger canary weight 5
  Normal   Synced  3m38s                flagger  Advance detail.flagger canary weight 10
  Normal   Synced  2m38s                flagger  Advance detail.prodcatalog-ns canary weight 15
  Normal   Synced  13s (x2 over 73s)    flagger  (combined from similar events): Copying detail.flagger template spec to detail-primary.flagger
  Normal   Synced  7s (x3 over 2m7s)  flagger  (combined from similar events): Routing all traffic to primary
  Normal   Synced  14s (x4 over 3m14s)  flagger  (combined from similar events): Promotion completed! Scaling down detail.flagger
{{< /output >}}

When the canary analysis starts, Flagger will call the pre-rollout webhooks before routing traffic to the canary.
**Note** that if you apply new changes to the deployment during the canary analysis, Flagger will restart the analysis.

Go to the LoadBalancer endpoint in browser and verify if new **version 2** has been deployed. 
![version2](/images/app_mesh_flagger/version2.png)

#### Automated Rollback

We will create the scenario for automated rollback. During the canary analysis we will generate HTTP 500 errors to test if Flagger pauses the rollout.

Trigger a canary deployment by updating the container image of `detail` service to **version 3**:

```bash
export APP_VERSION_3=3.0
kubectl -n flagger set image deployment/detail detail=public.ecr.aws/u2g6w7p2/eks-microservice-demo/detail:${APP_VERSION_3}
```
{{< output >}}
deployment.apps/detail image updated
{{< /output >}}

Once the canary analysis starts, you see the below message
```bash
kubectl -n appmesh-system logs deploy/flagger --tail 10  -f | jq .msg
```
{{< output >}}
"New revision detected! Scaling up detail.flagger"
"Starting canary analysis for detail.flagger"
{{< /output >}}

Exec into the loadtester pod
```bash
kubectl -n flagger exec -it deploy/flagger-loadtester bash
```
{{< output >}}  
Defaulting container name to loadtester.
Use 'kubectl describe pod/flagger-loadtester-5bdf76cfb7-wl59d -n flagger' to see all of the containers in this pod.
bash-5.0$ 
{{< /output >}}

Generate HTTP 500 errors from `http://detail-canary.flagger:3000/catalogDetail`

```bash
curl http://detail-canary.flagger:3000/injectFault
hey -z 1m -c 5 -q 5 http://detail-canary.flagger:3000/catalogDetail
```

When the number of failed checks reaches the canary analysis threshold which we have set as 1 in our setup, the traffic is routed back to the primary, the canary is scaled to zero and the rollout is marked as failed.

```bash
kubectl -n appmesh-system logs deploy/flagger --tail 10  -f | jq .msg
```

{{< output >}}
"New revision detected! Scaling up detail.flagger"
"Starting canary analysis for detail.flagger"
"Pre-rollout check acceptance-test passed"
"Advance detail.flagger canary weight 5"
"Halt detail.flagger advancement success rate 23.03% < 99%"
"Rolling back detail.flagger failed checks threshold reached 1"
"Canary failed! Scaling down detail.flagger"
{{< /output >}}

Go to the LoadBalancer endpoint in browser and you will still see **version 2** and version 3 did **not** get deployed. 
![rollback](/images/app_mesh_flagger/version2.png)

#### Redeploy Version 3 again

Lets deploy the **version 3** again, this time without injecting errors. 

As per the [Flagger FAQ](https://docs.flagger.app/faq#how-to-retry-a-failed-release) you can set an update to an annotation so that flagger knows to retry the release. 
The canary that failed has already been updated to the new image **version 3**, which is why setting the image version to the same value a second time will have no effect. So we need to update the annotation of the pod spec, which will then trigger a new canary progressing which is what we will be doing using below yaml.

```bash
export APP_VERSION_3=3.0
envsubst < ./flagger/flagger-app_noerror.yaml | kubectl apply -f -
```
{{< output >}}
deployment.apps/detail configured
{{< /output >}}

Flagger detects that the deployment revision changed and starts a new rollout:

```bash
kubectl -n appmesh-system logs deploy/flagger --tail 10  -f | jq .msg
```

{{< output >}}
"New revision detected! Scaling up detail.flagger"
"Starting canary analysis for detail.flagger"
"Pre-rollout check acceptance-test passed"
"Advance detail.flagger canary weight 5"
"Advance detail.flagger canary weight 10"
"Advance detail.flagger canary weight 15"
"Advance detail.flagger canary weight 20"
"Copying detail.flagger template spec to detail-primary.flagger"
"Routing all traffic to primary"
"Promotion completed! Scaling down detail.flagger"
{{< /output >}}

Go to the LoadBalancer endpoint in browser and verify if new **version 3** has been deployed.
![version3](/images/app_mesh_flagger/version3.png)

#### X-Ray tracing

You can log into console and go to X-Ray and you should able to see the tracing between different services as well as the track a specific service flow

![trace](/images/app_mesh_flagger/traceview.png)

![map](/images/app_mesh_flagger/mapview.png)

