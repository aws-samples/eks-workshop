---
title: "Deploy Sample Pod"
date: 2021-07-20T00:00:00-03:00
weight: 50
draft: false
---

Now that we have completed all the necessary configuration, we will run two kubernetes [jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) with the newly created IAM role:

* **job-s3.yaml**: that will output the result of the command `aws s3 ls` (this job should be successful).
* **job-ec2.yaml**: that will output the result of the command `aws ec2 describe-instances --region ${AWS_REGION}` (this job should failed).

Before deploying the workloads, make sure to have the environment variables `AWS_REGION` and `ACCOUNT_ID` configured in your terminal prompt.

### List S3 buckets

Let's start by testing if the service account can list the S3 buckets

```bash
mkdir ~/environment/irsa

cat <<EoF> ~/environment/irsa/job-s3.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: eks-iam-test-s3
spec:
  template:
    metadata:
      labels:
        app: eks-iam-test-s3
    spec:
      serviceAccountName: iam-test
      containers:
      - name: eks-iam-test
        image: amazon/aws-cli:latest
        args: ["s3", "ls"]
      restartPolicy: Never
EoF

kubectl apply -f ~/environment/irsa/job-s3.yaml
```

Make sure your job is **completed**.

```bash
kubectl get job -l app=eks-iam-test-s3
```

Output:
{{< output >}}
NAME              COMPLETIONS   DURATION   AGE
eks-iam-test-s3   1/1           2s         21m
{{< /output >}}

Let's check the logs to verify that the command ran successfully.

```bash
kubectl logs -l app=eks-iam-test-s3
```

Output:
{{< output >}}
2021-07-17 20:09:41 eksworkshop-eksctl-helm-charts
2021-07-18 19:22:37 eksworkshop-logs
{{< /output >}}

{{% notice info %}}
If the output lists some buckets, please move on to [**List EC2 Instances**](#list-ec2-instances). If not, it is possible your account doesn't have any s3 buckets. Please try to run theses extra commands.
{{% /notice %}}

Let's create an S3 bucket.

```bash
aws s3 mb s3://eksworkshop-$ACCOUNT_ID-$AWS_REGION --region $AWS_REGION
```

Output:
{{< output >}}
make_bucket: eksworkshop-40XXXXXXXX75-us-east-1
{{< /output >}}

Now, let's try that job again. But first, we should remove the old job.

```bash
kubectl delete job -l app=eks-iam-test-s3
```

Then we can re-create the job.

```bash
kubectl apply -f ~/environment/irsa/job-s3.yaml
```

Finally, we can have a look at the output.

```bash
kubectl logs -l app=eks-iam-test-s3
```

Output:
{{< output >}}
2021-07-21 14:06:24 eksworkshop-40XXXXXXXX75-us-east-1
{{< /output >}}

### List EC2 Instances

Now Let's confirm that the service account cannot list the EC2 instances

```bash
cat <<EoF> ~/environment/irsa/job-ec2.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: eks-iam-test-ec2
spec:
  template:
    metadata:
      labels:
        app: eks-iam-test-ec2
    spec:
      serviceAccountName: iam-test
      containers:
      - name: eks-iam-test
        image: amazon/aws-cli:latest
        args: ["ec2", "describe-instances", "--region", "${AWS_REGION}"]
      restartPolicy: Never
  backoffLimit: 0
EoF

kubectl apply -f ~/environment/irsa/job-ec2.yaml
```

Let's verify the job status

```bash
kubectl get job -l app=eks-iam-test-ec2
```

Output:
{{< output >}}
NAME               COMPLETIONS   DURATION   AGE
eks-iam-test-ec2   0/1           39s        39s
{{< /output >}}

{{% notice info %}}
It is normal that the job didn't complete succesfuly.
{{% /notice %}}

Finally we will review the logs

```bash
kubectl logs -l app=eks-iam-test-ec2
```

Output:
{{< output >}}
An error occurred (UnauthorizedOperation) when calling the DescribeInstances operation: You are not authorized to perform this operation.
{{< /output >}}
