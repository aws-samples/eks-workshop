---
title: "About Canary Analysis"
date: 2021-03-18T00:00:00-05:00
weight: 20
draft: false
---

Before we start the canary deployment setup, lets learn more about the canary analysis and how it works in Flagger.

#### Canary Resource

[Flagger](https://docs.flagger.app/) can be configured to automate the release process for Kubernetes workloads with a custom resource named canary which we installed in the previous chapter. 
The canary custom resource defines the release process of an application running on Kubernetes. 

We have defined the canary release with progressive traffic shifting for the deployment of backend service `detail` [here](https://github.com/aws-containers/eks-microservice-demo/blob/main/flagger/flagger-canary.yaml).

When we deploy a new version of `detail` backend service, Flagger gradually shifts traffic to the canary, and at the same time, measures the requests success rate as well as the average response duration.

#### Canary Target

Below is one of the section from Canary Resource for canary target for `detail` service. For more details, see Flagger documentation [here](https://docs.flagger.app/usage/how-it-works#canary-target).

{{< output >}}  
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: detail
  progressDeadlineSeconds: 60
{{< /output >}}

Based on the above configuration, Flagger generates deployment/detail-primary Kubernetes object during canary analysis. This primary deployment is considered the stable release of our `detail` service, by default all traffic is routed to this version and the target deployment is scaled to zero. Flagger will detect changes to the target deployment (including secrets and configmaps) and will perform a canary analysis before promoting the new version as primary.

The progress deadline represents the maximum time in seconds for the canary deployment to make progress before it is rolled back, defaults to ten minutes.

#### Canary Service

Below canary service section from Canary Resource dictates how the target workload is exposed inside the cluster. The canary target should expose a TCP port that will be used by Flagger to create the ClusterIP Services. For more details, see Flagger documentation [here](https://docs.flagger.app/usage/how-it-works#canary-service).

{{< output >}}  
  service:
    # container port
    port: 3000
{{< /output >}}

Based on our [canary spec](https://github.com/aws-containers/eks-microservice-demo/blob/main/flagger/flagger-canary.yaml) service, Flagger creates the following Kubernetes ClusterIP service
* `detail.flagger.svc.cluster.local`
  
  selector `app=detail-primary`
* `detail-primary.flagger.svc.cluster.local`

  selector `app=detail-primary`
* `detail-canary.flagger.svc.cluster.local`

  selector `app=detail`

This ensures that traffic to `detail.flagger:3000` will be routed to the latest stable release of our `detail` service. The `detail-canary.flagger:3000` address is available only during the canary analysis and can be used for conformance testing or load testing.


#### Canary Analysis

The canary analysis defines:
* the type of [deployment strategy](https://docs.flagger.app/usage/deployment-strategies) 
  * Canary Release
  * A/B Testing
  * Blue/Green Deployment
* the [metrics](https://docs.flagger.app/usage/metrics) used to validate the canary version. Flagger comes with two builtin metric checks: 
  * HTTP request success rate and duration
  * HTTP request success duration
* the [webhooks](https://docs.flagger.app/usage/webhooks) used for acceptance test, load testing, etc
* the [alerting](https://docs.flagger.app/usage/alerting) settings
  * Flagger can be configured to send Slack notifications:

The canary analysis runs periodically until it reaches the maximum traffic weight or the number of iterations. On each run, Flagger calls the [webhooks](https://docs.flagger.app/usage/webhooks), checks the metrics and if the failed checks threshold is reached, stops the analysis and rolls back the canary. For more details, see Flagger documentation [here](https://docs.flagger.app/usage/how-it-works#canary-analysis).

For the canary analyis of `detail` service, we have used the below setup. 
* We are checking the failed metrics for every iteration of canary analysis. If the request-success-rate metrics is below 99% or if the latency is greater than 500ms (which means the number of failures reach the threshold which is "1" in our setup), then canary analysis will fail and will rollback.
* We have pre-rollout webhook for running acceptance-test that are executed before routing traffic to canary. The canary advancement is paused if the pre-rollout hook fails and the canary will rollback.
* We also have rollout hook for load-test that are executed during the analysis on each iteration before the metric checks. If a rollout hook call fails; the canary advancement is paused and eventfully rolled back.


{{< output >}}  
  # define the canary analysis timing and KPIs
  analysis:
    # schedule interval (default 60s)
    interval: 1m
    # max number of failed metric checks before rollback
    threshold: 1
    # max traffic percentage routed to canary
    # percentage (0-100)
    maxWeight: 15
    # canary increment step
    # percentage (0-100)
    stepWeight: 5
    # App Mesh Prometheus checks
    metrics:
      - name: request-success-rate
        # minimum req success rate (non 5xx responses)
        # percentage (0-100)
        thresholdRange:
          min: 99
        interval: 1m
      - name: request-duration
        # maximum req duration P99
        # milliseconds
        thresholdRange:
          max: 500
        interval: 30s
    # testing (optional)
    webhooks:
      - name: acceptance-test
        type: pre-rollout
        url: http://flagger-loadtester.flagger/
        timeout: 30s
        metadata:
          type: bash
          cmd: 'curl -s http://detail-canary.flagger:3000/ping | grep "Healthy"'
      - name: "load test"
        type: rollout
        url: http://flagger-loadtester.flagger/
        timeout: 15s
        metadata:
          cmd: "hey -z 1m -q 5 -c 2 http://detail-canary.flagger:3000/ping"
{{< /output >}}

#### Canary Status

Get the current status of canary deployments in our cluster:

```bash
kubectl get canaries --all-namespaces
```
{{< output >}}  
NAMESPACE   NAME     STATUS      WEIGHT   LASTTRANSITIONTIME
flagger     detail   Succeeded   0        2021-03-23T05:16:21Z
{{< /output >}}

The status condition reflects the last known state of the canary analysis:

{{< output >}} 
kubectl -n flagger get canary/detail -oyaml | awk '/status/,0'
{{< /output >}}

{{< output >}}  
status:
  canaryWeight: 0
  conditions:
  - lastTransitionTime: "2021-03-23T05:16:21Z"
    lastUpdateTime: "2021-03-23T05:16:21Z"
    message: Canary analysis completed successfully, promotion finished.
    reason: Succeeded
    status: "True"
    type: Promoted
  failedChecks: 0
  iterations: 0
  lastAppliedSpec: 75cf74bc9b
  lastTransitionTime: "2021-03-23T05:16:21Z"
  phase: Succeeded
  trackedConfigs: {}
{{< /output >}}

The Promoted status condition can have one of the following reasons: 
* Initialized
* Waiting
* Progressing
* Promoting
* Finalising
* Succeeded
* Failed

A failed canary will have the promoted status set to false, the reason to failed and the last applied spec will be different to the last promoted one.

{{< output >}}  
status:
  canaryWeight: 0
  conditions:
  - lastTransitionTime: "2021-03-24T01:07:21Z"
    lastUpdateTime: "2021-03-24T01:07:21Z"
    message: Canary analysis failed, Deployment scaled to zero.
    reason: Failed
    status: "False"
    type: Promoted
  failedChecks: 0
  iterations: 0
  lastAppliedSpec: 6d5749b74f
  lastTransitionTime: "2021-03-24T01:07:21Z"
  phase: Failed
  trackedConfigs: {}
{{< /output >}}

Now lets deploy the app and canary analysis setup and see this in action!
