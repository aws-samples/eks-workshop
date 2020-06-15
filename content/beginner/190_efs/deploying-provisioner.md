---
title: "Deploying the EFS Provisioner"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

Next, you will deploy the EFS Provisioner Pod and a PVC to the cluster. Download the YAML manifests for these resources by executing the following commands.
```
mkdir -p ~/environment/efs
cd ~/environment/efs
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-provisioner-deployment.yaml
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-pvc.yaml
```

Open the file **efs-provisioner-deployment.yaml** in an editor, scroll down to the bottom of the file and replace the following three placeholder strings with the respective values from your EFS file system settings. Do not change any of the other environment variables in the file.

- YOUR_FILE_SYSTEM_DNS_NAME
- YOUR_FILE_SYSTEM_ID 
- YOUR_FILE_SYSTEM_REGION

Deploy the provisioner pod and PVC with the following set of commands.
```
kubectl apply -f efs-provisioner-deployment.yaml
kubectl apply -f efs-pvc.yaml
```

Next, check if a PVC resource was created. The output from the command should look similar to what is shown below, with the **STATUS** field set to **Bound**.
```
kubectl get pvc -n storage
```
Output: 
{{< output >}}
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-storage-claim   Bound    pvc-8e470e71-5a24-11ea-9a37-0a95e5bfd098   1Mi        RWX            elastic        9s
{{< /output >}}

A PV corresponding to the above PVC is dynamically created. Check its status with the following command.
```
kubectl get pv
```
Output: 
{{< output >}}
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE
pvc-8e470e71-5a24-11ea-9a37-0a95e5bfd098   1Mi        RWX            Delete           Bound    storage/efs-storage-claim   elastic                 36s
{{< /output >}}


You may launch a command shell within the EFS Provisioner pod and inspect the local directory **/efs-mount**. Note that this is the directory within the pod on to which **/data** directory of the EFS file system was mounted.

Run the following set of commands to first get the name of the EFS Provisioner pod and then open up a command shell within the pod. Note that the pod name will be different in your environment.
```
kubectl get pods -n storage
```
```
kubectl exec -it efs-provisioner-849b6f77cb-rn9jb -n storage -- /bin/sh
```

At the command shell within the pod, run the following command.
```
ls -al /efs-mount
```
A sub-directory would have been created under **/efs-mount** to back the PV resource listed above. The name of this directory, which in this example is *efs-storage-claim-pvc-8e470e71-5a24-11ea-9a37-0a95e5bfd098*, is constructed based on the name and ID attributes of the corresponding PVC. Whenever a new instance of PVC is created, the EFS Provisioner will dynamically create a PV instance as well as create a child directory under **/data** directory of the EFS file system to back that PV. There is always a one-to-one correspondance between a PV and a PVC. 

Hit **Ctrl^D** to exit out of the pod back to your CLI.



