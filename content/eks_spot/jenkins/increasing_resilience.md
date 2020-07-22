---
title: "Increasing resilience"
date: 2018-08-07T08:30:11-07:00
weight: 60
---


#### Increasing resilience: Automatic Jenkins job retries
We can configure Jenkins to automatically retry running jobs in case of failures. One possible failure would be when a Jenkins agent is running a job on an EC2 Spot Instance that is going to be terminated due to an EC2 Spot Interruption, when EC2 needs the capacity back. To configure automatic retries for jobs, follow these steps:

1. In the Jenkins dashboard, browse to **Manage Jenkins** -> **Manage Plugins** -> **Available** tab
2. In the filter field, enter **Naginator**. [Click here] (https://wiki.jenkins.io/display/JENKINS/Naginator+Plugin) to learn more about this plugin in the Jenkins website.
3. Check the box next to the Naginator result and click **Install without restart**
4. In the next page, check the box next to **Restart Jenkins when installation is complete and no jobs are running box**


{{% notice note %}}
The Naginator plugin, and automatic retries in general, might not be a good fit for your Jenkins jobs or for the way that your organization does CI/CD. It is included in this workshop for educational purposes and for demonstrating increased resilience to handle Spot Instance interruptions. For more complex retries in Jenkins pipelines, look into the [Jenkins Job DSL] (https://github.com/jenkinsci/job-dsl-plugin/wiki/Tutorial---Using-the-Jenkins-Job-DSL)
{{% /notice %}}

Wait for Jenkins to finish restarting, login to the dashboard again, and continue to the next step in the workshop.
