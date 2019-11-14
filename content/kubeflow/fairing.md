---
title: "Fairing"
date: 2019-11-13T21:55:32-05:00
weight: 60
draft: false
---
### Kubeflow Fairing

Jupyter notebooks are a great way to author your model creation. You can write the algorithms, train the model and if you need a way to publish the inference endpoint directly from this interface, you can use Kubeflow fairing to do so

#### Create Jupyter notebook server
Create new notebook server by following [Jupyter notebook chapter] (/kubeflow/jupyter). Before you jump to the link, take a note of custom image (**seedjeffwan/tensorflow-1.13.1-notebook-cpu:awscli-v2**) that you will use for fairing notebook server. Below screenshot depicts how to use custom image

![dashboard](/images/kubeflow/fairing-custom-notebook-server.png)

#### Clone the repo
We will clone Github repo from a Jupyter notebook so that we can readily use authored notebooks in this chapter.

Create new Python 3 Notebook if one doesn't exist. Run the command below to clone the repo

```
!git clone https://github.com/aws-samples/eks-kubeflow-workshop.git
```
Click Run. This will clone the repo into your notebook server

Close the notebook tab, go back to the notebook server, select the notebook that we just used and click **Shutdown**.

![dashboard](/images/kubeflow/fairing-shutdown-notebook.png)

Browse the "eks-kubeflow-workshop" repository and go to fairing introduction notebook. You can either click on the notebook to open or select and click **View**

![dashboard](/images/kubeflow/fairing-view-introduction-notebook.png)

Review the content and click first cell and click **Run**. This will let you install Fairing from Github repository

Wait till it finishes, go to next cell and click **Run**. Here is expected result
![dashboard](/images/kubeflow/fairing-install-from-github.png)

Now that we have fairing installed, we will train a model authored in Python. **The model is for**
Run cell 3. Once it completes, run cell 4. This will create a model locally on our notebook
![dashboard](/images/kubeflow/fairing-train-locally.png)
