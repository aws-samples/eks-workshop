---
title: "Create AMG workspace"
date: 2021-01-21T22:47:19-05:00
draft: false
weight: 50
---

#### Prerequisites

AMG requires AWS SSO enabled in your account. AWS SSO is used as the authentication provider to sign into the AMG workspace.

##### Follow the steps below to enable AWS SSO in your account:

- Sign in to the AWS Management Console with your AWS Organizations management account credentials.
- Open the [AWS SSO console](https://console.aws.amazon.com/singlesignon).
- Click `Enable AWS SSO`.

> If you have not yet set up AWS Organizations, you will be prompted to create an organization. Click the `Create AWS organization` button to complete this process.

- Create a new AWS SSO user. (We will use this user to provide access to the AMG workspace later.)

#### Create AMG workspace

1. In the AWS Management Console on the Services menu, click `Amazon Grafana`.
2. Click `Create workspace`.
3. Enter `demo-amg` as the workspace name and click `Next`.

![Create AMG workspace](/images/amg/amg1.png)

4. Select `Service managed` for the `Permission type`, then click `Next`. 

> Selecting this option allows the wizard to automatically provision the permissions for you based on the AWS services we will choose later on.

> From the `Service managed permission settings` screen, you can choose to configure Grafana to monitor resources in the same account that you are creating the workspace from or allow Grafana to reach into multiple AWS accounts by choosing the `Organization` option and providing the necessary OU IDs. 

![Configure accounts](/images/amg/amg2.png)

5. Leave `Current account` selected.
6. Select all the Data sources and the Notification channels, then click `Next`.

![Review amg screen](/images/amg/amg3.png)

7. In the Review screen, take a look at the options and click on `Create workspace`.

#### Add Users

8. Once the AMG workspace turns to `ACTIVE`, click on `Assign user` and select the SSO user created in previously. Click `Assign user`.

![Assign user](/images/amg/amg4.png)

9. Select the user under `Users` and select `Make admin`.

> By default, all newly assigned users are added as `Viewers` that only provides read-only permissions on Grafana. After completing this step you should see that the user is now an Administrator.

![Assign user](/images/amg/amg5.png)

This concludes this section. You may continue on to the next section.


