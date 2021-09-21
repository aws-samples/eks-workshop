---
title: "Deploying the Stateful Services"
date: 2021-08-10T00:00:00-03:00
weight: 14
draft: false
---

#### Deploy a Kubernetes storage class, persistent volume claim, and sample application to verify that the CSI driver is working

This procedure uses the Dynamic volume provisioning for Amazon S3 from the Amazon FSx for Lustre Container Storage Interface (CSI) driver GitHub repository to consume a dynamically-provisioned Amazon FSx for Lustre volume.

1. Create an Amazon S3 bucket and a folder within it named export by creating and copying a file to the bucket.
    ```
    aws s3 mb s3://$S3_LOGS_BUCKET
    echo test-file >> testfile
    aws s3 cp testfile s3://$S3_LOGS_BUCKET/export/testfile
    ```


2. Create the storageclass definition that should interpolate variables from your shell variables that we defined in on the previous page.
    ```
    cat << EOF > storageclass.yaml
    ---
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
        name: fsx-sc
    provisioner: fsx.csi.aws.com
    parameters:
        subnetId: ${SUBNET_ID}
        securityGroupIds: ${SECURITY_GROUP_ID}
        s3ImportPath: s3://${S3_LOGS_BUCKET}
        s3ExportPath: s3://${S3_LOGS_BUCKET}/export
        deploymentType: SCRATCH_2
    mountOptions:
        - flock
    EOF
    ```

    Explanation of the settings:

    - **subnetId** – The subnet ID that the Amazon FSx for Lustre file system should be created in. Amazon FSx for Lustre is not supported in all Availability Zones. Open the Amazon FSx for Lustre console at https://console.aws.amazon.com/fsx/ to confirm that the subnet that you want to use is in a supported Availability Zone. The subnet can include your nodes, or can be a different subnet or VPC. If the subnet that you specify is not the same subnet that you have nodes in, then your VPCs must be connected, and you must ensure that you have the necessary ports open in your security groups.

    - **securityGroupIds** – The security group ID for your nodes.

    - **s3ImportPath** – The Amazon Simple Storage Service data repository that you want to copy data from to the persistent volume.

    - **s3ExportPath** – The Amazon S3 data repository that you want to export new or modified files to. 

    - **deploymentType** – The file system deployment type. Valid values are SCRATCH_1, SCRATCH_2, and PERSISTENT_1. For more information about deployment types, see Create your Amazon FSx for Lustre file system.

        **Note**

        The Amazon S3 bucket for s3ImportPath and s3ExportPath must be the same, otherwise the driver cannot create the Amazon FSx for Lustre file system. The s3ImportPath can stand alone. A random path will be created automatically like s3://ml-training-data-000/FSxLustre20190308T012310Z. The s3ExportPath cannot be used without specifying a value for S3ImportPath.

3. Create the storageclass.
    ```
    kubectl apply -f storageclass.yaml
    ```
4. Download the persistent volume claim manifest.
    ```
    curl -o claim.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/examples/kubernetes/dynamic_provisioning_s3/specs/claim.yaml
    ```
    **(Optional)** Edit the claim.yaml file. Change the following <value> to one of the increment values listed below, based on your storage requirements and the deploymentType that you selected in a previous step.

    ```
    storage: <1200Gi>
    ```

        - SCRATCH_2 and PERSISTENT – 1.2 TiB, 2.4 TiB, or increments of 2.4 TiB over 2.4 TiB.

        - SCRATCH_1 – 1.2 TiB, 2.4 TiB, 3.6 TiB, or increments of 3.6 TiB over 3.6 TiB.

5. Create the persistent volume claim.

    ```
    kubectl apply -f claim.yaml
    ```

6. Confirm that the file system is provisioned.
    ```
    kubectl get pvc
    ```

    **Output:**

    ```
    NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    fsx-claim   Bound    pvc-15dad3c1-2365-11ea-a836-02468c18769e   1200Gi     RWX            fsx-sc         7m37s
    ```

    *The STATUS may show as Pending for 5-10 minutes, before changing to Bound. Don't continue with the next step until the STATUS is Bound.*

7. Deploy the sample application.

    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/examples/kubernetes/dynamic_provisioning_s3/specs/pod.yaml
    ```

8. Verify that the sample application is running.

    ```
        kubectl get pods
    ```
        **Output:**
    ```
        NAME      READY   STATUS              RESTARTS   AGE
        fsx-app   1/1     Running             0          8s
    ```

#### Access Amazon S3 files from the Amazon FSx for Lustre file system

1. If you only want to import data and read it without any modification and creation, then you don't need a value for s3ExportPath in your storageclass.yaml file. Verify that data was written to the Amazon FSx for Lustre file system by the sample app.

    ```
    kubectl exec fsx-app -- ls /data
    ```

    **Output:**
    
    The sample app wrote the out.txt file to the file system.

    ```
    export  
    out.txt
    ```

2. Archive files to the s3ExportPath. For new files and modified files, you can use the Lustre user space tool to archive the data back to Amazon S3 using the value that you specified for s3ExportPath.

    Export the file back to Amazon S3.

    ```
    kubectl exec -ti fsx-app -- lfs hsm_archive /data/out.txt
    ```

    New files aren't synced back to Amazon S3 automatically. In order to sync files to the s3ExportPath, you need to install the Lustre client in your container image and manually run the lfs hsm_archive command. The container should run in privileged mode with the CAP_SYS_ADMIN capability.
    This example uses a lifecycle hook to install the Lustre client for demonstration purpose. A normal approach is building a container image with the Lustre client.

3. Confirm that the out.txt file was written to the s3ExportPath folder in Amazon S3.

    ```
    aws s3 ls s3://$S3_LOGS_BUCKET/export/
    ```

    **Output:**

    ```
    2021-08-10 12:11:35       4553 out.txt
    2021-08-10 11:41:21         10 testfile
    ```
