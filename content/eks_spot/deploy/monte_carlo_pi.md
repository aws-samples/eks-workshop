---
title: "Monte Carlo Pi Template"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

## Monte Carlo Pi 

We will use this base configuration to deploy our application:

```
cat <<EoF > ~/environment/monte-carlo-pi-service.yml
---
apiVersion: v1 
kind: Service 
metadata: 
  name: monte-carlo-pi-service 
spec: 
  type: LoadBalancer 
  ports: 
    - port: 80 
      targetPort: 8080 
  selector: 
    app: monte-carlo-pi-service 
--- 
apiVersion: apps/v1 
kind: Deployment 
metadata: 
  name: monte-carlo-pi-service 
  labels: 
    app: monte-carlo-pi-service 
spec: 
  replicas: 2 
  selector: 
    matchLabels: 
      app: monte-carlo-pi-service 
  template: 
    metadata: 
      labels: 
        app: monte-carlo-pi-service 
    spec: 
      containers: 
        - name: monte-carlo-pi-service 
          image: ruecarlo/monte-carlo-pi-service
          resources: 
            requests: 
              memory: "512Mi" 
              cpu: "1024m" 
            limits: 
              memory: "512Mi" 
              cpu: "1024m" 
          securityContext: 
            privileged: false 
            readOnlyRootFilesystem: true 
            allowPrivilegeEscalation: false 
          ports: 
            - containerPort: 8080 

EoF

```

This should create a `monte-carlo-pi-service.yml` file that defines a **Service** and a **Deployment**. The configuration instructs the cluster to deploy two replicas of a pod with a single container, that sets up [Resource request and limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) to a fixed value 1vCPU and 512Mi of RAM. You can read more about the differences between Resource requests and limits [here](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html).

The deployment does not include any toleration or affinities. If deployed as is, it will be scheduled to the on-demand nodes that we created during the cluster creation phase!


{{% notice note %}}
There are a few best practices for managing multi-tenant dynamic clusters. One of those best practices is adding [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) such as the [ResourceQuota](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#resourcequota) and [LimitRanger](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#limitranger) admission controllers, both [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html)
{{% /notice %}}


Before we deploy our application and start scaling it, there are two requirements that we should apply and implement in the configuration file:

 1.- The first requirement is for the application to be deployed only on nodes that have been labeled with `intent: apps`
 
 2.- The second requirement is for the application to prefer Spot Instances over on-demand instances.


In the next section we will explore how to implement this requirements.




