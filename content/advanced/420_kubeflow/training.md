---
title: "Model training"
date: 2022-07-17T00:00:00-08:00
weight: 40
draft: false
---

### Model Training

While Jupyter notebook is good for interactive model training, you may like to package the training code as Docker image and run it in Amazon EKS cluster.

This chapter explains how to build a training model for [Fashion-MNIST](https://github.com/zalandoresearch/fashion-mnist) dataset using TensorFlow and Keras on Amazon EKS. This dataset contains 70,000 grayscale images in 10 categories and is meant to be a drop-in replace of [MNIST](https://en.wikipedia.org/wiki/MNIST_database).

#### Docker image

We will use a pre-built Docker image `seedjeffwan/mnist_tensorflow_keras:1.13.1` for this exercise. This image uses `tensorflow/tensorflow:1.13.1` as the base image. The image has training code and downloads training and test data sets. It also stores the generated model in an S3 bucket.

Alternatively, you can use [Dockerfile](/advanced/420_kubeflow/kubeflow.files/Dockerfile.txt) to build the image by using the command below. We will skip this step for now

`docker build -t <dockerhub_username>/<repo_name>:<tag_name> .`

#### Create S3 bucket

Create an S3 bucket where training model will be saved:

```
export HASH=$(< /dev/urandom tr -dc a-z0-9 | head -c6)
export S3_BUCKET=$HASH-eks-ml-data
aws s3 mb s3://$S3_BUCKET --region $AWS_REGION
```

This name will be used in the pod specification later. This bucket is also used for serving the model.

If you want to use an existing bucket in a different region, then make sure to specify the exact region as the value of `AWS_REGION` environment variable in `mnist-training.yaml`.

#### Setup AWS credentials in EKS cluster

AWS credentials are required to save model on S3 bucket. These credentials are stored in EKS cluster as Kubernetes secrets.

Create an IAM user 's3user', attach S3 access policy and retrieve temporary credentials
```
aws iam create-user --user-name s3user
aws iam attach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam create-access-key --user-name s3user > /tmp/create_output.json
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
type: Opaque
data:
  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID_VALUE
  AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY_VALUE
EOF
```

#### Run training using pod

Create pod:

```
curl -LO https://eksworkshop.com/advanced/420_kubeflow/kubeflow.files/mnist-training.yaml
envsubst < mnist-training.yaml | kubectl create -f -
```

This will start a pod which will start the training and save the generated model in S3 bucket. Check status:

```
kubectl get pods
```
You'll see similar output
```
NAME              READY   STATUS    RESTARTS   AGE
mnist-training    1/1     Running   0          2m45s
```
{{% notice note %}}
Note: If your `mnist-training` fail for some reason, please copy our trained model by running the command under 'Expand here to copy trained model'. This will unblock your inference experiment in the next chapter.
{{% /notice %}}

{{%expand "Expand here to copy trained model" %}}
```
aws s3 sync s3://reinvent-opn401/mnist/tf_saved_model  s3://$S3_BUCKET/mnist/tf_saved_model
```
{{% /expand %}}

{{%expand "Expand here to see logs from successful run" %}}
```
kubectl logs mnist-training -f
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-labels-idx1-ubyte.gz
32768/29515 [=================================] - 0s 0us/step
40960/29515 [=========================================] - 0s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-images-idx3-ubyte.gz
26427392/26421880 [==============================] - 0s 0us/step
26435584/26421880 [==============================] - 0s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-labels-idx1-ubyte.gz
16384/5148 [===============================================================================================] - 0s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-images-idx3-ubyte.gz
4423680/4422102 [==============================] - 0s 0us/step
4431872/4422102 [==============================] - 0s 0us/step
WARNING:tensorflow:From /usr/local/lib/python2.7/dist-packages/tensorflow/python/ops/resource_variable_ops.py:435: colocate_with (from tensorflow.python.framework.ops) is deprecated and will be removed in a future version.
Instructions for updating:
Colocations handled automatically by placer.
2022-07-17 03:18:00.784739: I tensorflow/core/platform/cpu_feature_guard.cc:141] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2022-07-17 03:18:00.804970: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2649985000 Hz
2022-07-17 03:18:00.805221: I tensorflow/compiler/xla/service/service.cc:150] XLA service 0x35a7a70 executing computations on platform Host. Devices:
2022-07-17 03:18:00.805235: I tensorflow/compiler/xla/service/service.cc:158]   StreamExecutor device (0): <undefined>, <undefined>
2022-07-17 03:18:00.841013: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing config loader against fileName /root//.aws/config and using profilePrefix = 1
2022-07-17 03:18:00.841049: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing config loader against fileName /root//.aws/credentials and using profilePrefix = 0
2022-07-17 03:18:00.841056: I tensorflow/core/platform/s3/aws_logging.cc:54] Setting provider to read credentials from /root//.aws/credentials for credentials file and /root//.aws/config for the config file , for use with profile default
2022-07-17 03:18:00.841062: I tensorflow/core/platform/s3/aws_logging.cc:54] Creating HttpClient with max connections2 and scheme http
2022-07-17 03:18:00.841069: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing CurlHandleContainer with size 2
2022-07-17 03:18:00.841075: I tensorflow/core/platform/s3/aws_logging.cc:54] Creating Instance with default EC2MetadataClient and refresh rate 900000
2022-07-17 03:18:00.841084: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.841114: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing CurlHandleContainer with size 25
2022-07-17 03:18:00.841161: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.841255: I tensorflow/core/platform/s3/aws_logging.cc:54] Pool grown by 2
2022-07-17 03:18:00.841270: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.881729: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:18:00.881788: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:18:00.881846: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.881907: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.892742: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.892848: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.901815: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:18:00.901850: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:18:00.901892: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.901961: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.918161: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.918253: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.929317: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:18:00.929361: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:18:00.929411: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.929492: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.941661: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.941762: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.945406: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.945513: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.963891: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0318001658027880945
2022-07-17 03:18:00.964085: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:00.964183: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:00.983749: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0318001658027880964
2022-07-17 03:18:01.000370: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.000477: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:01.020649: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.020780: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:01.032914: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.033016: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:01.044396: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.044494: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:01.078156: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.078289: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:01.089475: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:01.089568: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.

train_images.shape: (60000, 28, 28, 1), of float64
test_images.shape: (10000, 28, 28, 1), of float64
_________________________________________________________________
Layer (type)                 Output Shape              Param #   
=================================================================
Conv1 (Conv2D)               (None, 13, 13, 8)         80        
_________________________________________________________________
flatten (Flatten)            (None, 1352)              0         
_________________________________________________________________
Softmax (Dense)              (None, 10)                13530     
=================================================================
Total params: 13,610
Trainable params: 13,610
Non-trainable params: 0
_________________________________________________________________
Epoch 1/40
2022-07-17 03:18:04.299751: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:04.299873: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:04.334004: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:04.334085: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:04.346408: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:04.346489: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 54us/sample - loss: 0.5570 - acc: 0.8049
Epoch 2/40
2022-07-17 03:18:07.460283: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:07.460397: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:07.540792: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:07.540962: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:07.551892: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:07.551989: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.4297 - acc: 0.8488
Epoch 3/40
2022-07-17 03:18:10.606213: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:10.606329: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:10.723069: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:10.723188: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:10.733804: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:10.733982: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.3960 - acc: 0.8601
Epoch 4/40
2022-07-17 03:18:13.814546: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:13.814666: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:13.856450: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:13.856577: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:13.868715: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:13.868804: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.3725 - acc: 0.8679
Epoch 5/40
2022-07-17 03:18:16.925660: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:16.925779: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:16.998810: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:16.998903: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:17.009333: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:17.009412: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.3541 - acc: 0.8741
Epoch 6/40
2022-07-17 03:18:20.055997: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:20.056117: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:20.149727: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:20.149940: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:20.161445: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:20.161566: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.3407 - acc: 0.8773
Epoch 7/40
2022-07-17 03:18:23.206100: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:23.206206: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:23.244258: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:23.244357: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:23.254849: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:23.254917: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.3263 - acc: 0.8823
Epoch 8/40
2022-07-17 03:18:26.308283: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:26.308402: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:26.410090: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:26.410209: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:26.432596: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:26.432694: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.3150 - acc: 0.8862
Epoch 9/40
2022-07-17 03:18:29.466167: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:29.466278: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:29.527328: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:29.527427: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:29.538035: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:29.538106: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.3048 - acc: 0.8898
Epoch 10/40
2022-07-17 03:18:32.600030: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:32.600140: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:32.665278: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:32.665392: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:32.677072: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:32.677169: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2940 - acc: 0.8935
Epoch 11/40
2022-07-17 03:18:35.742354: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:35.742489: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:35.841216: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:35.841337: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:35.859005: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:35.859093: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2855 - acc: 0.8965
Epoch 12/40
2022-07-17 03:18:38.919124: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:38.919241: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:39.002438: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:39.002575: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:39.014037: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:39.014107: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2779 - acc: 0.8996
Epoch 13/40
2022-07-17 03:18:42.087802: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:42.087911: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:42.168982: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:42.169090: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:42.181057: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:42.181149: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2720 - acc: 0.9014
Epoch 14/40
2022-07-17 03:18:45.222581: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:45.222697: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:45.306428: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:45.306560: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:45.318697: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:45.318765: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2666 - acc: 0.9035
Epoch 15/40
2022-07-17 03:18:48.368281: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:48.368391: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:48.462290: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:48.462407: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:48.473023: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:48.473091: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2614 - acc: 0.9046
Epoch 16/40
2022-07-17 03:18:51.526117: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:51.526224: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:51.828310: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:51.828458: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:51.839686: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:51.839751: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 56us/sample - loss: 0.2586 - acc: 0.9065
Epoch 17/40
2022-07-17 03:18:54.894572: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:54.894686: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:54.949660: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:54.949762: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:54.961718: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:54.961807: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2538 - acc: 0.9075
Epoch 18/40
2022-07-17 03:18:58.018278: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:58.018385: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:58.092576: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:58.092681: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:18:58.104523: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:18:58.104639: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2509 - acc: 0.9088
Epoch 19/40
2022-07-17 03:19:01.130318: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:01.130424: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:01.204608: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:01.204715: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:01.215207: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:01.215278: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2470 - acc: 0.9103
Epoch 20/40
2022-07-17 03:19:04.272580: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:04.272699: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:04.342038: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:04.342126: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:04.353007: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:04.353099: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2446 - acc: 0.9108
Epoch 21/40
2022-07-17 03:19:07.421772: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:07.421861: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:07.456119: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:07.456216: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:07.468490: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:07.468607: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2418 - acc: 0.9112
Epoch 22/40
2022-07-17 03:19:10.518048: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:10.518162: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:10.613401: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:10.613520: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:10.624870: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:10.624954: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2392 - acc: 0.9123
Epoch 23/40
2022-07-17 03:19:13.698102: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:13.698207: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:13.826427: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:13.826525: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:13.837726: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:13.837837: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 54us/sample - loss: 0.2372 - acc: 0.9137
Epoch 24/40
2022-07-17 03:19:16.906575: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:16.906683: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:16.945482: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:16.945583: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:16.956187: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:16.956286: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2346 - acc: 0.9143
Epoch 25/40
2022-07-17 03:19:19.986565: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:19.986679: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:20.058208: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:20.058321: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:20.068005: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:20.068083: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2323 - acc: 0.9152
Epoch 26/40
2022-07-17 03:19:23.112633: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:23.112743: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:23.191629: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:23.191720: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:23.208750: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:23.208880: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2299 - acc: 0.9158
Epoch 27/40
2022-07-17 03:19:26.266264: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:26.266385: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:26.338674: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:26.338763: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:26.350449: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:26.350528: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2276 - acc: 0.9166
Epoch 28/40
2022-07-17 03:19:29.378339: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:29.378455: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:29.438245: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:29.438336: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:29.450145: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:29.450219: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2261 - acc: 0.9169
Epoch 29/40
2022-07-17 03:19:32.520600: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:32.520715: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:32.592682: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:32.592785: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:32.632454: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:32.632534: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2236 - acc: 0.9171
Epoch 30/40
2022-07-17 03:19:35.695552: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:35.695662: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:35.768919: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:35.769000: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:35.779888: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:35.780075: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2227 - acc: 0.9192
Epoch 31/40
2022-07-17 03:19:38.837438: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:38.837555: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:38.951584: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:38.951709: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:38.963063: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:38.963140: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2204 - acc: 0.9192
Epoch 32/40
2022-07-17 03:19:42.034590: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:42.034704: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:42.066536: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:42.066630: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:42.077085: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:42.077159: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2176 - acc: 0.9209
Epoch 33/40
2022-07-17 03:19:45.125805: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:45.126012: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:45.179529: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:45.179631: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:45.192748: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:45.192876: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2171 - acc: 0.9216
Epoch 34/40
2022-07-17 03:19:48.239574: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:48.239681: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:48.310074: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:48.310162: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:48.326747: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:48.326840: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2150 - acc: 0.9215
Epoch 35/40
2022-07-17 03:19:51.386475: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:51.386569: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:51.455708: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:51.455800: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:51.466579: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:51.466644: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2137 - acc: 0.9227
Epoch 36/40
2022-07-17 03:19:54.501719: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:54.501836: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:54.538866: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:54.538952: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:54.551565: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:54.551644: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 51us/sample - loss: 0.2123 - acc: 0.9227
Epoch 37/40
2022-07-17 03:19:57.614738: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:57.614845: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:57.683686: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:57.683768: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:19:57.694289: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:19:57.694357: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2113 - acc: 0.9214
Epoch 38/40
2022-07-17 03:20:00.735999: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:00.736116: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:00.814213: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:00.814327: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:00.825718: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:00.825811: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 52us/sample - loss: 0.2101 - acc: 0.9225
Epoch 39/40
2022-07-17 03:20:03.891471: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:03.891572: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:03.922998: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:03.923084: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:03.939469: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:03.939553: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:03.952426: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:03.952545: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:04.003777: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:04.003877: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:04.016740: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:04.016807: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2087 - acc: 0.9232
Epoch 40/40
2022-07-17 03:20:07.107878: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.107995: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.199878: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.199974: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.211446: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.211531: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 3s 53us/sample - loss: 0.2078 - acc: 0.9250
2022-07-17 03:20:07.224786: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.224898: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.311986: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0318011658027881000
10000/10000 [==============================] - 0s 30us/sample - loss: 0.3462 - acc: 0.8861
WARNING:tensorflow:From mnist.py:69: simple_save (from tensorflow.python.saved_model.simple_save) is deprecated and will be removed in a future version.
Instructions for updating:
This function will only be available through the v1 compatibility library as tf.compat.v1.saved_model.simple_save.
WARNING:tensorflow:From /usr/local/lib/python2.7/dist-packages/tensorflow/python/saved_model/signature_def_utils_impl.py:205: build_tensor_info (from tensorflow.python.saved_model.utils_impl) is deprecated and will be removed in a future version.
Instructions for updating:
This function will only be available through the v1 compatibility library as tf.compat.v1.saved_model.utils.build_tensor_info or tf.compat.v1.saved_model.build_tensor_info.
2022-07-17 03:20:07.619762: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.619869: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.630061: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.630090: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.630131: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.630191: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.643068: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.643156: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.650559: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.650586: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.650621: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.650676: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.660322: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.660429: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.668256: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.668282: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.668316: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.668387: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.679311: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.679383: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.685265: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.685295: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.685332: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.685435: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.712210: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.712303: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.729050: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320071658028007712
2022-07-17 03:20:07.729164: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.729266: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.743765: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320071658028007729
2022-07-17 03:20:07.744099: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.744195: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.754090: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.754113: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.754142: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.754213: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.764394: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.764479: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.771711: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.771746: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.771794: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.771899: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.782494: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.782578: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.790129: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:07.790150: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:07.790176: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.790241: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.803417: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.803499: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.820888: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320071658028007803
2022-07-17 03:20:07.857238: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.857342: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.876428: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320071658028007857
2022-07-17 03:20:07.878847: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.878947: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.952529: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320071658028007876
2022-07-17 03:20:07.952647: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.952720: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:07.967044: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:07.967157: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.055603: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.055763: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.073552: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.073646: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.109421: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320081658028008073
2022-07-17 03:20:08.109535: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.109623: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.122588: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.122690: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.162513: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.162626: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.179943: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.180043: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.193361: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320081658028008179
2022-07-17 03:20:08.193475: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.193570: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.205294: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.205397: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.215508: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.215614: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.225528: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.225624: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.235359: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.235458: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.248316: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.248414: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.260267: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.260363: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.350489: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.350601: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.366895: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.366987: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.388557: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320081658028008366
2022-07-17 03:20:08.388680: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.388785: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.405153: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.405239: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.417728: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.417819: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.473716: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.473804: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.481411: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2022-07-17 03:20:08.481446: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2022-07-17 03:20:08.481491: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.481558: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.498238: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2022-07-17 03:20:08.498333: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2022-07-17 03:20:08.533310: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20220717T0320081658028008498

Test accuracy: 0.886099994183

Saved model: s3://y2opzd-eks-ml-data/mnist/tf_saved_model/1
```
{{% /expand %}}

The last line shows that the exported model is saved to S3 bucket.
