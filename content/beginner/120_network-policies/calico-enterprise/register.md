---
title: "Registration - GET ACCCESS TO CALICO ENTERPRISE TRIAL"
date: 2020-08-13T02:29:26-05:00
weight: 1
---

The team at Tigera offers a free access to [Calico Enterprise Edition](https://www.tigera.io/tigera-products/calico-enterprise) for all EKSWorkshop users. Follow the steps below to get your free trial to access Calico Enterprise and run it directly on your EKS cluster.

- Go to the Calico Enterprise trial registration website using [this](https://www.tigera.io/tigera-products/enterprise-trial) link . 

- Fill out your contact details along with your work email address to ensure you receive your trial environment details promptly.

- Select Amazon EKS as your Kubernetes distro. 

- For the Promo Code, please use **PAR-AWS-EKS-WORKSHOP**. It is critical for you to use this code as it is used to automatically approve trial requests for EKS Workshop Users.

- Review and accept the terms of service and click the START YOUR TRIAL button.

- Somebody from the Tigera team will provision your environment and send you an email with the details you need. This is currently a manual process and can take up to half an hour during business hours M-F 9 am - 5 pm PT. Requests received during non-business hours will be provisioned on the next business day.

- Once you receive the email titled "Your Calico Enterprise Trial Credentials" from cet@tigera.io ( make sure it's not going to your spam folder). You will be supplied with a single command to run against your existing EKS cluster. This command will automatically install the required Calico Enterprise components on your EKS cluster so you will be able to use a dedicated management portal to manage this cluster.

- You may follow the instructions provided in the email to register your EKS cluster and go through the advanced labs!


```
🐯 → curl -s https://tigera-installer.storage.googleapis.com/XXXXXXXX--management_install.sh | bash
[INFO] Checking for installed CNI Plugin
[INFO] Deploying CRDs and Tigera Operator
[INFO] Creating Tigera Pull Secret
[INFO] Tigera Operator is Available
[INFO] Adding Installation CR for Enterprise install
[WAIT] Tigera calico is Progressing
[INFO] Tigera Calico is Available
[INFO] Deploying Tigera Prometheus Operator
[INFO] Deploying CRs for Managed Cluster
[WAIT] Tigera apiserver is Progressing
[INFO] Tigera Apiserver is Available
[INFO] Generate New Cluster Registration Manifest
[INFO] Creating connection
[INFO] All Tigera Components are Available
[INFO] Securing Install

Your Connected Cluster Name is 
XXXXXXXX-us-west-2-eks-amazonaws-com

Your install was completed successfully. Below are your Calico Enterprise Credentials.

PORTAL URL: https://XXXXX-management.try.tigera.io

ACCESS TOKEN: XXXX
KIBANA USERNAME: elastic

KIBANA PASSWORD: XXXXXXXX
Lab Environment Access
  Endpoint: https://XXXXXXX.try.tigera.io:31500
  User: XXXXXXX
  Pass: XXXXXXX
```
