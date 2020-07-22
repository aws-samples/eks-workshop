---
title: "Setting up Jenkins master "
date: 2018-08-07T08:30:11-07:00
weight: 30
---

#### Install Jenkins

```
helm install cicd stable/jenkins --set rbac.create=true,master.servicePort=80,master.serviceType=LoadBalancer
```

The output of this command will give you some additional information such as the
`admin` password and the way to get the host name of the ELB that was
provisioned.

Let's give this some time to provision and while we do let's watch for Jenkins master pod
to boot.

```
kubectl get pods -w
```

You should see a pod that starts with the name **cicd-jenkins-** in `init`, `pending` or `running` state.

Once the pod status changes to `running`, we can get the load balancer address which will allow us to login to the Jenkins dashboard.

```
export SERVICE_IP=$(kubectl get svc --namespace default cicd-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Jenkins running at : http://$SERVICE_IP/login"
```

The expected result should be similar to:
```
http://a47cfc8b6f49411e9bb3c0a177920747-1075946478.eu-west-1.elb.amazonaws.com/login
```

{{% notice info %}}
This service was configured with a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/), so an [AWS Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) (ELB) is launched by Kubernetes for the service.
{{% /notice %}}

{{% notice tip %}}
It can take up to several minutes for the ELB to be created and DNS updated. During this time the link above may display a "site unreachable" message. To check if the instances are in service, follow this [deep link](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:tag:kubernetes.io/service-name=default/cicd-jenkins;sort=loadBalancerName) to the load balancer console. On the load balancer select the instances tab and ensure that the instance status is listed as "InService" before proceeding to the next page in the workshop. 
{{% /notice %}}


Open a new tab and browse to the address of the ELB that you got in the last step.

![Jenkins Login](/images/jenkinslogin.png)

From here we can log in using:

| Username | Password             |
|----------|----------------------|
| admin    | `command from below` |


```
printf $(kubectl get secret --namespace default cicd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

The output of this command will give you the default password for your `admin`
user. Log into the Jenkins login screen using these credentials. Make note of this password, because you will need to use it several times throughout the workshop.

Now that our Jenkins master is working, move to the next step in the workshop to set up Jenkins agents.
