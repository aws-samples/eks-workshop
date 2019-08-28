---
title: "Model training"
date: 2019-08-27T00:00:00-08:00
weight: 40
draft: false
---

### Model Training

While Jupyter notebook is good for interactive model training, you may like to package the training code as Docker image and run it in Amazon EKS cluster.

This chapter explains how to build a training model for [Fashion-MNIST](https://github.com/zalandoresearch/fashion-mnist) dataset using TensorFlow and Keras on Amazon EKS. This databset contains 70,000 grayscale images in 10 categories and is meant to be a drop-in replace of [MNIST](https://en.wikipedia.org/wiki/MNIST_database).

#### Docker image

You can use a pre-built Docker image `seedjeffwan/mnist_tensorflow_keras:1.13.1`. This image uses `tensorflow/tensorflow:1.13.1` as the base image. The image has training code and downloads training and test data sets. It also stores the generated model in an S3 bucket.

Alternatively, you can build a Docker image using the Dockerfile in `Dockerfile` to build it:

```
docker build -t <dockerhub_username>/<repo_name>:<tag_name> .
```

#### Create S3 bucket

Create an S3 bucket where training model will be saved:

```
aws s3 mb s3://<bucket-name>
```

This name will be used in the pod specification later.

This bucket is also used for serving the model.


#### Setup AWS credentials in EKS cluster

AWS credentials are required to save model on S3 bucket. These credentials are stored in EKS cluster as Kubernetes secrets.

Get your AWS access key id and secret access key.

Replace `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the following command with values specific to your environment.

```
export AWS_ACCESS_KEY_ID_VALUE=$(echo -n 'AWS_ACCESS_KEY_ID' | base64)
export AWS_SECRET_ACCESS_KEY_VALUE=$(echo -n 'AWS_SECRET_ACCESS_KEY' | base64)
```

Apply to EKS cluster:

```
curl 
envsubst <aws-secrets.yaml | kubectl -n kubeflow apply -f
```

#### Create Kubernetes Job

Now, create the pod:

```
kubectl create -f samples/mnist/training/tensorflow/mnist_train.yaml
```

This will start the pod which will start the training and generate model in the S3 bucket. Check status:

```
kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
mnist-tensorflow   1/1     Running   0          47s
```
