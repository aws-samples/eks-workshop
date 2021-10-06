---
title: "Deploy Jenkins"
date: 2018-08-07T08:30:11-07:00
weight: 20
draft: false
---

### Install Jenkins

We'll begin by creating the `values.yaml` to declare the configuration of our Jenkins installation.

```bash
cat << EOF > values.yaml
---
controller:
  # Used for label app.kubernetes.io/component
  componentName: "jenkins-controller"
  image: "jenkins/jenkins"
  tag: "2.289.2-lts-jdk11"
  additionalPlugins:
    - aws-codecommit-jobs:0.3.0
    - aws-java-sdk:1.11.995
    - junit:1.51
    - ace-editor:1.1
    - workflow-support:3.8
    - pipeline-model-api:1.8.5
    - pipeline-model-definition:1.8.5
    - pipeline-model-extensions:1.8.5
    - workflow-job:2.41
    - credentials-binding:1.26
    - aws-credentials:1.29
    - credentials:2.5
    - lockable-resources:2.11
    - branch-api:2.6.4
  resources:
    requests:
      cpu: "1024m"
      memory: "4Gi"
    limits:
      cpu: "4096m"
      memory: "8Gi"
  javaOpts: "-Xms4000m -Xmx4000m"
  servicePort: 80
  serviceType: LoadBalancer
agent:
  Enabled: false
rbac:
  create: true
serviceAccount:
  create: false
  name: "jenkins"
EOF
```

Now we'll use the `helm` cli to create the Jenkins server as we've declared it in the `values.yaml` file.

```bash
helm install cicd stable/jenkins -f values.yaml
```

The output of this command will give you some additional information such as the
`admin` password and the way to get the host name of the ELB that was
provisioned.

Let's give this some time to provision and while we do let's watch for pods
to boot.

```bash
kubectl get pods -w
```

You should see the pods in `init`, `pending` or `running` state.

Once this changes to `running` we can get the `load balancer` address.

```bash
export SERVICE_IP=$(kubectl get svc --namespace default cicd-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")

echo http://$SERVICE_IP/login
```

{{% notice info %}}
This service was configured with a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/) so,
an [AWS Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) (ELB) is launched by Kubernetes for the service.
The EXTERNAL-IP column contains a value that ends with "elb.amazonaws.com" - the full value is the DNS address.
{{% /notice %}}

{{% notice tip %}}
When the front-end service is first deployed, it can take up to several minutes for the ELB to be created and DNS updated. During this time the link above may display a "site unreachable" message. To check if the instances are in service, follow this [deep link](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:tag:kubernetes.io/service-name=default/cicd-jenkins;sort=loadBalancerName) to the load balancer console. On the load balancer select the instances tab and ensure that the instance status is listed as "InService" before proceeding to the jenkins login page.
{{% /notice %}}
