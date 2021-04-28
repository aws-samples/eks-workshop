---
title: "Pods Deployments"
date: 2020-12-02T23:37:35-05:00
draft: false
weight: 50
tags:
  - beginner
---

### Kubernetes secrets

Before deploying our two pods we need to provide them with the RDS endpoint and password.
We will create a kubernetes secret.

```bash
export RDS_PASSWORD=$(cat ~/environment/sg-per-pod/rds_password)

export RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier rds-eksworkshop \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

kubectl create secret generic rds\
    --namespace=sg-per-pod \
    --from-literal="password=${RDS_PASSWORD}" \
    --from-literal="host=${RDS_ENDPOINT}"

kubectl -n sg-per-pod describe  secret rds
```

Output

{{< output >}}
Name:         rds
Namespace:    sg-per-pod
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
host:      56 bytes
password:  32 bytes
{{< /output >}}

### Deployments

Let's download both pods deployment files

```bash
cd ~/environment/sg-per-pod

curl -s -O https://www.eksworkshop.com/beginner/115_sg-per-pod/deployments.files/green-pod.yaml
curl -s -O https://www.eksworkshop.com/beginner/115_sg-per-pod/deployments.files/red-pod.yaml
```

Take some time to explore both YAML files and see the different between the two.

![sg-per-pod_5](/images/sg-per-pod/sg-per-pod_5.png)

#### Green Pod

Now let's deploy the green pod

```bash
kubectl -n sg-per-pod apply -f ~/environment/sg-per-pod/green-pod.yaml

kubectl -n sg-per-pod rollout status deployment green-pod
```

The container will try to:

* Connect to the database and will output the content of a table to _STDOUT_.
* If the database connection failed, the error message will also be outputted to _STDOUT_.

Let's verify the logs.

```bash
export GREEN_POD_NAME=$(kubectl -n sg-per-pod get pods -l app=green-pod -o jsonpath='{.items[].metadata.name}')

kubectl -n sg-per-pod  logs -f ${GREEN_POD_NAME}
```

Output

{{% output %}}
[('--------------------------',), ('Welcome to the eksworkshop',), ('--------------------------',)]
[('--------------------------',), ('Welcome to the eksworkshop',), ('--------------------------',)]
{{% /output %}}

{{% notice note %}}
use _CTRL+C_ to exit the log
{{% /notice %}}

As we can see, our attempt was successful!

Now let's verify that:

* An ENI is attached to the pod.
* And the ENI has the security group POD_SG attached to it.

We can find the ENI ID in the pod `Annotations` section using this command.

```bash
kubectl -n sg-per-pod  describe pod $GREEN_POD_NAME | head -11
```

Output

{{< output >}}
Name:         green-pod-5c786d8dff-4kmvc
Namespace:    sg-per-pod
Priority:     0
Node:         ip-192-168-33-222.us-east-2.compute.internal/192.168.33.222
Start Time:   Thu, 03 Dec 2020 05:25:54 +0000
Labels:       app=green-pod
              pod-template-hash=5c786d8dff
Annotations:  kubernetes.io/psp: eks.privileged
              vpc.amazonaws.com/pod-eni:
                [{"eniId":"eni-0d8a3a3a7f2eb57ab","ifAddress":"06:20:0d:3c:5f:bc","privateIp":"192.168.47.64","vlanId":1,"subnetCidr":"192.168.32.0/19"}]
Status:       Running
{{< /output >}}

You can verify that the security group POD_SG is attached to the `eni` shown above by opening this [link](https://console.aws.amazon.com/ec2/home?#NIC:search=POD_SG).

![sg-per-pod_6](/images/sg-per-pod/sg-per-pod_6.png)

### Red Pod

We will deploy the red pod and verify that it's unable to connect to the database.

Just like for the green pod, the container will try to:

* Connect to the database and will output to _STDOUT_ the content of a table.
* If the database connection failed, the error message will also be outputted to _STDOUT_.

```bash
kubectl -n sg-per-pod apply -f ~/environment/sg-per-pod/red-pod.yaml

kubectl -n sg-per-pod rollout status deployment red-pod
```

Let's verify the logs (use _CTRL+C_ to exit the log)

```bash
export RED_POD_MAME=$(kubectl -n sg-per-pod get pods -l app=red-pod -o jsonpath='{.items[].metadata.name}')

kubectl -n sg-per-pod  logs -f ${RED_POD_MAME}
```

Output

{{< output >}}
Database connection failed due to timeout expired
{{< /output >}}

Finally let's verify that the pod doesn't have an _enitId_ `annotation`.

```bash
kubectl -n sg-per-pod  describe pod ${RED_POD_MAME} | head -11
```

Output

{{< output >}}
Name:         red-pod-7f68d78475-vlm77
Namespace:    sg-per-pod
Priority:     0
Node:         ip-192-168-6-158.us-east-2.compute.internal/192.168.6.158
Start Time:   Thu, 03 Dec 2020 07:08:28 +0000
Labels:       app=red-pod
              pod-template-hash=7f68d78475
Annotations:  kubernetes.io/psp: eks.privileged
Status:       Running
IP:           192.168.0.188
IPs:
{{< /output >}}

### Conclusion

In this module, we configured our EKS cluster to enable the security groups per pod feature.

We created a `SecurityGroup` Policy and deployed 2 pods (using the same docker image) and a RDS Database protected by a Security Group.

Based on this policy, only one of the two pods was able to connect to the database.

Finally using the CLI and the AWS console, we were able to locate the pod's ENI and verify that the Security Group was attached to it.
