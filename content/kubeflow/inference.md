---
title: "Model inference"
date: 2019-09-03T00:00:00-08:00
weight: 50
draft: true
---

### Model Inference

After the model is trained and stored in S3 bucket, the next step is to use that model for inference.

This chapter explains how to use the previously created training model and provide inference using TensorFlow and Keras on Amazon EKS.

#### Run inference pod

A model from training was stored in the S3 bucket in previous section. Make sure `S3_BUCKET` and `AWS_REGION` environment variables are set correctly.

```
curl -LO https://raw.githubusercontent.com/arun-gupta/eks-workshop/inference/content/kubeflow/kubeflow.files/mnist-inference.yaml
curl -LO https://eksworkshop.com/kubeflow/kubeflow.files/mnist-inference.yaml
envsubst <mnist-inference.yaml | kubectl apply -f -
```

Wait for the containers to start:

```
kubectl get pods -l app=mnist,type=inference
NAME                    READY   STATUS      RESTARTS   AGE
mnist-96fb6f577-k8pm6   1/1     Running     0          116s
```

Port forward inference endpoint for local testing:

```
kubectl port-forward `kubectl get pods -l=app=mnist,type=inference -o jsonpath='{.items[0].metadata.name}' --field-selector=status.phase=Running` 8500:8500 &
```

#### Run inference

Original datasets are feature vectors and we use `matplotlib` to draw picture to compare results. Install the following TensorFlow client-side components:

   ```
   pip install tensorflow matplotlib --user
   ```

1. Use the script [inference_client.py](/kubeflow/kubeflow.files/inference_client.py) to make prediction request. It will randomly pick one image from test dataset and make prediction.

   ```
   $ python inference_client.py --endpoint http://localhost:8500/v1/models/mnist:predict

    Data: {"instances": [[[[0.0], [0.0], [0.0], [0.0], [0.0] ... 0.0], [0.0]]]], "signature_name": "serving_default"}
    The model thought this was a Ankle boot (class 9), and it was actually a Ankle boot (class 9)
   ```

   ![inference-random-example](inference-random-example.png)

   Running this client shows an image and the output text indicates what kind of object it is.

1. Get serving pod name:

   ```
   TF_MNIST_POD=$(kubectl get pods -l=app=mnist --field-selector=status.phase=Running -o jsonpath={'.items[0].metadata.name'})
   NAME                     READY   STATUS    RESTARTS   AGE
   mnist-7cc4468bc5-wm8kx   1/1     Running   0          2h
   ```

   Check the logs:

   ```
   kubectl logs $TF_MNIST_POD
   ```
