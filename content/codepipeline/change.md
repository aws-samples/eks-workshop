---
title: "Trigger New Release"
date: 2018-10-087T08:30:11-07:00
weight: 15
draft: false
---

So far we have walked through setting up CI/CD for EKS using AWS CodePipeline and now we are going to
make a change to the GitHub repository so that we can see a new release built and delivered.

Open [GitHub](https://github.com/) and select the forked repository with the name **eks-workshop-sample-api-service-go**.

Click on **main.go** file and then click on the **edit** button, which looks like a pencil.

![GitHub Edit](/images/codepipeline/github_edit.png)

Change the text where it says "Hello World", add a commit message and then click the "Commit changes" button.

You should leave the master branch selected.

{{% notice info %}}
The main.go application needs to be compiled, so please ensure that you don't accidentally break the build :)
{{% /notice %}}


![GitHub Modify](/images/codepipeline/github_modify.png)

After you modify and commit your change in GitHub, in approximately one minute you will see a new build triggered in the [AWS Management Console](https://console.aws.amazon.com/codesuite/codepipeline/pipelines)

![CodePiepline Running](/images/codepipeline/codepipeline_building.png)

#### Challenge:
**How can we validate the changes and access latest version of the app?**
 {{%expand "Expand here to see the solution" %}}

 Once the service is built and delivered, we can run the following command to get the Elastic Load Balancer (ELB) endpoint and open it in a browser.
 If the message is not updated immediately, give Kubernetes some time to deploy the change.

 ```
 kubectl get services hello-k8s -o wide
 ```

The EXTERNAL-IP column contains a value that ends with "elb.amazonaws.com" - the full value is the DNS record which can be used to validate/access the app.

{{% /expand %}}
