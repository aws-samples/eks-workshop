---
title: "Fairing"
date: 2019-11-13T21:55:32-05:00
weight: 60
draft: false
---
### Kubeflow Fairing

Jupyter notebooks are a great way to author your model creation. You can write the algorithms, train the model and if you need a way to publish the inference endpoint directly from this interface, you can use Kubeflow fairing to do so

#### Assign ECR permissions

For this chapter, we will create a training image and store it in ECR. We need to add an IAM policy to Worker nodes so that we can write to ECR. Run below commands in Cloud9 and assign desired permission

```
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```

#### Create Jupyter notebook server
Create new notebook server by following [Jupyter notebook chapter] (/advanced/420_kubeflow/jupyter). Before you jump to the link, take a note of custom image (**seedjeffwan/tensorflow-1.13.1-notebook-cpu:awscli-v2**) that you will use for **eks-kubeflow-workshop** notebook server. Below screenshot depicts how to use custom image

![dashboard](/images/kubeflow/eks-kubeflow-workshop-notebook-server.png)

#### Clone the repo
We will clone Github repo from a Jupyter notebook so that we can readily use authored notebooks in this chapter.

Create new Python 3 Notebook if one doesn't exist. Run the command below to clone the repo

```
!git clone https://github.com/aws-samples/eks-kubeflow-workshop.git
```
Click Run. This will clone the repo into your notebook server

Close the notebook tab, go back to the notebook server, select the notebook that we just used and click **Shutdown**.

![dashboard](/images/kubeflow/fairing-shutdown-notebook.png)

#### Run fairing introduction notebook

Browse the **"eks-kubeflow-workshop"** repository and go to fairing introduction notebook (eks-kubeflow-workshop/notebooks/02_Fairing/02_01_fairing_introduction.ipynb). You can either click on the notebook to open or select and click **View**

![dashboard](/images/kubeflow/fairing-view-introduction-notebook.png)

{{% notice info %}}
Starting from here, its important to read notebook instructions carefully. The info provided in the workshop is lightweight and you can use it to ensure desired result. You can complete the exercise by staying in the notebook
{{% /notice %}}

Review the content and click first cell and click **Run**. This will let you install Fairing from Github repository

Wait till it finishes, go to next cell and click **Run**. Here is expected result
![dashboard](/images/kubeflow/fairing-install-from-github.png)

Now that we have fairing installed, we will train a model authored in Python. The model will create a linear regression model that allows us to learn a function or relationship from a given set of continuous data. For example, we are given some data points of x and corresponding y and we need to learn the relationship between them that is called a hypothesis.

In case of linear regression, the hypothesis is a straight line i.e, h(x) = x * weight + b.

Run cell 3. Once it completes, run cell 4. This will create a model locally on our notebook
![dashboard](/images/kubeflow/fairing-train-locally.png)

Now, lets use fairing and push the image into ECR which can be used for remote training

Before you run authenticate with ECR, change the region if needed. Run this cell and login so that you can perform ECR operations

Run the next cell and create an ECR repository (fairing-job) in the same region. You should see similar output
![dashboard](/images/kubeflow/fairing-create-ecr-repo.png)

Let's run next cell. Fairing pushes the image to ECR and then deploys the model remotely

![dashboard](/images/kubeflow/fairing-remote-job.png)

Now that we have demonstrated how to use Fairing to train locally and remotely, let's train and deploy XGBoost model and review an end to end implementation

#### Run fairing end to end deployment notebook 

For this exercise, we will use another notebook called **02_06_fairing_e2e.ipynb**

Go back to your notebook server and shutdown 02_01_fairing_introduction.ipynb notebook. Open the **02_06_fairing_e2e.ipynb**

Let's install python dependencies by running first 2 cells, and then run next 2 cells under "Develop your model"

Run the next cell to train the XGBoost model locally. Here is the expected result
![dashboard](/images/kubeflow/fairing-xgboost-local.png)

Now lets create an S3 bucket to store pipeline data. Remember to change HASH to a random value before running next cell

Running next two steps will setup Fairing backend. Remember to change S3 bucket name before running next cell

Now lets submit the Trainjob. Here is the expected result
![dashboard](/images/kubeflow/fairing-xgboost-remote.png)

Running next step will deploy prediction endpoint using Fairing. You will endpoint details at the bottom.
![dashboard](/images/kubeflow/fairing-deploy-prediction.png)

Let's call this prediction endpoint. Remember to replace <endpoint> with your endpoint before running next two cells
![dashboard](/images/kubeflow/fairing-call-prediction.png)

This demonstrates how to build XGBoost model using Fairing and deploy it locally and to remote endpoint.

Run the next steps to cleanup resources from this exercise
