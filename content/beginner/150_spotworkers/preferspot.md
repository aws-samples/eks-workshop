---
title: "Deploy an Application on Spot"
date: 2018-09-18T17:40:09-05:00
weight: 30
draft: false
---

We are redesigning our Microservice example and want our frontend service to be deployed on Spot Instances when they are available. We will use Node Affinity in our manifest file to configure this.

#### Configure Node Affinity and Tolerations

Open the deployment manifest in your Cloud9 editor - **~/environment/ecsdemo-frontend/kubernetes/deployment.yaml**

Edit the spec to configure NodeAffinity to **prefer** Spot Instances, but not **require** them. This will allow the pods to be scheduled on On-Demand nodes if no spot instances were available or correctly labelled.

We also want to configure a toleration which will allow the pods to "tolerate" the taint that we configured on our EC2 Spot Instances.

For examples of Node Affinity, check this [**link**](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity)

For examples of Taints and Tolerations, check this [**link**](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)

#### Challenge

**Configure Affinity and Toleration**

{{% expand "Expand here to see the solution"%}}
Add this to your deployment file under spec.template.spec

```yaml
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: lifecycle
                operator: In
                values:
                - Ec2Spot
      tolerations:
      - key: "spotInstance"
        operator: "Equal"
        value: "true"
        effect: "PreferNoSchedule"
```

{{% notice tip %}}
 We have provided a solution file below that you can use to compare.
{{% /notice %}}

{{% /expand %}}

{{%attachments title="Related files" pattern=".yml"/%}}

#### Redeploy the Frontend on Spot

First let's take a look at all pods deployed on Spot instances

```bash
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do echo "Pods on instance ${n}:";kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} ; echo ; done
```

Now we will redeploy  our microservices with our edited Frontend Manifest

```bash
cd ~/environment/ecsdemo-frontend
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-crystal
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/deployment.yaml

cd ~/environment/ecsdemo-nodejs
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/deployment.yaml
```

We can again check all pods deployed on Spot Instances and should now see the frontend pods running on Spot instances

```bash
 for n in $(kubectl get nodes -l lifecycle=Ec2Spot --no-headers | cut -d " " -f1); do echo "Pods on instance ${n}:";kubectl get pods --all-namespaces  --no-headers --field-selector spec.nodeName=${n} ; echo ; done
```