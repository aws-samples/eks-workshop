---
title: "Jupyter Notebook"
date: 2019-08-26T00:00:00-08:00
weight: 30
draft: false
---

### Jupyter Notebook using Kubeflow on Amazon EKS

[The Jupyter Notebook](https://jupyter.org/) is an open-source web application that allows you to create and share documents that contain live code, equations, visualizations and narrative text. It is often used for data cleaning and transformation, numerical simulation, statistical modeling, data visualization, machine learning, and more.

In Kubeflow dashboard, click on **Create a new Notebook server**:

![dashboard](/images/kubeflow/dashboard-new-notebook-server.png)

Select the namespace created in previous step:

![dashboard](/images/kubeflow/jupyter-select-namespace.png)

This pre-populates the namespace field on the dashboard. Specify a name **myjupyter** for the notebook:

![dashboard](/images/kubeflow/jupyter-enter-notebook-server-name.png)

In the Image section, select the latest **tensorflow-1.x** image whose name ends
in **cpu** (not gpu) from the dropbown box:

![dashboard](/images/kubeflow/jupyter-select-image.png)

Change the CPU value to **1.0**:

![dashboard](/images/kubeflow/jupyter-select-cpu.png)

Scroll to the bottom, take all other defaults, and click on **LAUNCH**.

It takes a few seconds for the Jupyter notebook to come online. Click on **CONNECT**

![dashboard](/images/kubeflow/jupyter-notebook-servers.png)

This connects to the notebook and opens the notebook interface in a new browser tab.

![dashboard](/images/kubeflow/jupyter-new-notebook.png)

CLick on **New**, select **Python3**

![dashboard](/images/kubeflow/jupyter-new-python3-notebook.png)

This creates an empty Python 3 Jupyter notebook

![dashboard](/images/kubeflow/jupyter-empty-notebook.png)

Copy the [sample training code](/advanced/420_kubeflow/kubeflow.files/mnist-tensorflow-jupyter.py) and paste it in the first code block. This Python sample code uses TensorFlow to create a training model for MNIST database. Click on **Run** to load this code in notebook.

![dashboard](/images/kubeflow/jupyter-mnist-code.png)

This also creates a new code block. Copy `main()` in this new code block and click on **Run** again

![dashboard](/images/kubeflow/jupyter-mnist-code-main.png)

This starts the model training and the output is shown on the notebook:

![dashboard](/images/kubeflow/jupyter-mnist-training.png)

The first few lines shows that TensorFlow and Keras dataset is downloaded. Training data set is 60k images and test data set is 10k images. Hyperparameters used for the training, outputs from five epochs, and finally the model accuracy is shown.
