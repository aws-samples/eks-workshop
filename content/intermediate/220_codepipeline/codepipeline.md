---
title: "CodePipeline Setup"
date: 2018-10-087T08:30:11-07:00
weight: 14
draft: false
---

Now we are going to create the AWS CodePipeline using [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

CloudFormation is an [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_Code) (IaC) tool which
provides a common language for you to describe and provision all the infrastructure resources in your cloud environment.
CloudFormation allows you to use a simple text file to model and provision, in an automated and secure manner, all the
resources needed for your applications across all regions and accounts.

Each EKS deployment/service should have its own CodePipeline and be located in an isolated source repository.

You can modify the CloudFormation templates provided with this workshop to meet your system requirements to easily
onboard new services to your EKS cluster. For each new service the following steps can be repeated.

Click the **Launch** button to create the CloudFormation stack in the AWS Management Console.

| Launch template |  |  |
| ------ |:------:|:--------:|
| CodePipeline & EKS |  {{< cf-launch "ci-cd-codepipeline.cfn.yml" "eksws-codepipeline" >}} | {{< cf-download "ci-cd-codepipeline.cfn.yml" >}}  |

After the console is open, enter your GitHub username, personal access token (created in previous step), check the acknowledge box and then click the "Create stack" button located at the bottom of the page.

![CloudFormation Stack](/images/codepipeline/cloudformation_stack.png)

Wait for the status to change from "CREATE_IN_PROGRESS" to **CREATE_COMPLETE** before moving on to the next step.

![CloudFormation Stack](/images/codepipeline/cloudformation_stack_creating.png)

Open [CodePipeline in the Management Console](https://console.aws.amazon.com/codesuite/codepipeline/pipelines). You will see a CodePipeline that starts with **eks-workshop-codepipeline**.
Click this link to view the details.

{{% notice tip %}}
If you receive a permissions error similar to **User x is not authorized to perform: codepipeline:ListPipelines...** upon clicking the above link, the CodePipeline console may have opened up in the wrong region.  To correct this, from the **Region** dropdown in the console, choose the region you provisioned the workshop in.  Select Oregon (us-west-2) if you provisioned the workshow per the "Start the workshop at an AWS event" instructions.
{{% /notice %}}


![CodePipeline Landing](/images/codepipeline/codepipeline_landing.png)

Once you are on the detail page for the specific CodePipeline, you can see the status along with links to the change and build details.

![CodePipeline Details](/images/codepipeline/codepipeline_details.png)

{{% notice tip %}}
If you click on the "details" link in the build/deploy stage, you can see the output from the CodeBuild process.
{{% /notice %}}

To review the status of the deployment, you can run:

```
kubectl describe deployment hello-k8s
```

For the status of the service, run the following command:

```
kubectl describe service hello-k8s
```

#### Challenge:
**How can we view our exposed service?**

**HINT:** Which kubectl command will get you the Elastic Load Balancer (ELB) endpoint for this app?

 {{%expand "Expand here to see the solution" %}}

 Once the service is built and delivered, we can run the following command to get the Elastic Load Balancer (ELB) endpoint and open it in a browser.
 If the message is not updated immediately, give Kubernetes some time to deploy the change.

 ```
 kubectl get services hello-k8s -o wide
 ```

{{% notice info %}}
This service was configured with a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/) so,
an [AWS Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) is launched by Kubernetes for the service.
The EXTERNAL-IP column contains a value that ends with "elb.amazonaws.com" - the full value is the DNS address.
{{% /notice %}}
{{% /expand %}}
