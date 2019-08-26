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

This pre-populates the namespace field on the dashboard. Specify a name **myjupyter** for the notebook and change the CPU value to **1.0**:

![dashboard](/images/kubeflow/jupyter-name-cpu.png)

Scroll to the bottom, take all other defaults, and click on **LAUNCH**.

It takes a few seconds for the Jupyter notebook to come online. Click on **CONNECT**

![dashboard](/images/kubeflow/jupyter-notebook-servers.png)

This connects to the notebook and opens the notebook interface in a new browser tab.

![dashboard](/images/kubeflow/jupyter-new-notebook.png)

CLick on **New**, select **Python3**

![dashboard](/images/kubeflow/jupyter-new-python3-notebook.png)

