---
title: "Setup CloudWatch Alarm"
chapter: false
weight: 3
---
#### Setup CloudWatch Alarm

In this section, we will setup CloudWatch alarm and send notification using SNS when a Pod restarts more than once in a 5 minute period.

##### Steps

* Navigate to [CloudWatch Alarms](https://console.aws.amazon.com/cloudwatch/home#alarmsV2:)
* Click on **Create alarm**
* In the **Specify metric conditions screen** click **Select metric**
* Select **Container Insights** and then **ClusterName, Namespace, PodName**.
* Then check the **pod_number_of_container_restarts** metric as shown below

![Container Insights](/images/ContainerInsights7.png)

* Click **Select metric**
* In the **Specify metric and conditions** screen, change the statistic to **Sum**
* Enter **1** in the **Define the threshold value** textbox. Click **Next**
* In the **Configure actions** screen, ensure **in Alarm** is selected and select **Select an existing SNS topic** if you have an SNS topic already in your account you want to use for this purpose. If not, select **Create new topic**

![Container Insights](/images/ContainerInsights8.png)

* Click on **Create topic** and then click **Next**
* In the **Add a description** screen, enter the alarm name as **Pod Restart Count** and click **Next**

![Container Insights](/images/ContainerInsights10.png)

* Review the details in the following screen and click **Create alarm**

##### Trigger the alarm

Get the name of the **ecsdemo-frontend** pod using the following command

```
kubectl get pods

NAME                                READY   STATUS    RESTARTS   AGE
ecsdemo-crystal-6b45547688-tzvw2    1/1     Running   0          8d
ecsdemo-frontend-7f7644d5d5-tk72w   1/1     Running   3          8d
ecsdemo-nodejs-744d497fdc-9hwgz     1/1     Running   0          8d

```

Kill the pod using the following command after replacing the placeholder string with the name of the ecsdemo-frontend pod obtained from the command above. 
Wait for the pod to restart, and then kill it again. Do all this within 5 minutes so the alarm can be triggered.

```
kubectl exec -it <NAME_OF_THE_ECSDEMO_FRONT_END_POD> -c ecsdemo-frontend -- /bin/sh -c "kill 1"
```

##### Check alarm status
Navigate to [CloudWatch Alarms](https://console.aws.amazon.com/cloudwatch/home#alarmsV2:) page and you should be able to see the alarm firing off as shown below
![Container Insights](/images/ContainerInsights17.png)

If your email is subscribed to the SNS topic, you will also see an email notification as shown below
![Container Insights](/images/ContainerInsights16.png)