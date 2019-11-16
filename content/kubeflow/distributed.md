---
title: "Kubeflow Distributed Training"
date: 2019-11-15T00:00:00-08:00
weight: 70
draft: false
---

### Distributed Training using tf-operator and pytorch-operator

`TFJob` is a Kubernetes [custom resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that you can use to run TensorFlow training jobs on Kubernetes. The Kubeflow implementation of TFJob is in [tf-operator](https://github.com/kubeflow/tf-operator). Similarly, you can create PyTorch Job by defining a `PyTorchJob` config file and [pytorch-operator](https://github.com/kubeflow/pytorch-operator) will help create PyTorch job, monitor and keep track of the job.

You can open following notebook to go over basic concepts of distributed training. In addition, we prepare `distributed-tensorflow-job.yaml` and `distributed-pytorch-job.yaml` for you to run distributed training jobs on EKS. You can follow guidance to check job specs, create the jobs and monitor the jobs

![dashboard](/images/kubeflow/distributed-training-notebook.png)

