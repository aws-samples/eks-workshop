---
title: "Kubeflow pipeline"
date: 2019-08-27T00:00:00-08:00
weight: 80
draft: false
---

### Kubeflow Pipelines

Kubeflow Pipeline is one the core components of the toolkit and gets deployed automatically when you install Kubeflow. Kubeflow Pipelines consists of:

* A user interface (UI) for managing and tracking experiments, jobs, and runs.
* An engine for scheduling multi-step ML workflows.
* An SDK for defining and manipulating pipelines and components.
* Notebooks for interacting with the system using the SDK.

[Amazon Sagemaker](https://aws.amazon.com/sagemaker/) is a managed service that enables data scientists and developers to quickly and easily build, train, and deploy machine learning models.

For this exercise, we will build Mnist classification pipeline using Amazon Sagemaker.

#### Assign IAM permissions

In order to run this exercise, we need three levels of IAM permissions. 1) create Kubernetes secrets **aws-secret** with Sagemaker policies. We'll use this during pipeline execution to make calls to AWS API's. 2) create an IAM execution role for Sagemaker so that the job can assume this role in order to perform Sagemaker actions. Typically in a production environment, you would assign fine-grained permissions depending on the nature of actions you take and leverage tools like [IAM Role for Service Account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) for securing access to AWS resources but for simplicity we will assign AmazonSageMakerFullAccess IAM policy to both. You can read more about granular policies [here](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html). 3) Assign sagemaker:InvokeEndpoint permission to Worker node IAM role so that we can use this to make predictions once Sagemaker creates the endpoint

Run this command from your Cloud9 to create these IAM permissions
```
aws iam create-user --user-name sagemakeruser
aws iam attach-user-policy --user-name sagemakeruser --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam create-access-key --user-name sagemakeruser > /tmp/create_output.json
```

Next, record the new user's credentials into environment variables:

```
export AWS_ACCESS_KEY_ID_VALUE=$(jq -j .AccessKey.AccessKeyId /tmp/create_output.json | base64)
export AWS_SECRET_ACCESS_KEY_VALUE=$(jq -j .AccessKey.SecretAccessKey /tmp/create_output.json | base64)
```

Apply to EKS cluster:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: kubeflow
type: Opaque
data:
  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID_VALUE
  AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY_VALUE
EOF
```

Run this command to create **Sagemaker execution role**
```
TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"Service\": \"sagemaker.amazonaws.com\" }, \"Action\": \"sts:AssumeRole\" } ] }"
aws iam create-role --role-name eksworkshop-sagemaker-kfp-role --assume-role-policy-document "$TRUST"
aws iam attach-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam get-role --role-name eksworkshop-sagemaker-kfp-role --output text --query 'Role.Arn'
```

At the end of the script, you will get the arn of IAM role generated. Make a note of this role as you will need it during pipeline creation step

Here is an example of the output
{{< output >}}
TeamRole:~/environment $ aws iam get-role --role-name eksworkshop-sagemaker-kfp-role --output text --query 'Role.Arn'
arn:aws:iam::371348455981:role/eksworkshop-sagemaker-kfp-role
{{< /output >}}
Lastly, let's assign sagemaker:InvokeEndpoint permission to Worker node IAM role

```
cat <<EoF > ~/environment/sagemaker-invoke.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": "*"
        }
    ]
}
EoF
aws iam put-role-policy --role-name $ROLE_NAME --policy-name sagemaker-invoke-for-worker --policy-document file://~/environment/sagemaker-invoke.json
```

#### Run Sagemaker pipeline notebook

Go to your **eks-kubeflow-workshop** notebook server and browse for Sagemaker pipeline notebook (eks-workshop-notebook/notebooks/05_Kubeflow_Pipeline/05_04_Pipeline_SageMaker.ipynb). If you haven't installed notebook server, review [fairing chapter](/advanced/420_kubeflow/fairing/#create-jupyter-notebook-server) and finish the [clone the repo](/advanced/420_kubeflow/fairing/#clone-the-repo) instructions.

Open Sagemaker pipeline notebook  
![dashboard](/images/kubeflow/pipelines-view-sagemaker-notebook.png)

{{% notice info %}}
Starting from here, its important to read notebook instructions carefully. The info provided in the workshop is lightweight and you can use it to ensure desired result. You can complete the exercise by staying in the notebook
{{% /notice %}}

Review the introduction and go through the prerequisites for 1) creating an S3 bucket and 2) copying the pipeline data. You can skip step 3 because you have already created Kubernetes secrets and Sagemaker execution role earlier. Continue with step 4 by installing Kubeflow pipeline SDK

Once all the prerequisites steps are completed, let's go through building our pipeline.

Run step 1 to load Kubeflow pipeline SDK. Once that is complete, run step 2 to load sagemaker components

Before you run step 3 - create pipeline, replace the value of SAGEMAKER_ROLE_ARN with Sagemaker execution role that we created during [Assign IAM permissions](/advanced/420_kubeflow/pipelines/#assign-iam-permissions)
![dashboard](/images/kubeflow/pipelines-sagemaker-execution-role.png)

After this, go and run next two steps to compile and deploy your pipelines

You will receive 2 links, one is for experiments and other is pipeline run.
![dashboard](/images/kubeflow/pipelines-deploy.png)

Click on **here** next to **Experiment link**.
![dashboard](/images/kubeflow/pipelines-sagemaker-experiment.png)

You can click on **View pipeline** to view details of the pipeline
![dashboard](/images/kubeflow/pipelines-sagemaker-overview.png)

You can click on **Experiments**, **All runs**, **mnist-classification-pipeline** to examine each steps in the pipeline. 
![dashboard](/images/kubeflow/pipelines-sagemaker-experiment-run.png)

Click on sagemaker training job and then click logs tab to see details
![dashboard](/images/kubeflow/pipelines-run-logs.png)

After few minutes you'll see the training job completes and then creates a model. After this step, batch transformation runs and then finally model is deployed using Sagemaker inference. Make a note of Sagemaker endpoint so that we can run prediction to validate our model
![dashboard](/images/kubeflow/pipelines-sagemaker-endpoint.png)

Now, let's run prediction against this endpoint. You can safely ignore the permissions note because we have already taken care of this earlier. Install boto3 and then change the endpoint name to the name you received in previous step
![dashboard](/images/kubeflow/pipelines-sagemaker-predictions.png)

You'll receive predictions as depicted above
