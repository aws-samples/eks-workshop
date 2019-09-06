---
title: "Model inference"
date: 2019-08-27T00:00:00-08:00
weight: 50
draft: false
---

### Model Inference

After the model is trained and stored in S3 bucket, the next step is to use that model for inference.

This chapter explains how to use the previously trained model and run inference using TensorFlow and Keras on Amazon EKS.

#### Run inference pod

A model from training was stored in the S3 bucket in previous section. Make sure `S3_BUCKET` and `AWS_REGION` environment variables are set correctly.

```
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

Use the script [inference_client.py](/kubeflow/kubeflow.files/inference_client.py) to make prediction request. It will randomly pick one image from test dataset and make prediction.

```
curl -LO https://eksworkshop.com/kubeflow/kubeflow.files/inference_client.py
$ python inference_client.py --endpoint http://localhost:8500/v1/models/mnist:predict

Data: {"instances": [[[[0.0], [0.0], [0.0], [0.0], [0.0] ... 0.0], [0.0]]]], "signature_name": "serving_default"}
The model thought this was a Ankle boot (class 9), and it was actually a Ankle boot (class 9)
```
