---
title: "Model training"
date: 2019-08-27T00:00:00-08:00
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

> Note: If your `mnist-training` fail for some reason, please copy our trained model to your bucket by running following command, this will unblock your inference experiment in the next chapter.

```
aws s3 sync s3://reinvent-opn401/mnist/tf_saved_model  s3://$S3_BUCKET/mnist/tf_saved_model
```

{{%expand "Expand here to see complete logs" %}}
```
kubectl logs mnist-training -f
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-labels-idx1-ubyte.gz
32768/29515 [=================================] - 0s 1us/step
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
2019-08-29 00:32:10.652905: I tensorflow/core/platform/cpu_feature_guard.cc:141] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2019-08-29 00:32:10.659233: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2300070000 Hz
2019-08-29 00:32:10.661111: I tensorflow/compiler/xla/service/service.cc:150] XLA service 0x45baf40 executing computations on platform Host. Devices:
2019-08-29 00:32:10.661139: I tensorflow/compiler/xla/service/service.cc:158]   StreamExecutor device (0): <undefined>, <undefined>
2019-08-29 00:32:10.718125: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing config loader against fileName /root//.aws/config and using profilePrefix = 1
2019-08-29 00:32:10.718160: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing config loader against fileName /root//.aws/credentials and using profilePrefix = 0
2019-08-29 00:32:10.718174: I tensorflow/core/platform/s3/aws_logging.cc:54] Setting provider to read credentials from /root//.aws/credentials for credentials file and /root//.aws/config for the config file , for use with profile default
2019-08-29 00:32:10.718184: I tensorflow/core/platform/s3/aws_logging.cc:54] Creating HttpClient with max connections2 and scheme http
2019-08-29 00:32:10.718196: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing CurlHandleContainer with size 2
2019-08-29 00:32:10.718207: I tensorflow/core/platform/s3/aws_logging.cc:54] Creating Instance with default EC2MetadataClient and refresh rate 900000
2019-08-29 00:32:10.718224: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:10.718275: I tensorflow/core/platform/s3/aws_logging.cc:54] Initializing CurlHandleContainer with size 25
2019-08-29 00:32:10.718341: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:10.718468: I tensorflow/core/platform/s3/aws_logging.cc:54] Pool grown by 2
2019-08-29 00:32:10.718490: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.036616: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:32:11.036661: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:32:11.036724: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.036807: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.204229: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.204327: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.281479: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:32:11.281513: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:32:11.281551: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.281615: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.388175: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.388285: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.550463: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.550639: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.628831: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.628915: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:11.709359: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:11.709455: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:12.017431: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:12.017573: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:12.096831: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:12.096933: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.

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
2019-08-29 00:32:16.840512: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:16.840633: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:17.280630: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:17.280744: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:17.384333: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:17.384520: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 87us/sample - loss: 0.5496 - acc: 0.8082
Epoch 2/40
2019-08-29 00:32:21.952054: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:21.952176: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:22.369041: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:22.369238: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:22.446531: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:22.446629: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.4137 - acc: 0.8548
Epoch 3/40
2019-08-29 00:32:27.021467: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:27.021592: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:27.454086: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:27.454230: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:27.534720: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:27.534816: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3763 - acc: 0.8685
Epoch 4/40
2019-08-29 00:32:32.130604: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:32.130728: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:32.517514: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:32.517630: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:32.629178: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:32.629262: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3555 - acc: 0.8746
Epoch 5/40
2019-08-29 00:32:37.235765: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:37.235889: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:37.736414: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:37.736525: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:37.813549: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:37.813632: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 86us/sample - loss: 0.3415 - acc: 0.8794
Epoch 6/40
2019-08-29 00:32:42.400365: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:42.400527: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:42.809268: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:42.809409: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:42.887120: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:42.887209: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3283 - acc: 0.8835
Epoch 7/40
2019-08-29 00:32:47.474549: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:47.474676: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:47.885577: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:47.885686: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:47.963577: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:47.963662: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3188 - acc: 0.8868
Epoch 8/40
2019-08-29 00:32:52.571365: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:52.571487: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:52.973365: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:52.973461: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:53.051547: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:53.051711: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3112 - acc: 0.8887
Epoch 9/40
2019-08-29 00:32:57.620454: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:57.620579: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:58.045196: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:58.045301: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:32:58.123871: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:32:58.123956: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.3036 - acc: 0.8924
Epoch 10/40
2019-08-29 00:33:02.735621: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:02.735784: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:03.155609: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:03.155717: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:03.237484: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:03.237568: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 86us/sample - loss: 0.2964 - acc: 0.8943
Epoch 11/40
2019-08-29 00:33:07.847167: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:07.847295: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:08.308130: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:08.308233: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:08.385677: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:08.385761: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2904 - acc: 0.8966
Epoch 12/40
2019-08-29 00:33:12.989568: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:12.989709: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:13.425758: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:13.425871: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:13.503980: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:13.504066: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2850 - acc: 0.8979
Epoch 13/40
2019-08-29 00:33:18.084636: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:18.084799: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:18.505749: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:18.505889: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:18.584930: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:18.585086: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2788 - acc: 0.8994
Epoch 14/40
2019-08-29 00:33:23.165093: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:23.165216: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:23.583005: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:23.583125: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:23.660931: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:23.661017: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2743 - acc: 0.9016
Epoch 15/40
2019-08-29 00:33:28.273507: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:28.273630: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:28.656655: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:28.656805: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:28.735635: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:28.735757: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 84us/sample - loss: 0.2702 - acc: 0.9025
Epoch 16/40
2019-08-29 00:33:33.340967: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:33.341091: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:33.797569: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:33.797673: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:33.876101: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:33.876187: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 86us/sample - loss: 0.2668 - acc: 0.9032
Epoch 17/40
2019-08-29 00:33:38.485389: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:38.485516: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:38.911662: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:38.911776: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:38.990577: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:38.990673: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2627 - acc: 0.9059
Epoch 18/40
2019-08-29 00:33:43.586335: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:43.586462: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:43.982270: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:43.982444: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:44.061595: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:44.061765: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2587 - acc: 0.9072
Epoch 19/40
2019-08-29 00:33:48.666451: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:48.666582: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:49.113733: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:49.113835: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:49.191768: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:49.191853: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2542 - acc: 0.9082
Epoch 20/40
2019-08-29 00:33:53.778720: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:53.778845: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:54.275408: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:54.275506: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:54.354271: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:54.354356: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 86us/sample - loss: 0.2521 - acc: 0.9092
Epoch 21/40
2019-08-29 00:33:58.946098: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:58.946222: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:59.369881: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:59.369985: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:33:59.449359: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:33:59.449538: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2481 - acc: 0.9108
Epoch 22/40
2019-08-29 00:34:04.040611: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:04.040733: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:04.459577: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:04.459698: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:04.537060: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:04.537154: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2457 - acc: 0.9116
Epoch 23/40
2019-08-29 00:34:09.122286: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:09.122409: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:09.542468: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:09.542659: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:09.633226: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:09.633310: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 86us/sample - loss: 0.2419 - acc: 0.9119
Epoch 24/40
2019-08-29 00:34:14.283736: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:14.283861: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:14.759453: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:14.759588: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:14.840762: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:14.840865: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:14.924147: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:14.924254: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:15.297162: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:15.297277: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:15.374905: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:15.375009: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 6s 95us/sample - loss: 0.2388 - acc: 0.9141
Epoch 25/40
2019-08-29 00:34:20.010218: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:20.010338: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:20.431755: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:20.431867: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:20.511302: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:20.511404: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2368 - acc: 0.9146
Epoch 26/40
2019-08-29 00:34:25.085846: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:25.085965: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:25.497865: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:25.497980: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:25.575489: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:25.575573: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 84us/sample - loss: 0.2345 - acc: 0.9151
Epoch 27/40
2019-08-29 00:34:30.165576: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:30.165696: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:30.585389: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:30.585504: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:30.663307: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:30.663409: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2308 - acc: 0.9172
Epoch 28/40
2019-08-29 00:34:35.239820: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:35.239945: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:35.664925: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:35.665038: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:35.743716: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:35.743799: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2294 - acc: 0.9172
Epoch 29/40
2019-08-29 00:34:40.319353: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:40.319497: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:40.729421: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:40.729536: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:40.807044: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:40.807129: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2273 - acc: 0.9182
Epoch 30/40
2019-08-29 00:34:45.400274: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:45.400403: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:46.006187: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:46.006303: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:46.080739: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:46.080829: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 87us/sample - loss: 0.2253 - acc: 0.9193
Epoch 31/40
2019-08-29 00:34:50.675446: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:50.675569: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:51.083387: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:51.083492: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:51.158345: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:51.158437: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2238 - acc: 0.9199
Epoch 32/40
2019-08-29 00:34:55.735525: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:55.735650: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:56.186660: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:56.186764: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:34:56.260818: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:34:56.260911: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2213 - acc: 0.9203
Epoch 33/40
2019-08-29 00:35:00.860052: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:00.860199: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:01.251599: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:01.251755: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:01.327938: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:01.328027: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 84us/sample - loss: 0.2196 - acc: 0.9205
Epoch 34/40
2019-08-29 00:35:05.913785: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:05.913909: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:06.448875: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:06.448994: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:06.523964: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:06.524112: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 87us/sample - loss: 0.2184 - acc: 0.9206
Epoch 35/40
2019-08-29 00:35:11.114671: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:11.114823: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:11.521477: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:11.521598: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:11.596112: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:11.596214: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2159 - acc: 0.9218
Epoch 36/40
2019-08-29 00:35:16.230868: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:16.230993: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:16.631740: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:16.631860: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:16.709297: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:16.709410: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2145 - acc: 0.9225
Epoch 37/40
2019-08-29 00:35:21.293198: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:21.293319: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:21.807158: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:21.807261: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:21.930544: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:21.930631: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 87us/sample - loss: 0.2136 - acc: 0.9232
Epoch 38/40
2019-08-29 00:35:26.531272: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:26.531393: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:26.934413: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:26.934524: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:27.041029: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:27.041135: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2117 - acc: 0.9235
Epoch 39/40
2019-08-29 00:35:31.632210: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:31.632333: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:32.032924: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:32.033065: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:32.107077: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:32.107193: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 84us/sample - loss: 0.2108 - acc: 0.9241
Epoch 40/40
2019-08-29 00:35:36.705902: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:36.706024: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:37.106458: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:37.106617: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:37.183601: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:37.183817: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
60000/60000 [==============================] - 5s 85us/sample - loss: 0.2098 - acc: 0.9239
2019-08-29 00:35:37.263849: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:37.263982: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:37.457410: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0032111567038731387
10000/10000 [==============================] - 0s 44us/sample - loss: 0.3531 - acc: 0.8830
WARNING:tensorflow:From mnist.py:69: simple_save (from tensorflow.python.saved_model.simple_save) is deprecated and will be removed in a future version.
Instructions for updating:
This function will only be available through the v1 compatibility library as tf.compat.v1.saved_model.simple_save.
WARNING:tensorflow:From /usr/local/lib/python2.7/dist-packages/tensorflow/python/saved_model/signature_def_utils_impl.py:205: build_tensor_info (from tensorflow.python.saved_model.utils_impl) is deprecated and will be removed in a future version.
Instructions for updating:
This function will only be available through the v1 compatibility library as tf.compat.v1.saved_model.utils.build_tensor_info or tf.compat.v1.saved_model.build_tensor_info.
2019-08-29 00:35:37.903206: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:37.903336: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:37.978201: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:37.978248: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:37.978318: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:37.978431: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.060440: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.060574: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.133815: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:38.133858: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:38.133913: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.134018: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.211956: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.212154: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.287561: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:38.287603: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:38.287662: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.287762: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.365346: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.365482: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.437001: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:38.437062: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:38.437133: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.437263: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.618714: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.618821: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.703515: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035381567038938618
2019-08-29 00:35:38.703638: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.703727: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.796327: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035381567038938703
2019-08-29 00:35:38.796732: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.796826: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:38.871391: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:38.871426: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:38.871468: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:38.871535: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.000565: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.000661: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.074122: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:39.074157: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:39.074197: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.074271: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.151349: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.151439: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.225500: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:39.225536: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:39.225574: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.225640: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.305893: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.305997: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.393168: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035391567038939305
2019-08-29 00:35:39.451779: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.451888: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.534538: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035391567038939451
2019-08-29 00:35:39.539846: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.539981: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.790995: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035391567038939534
2019-08-29 00:35:39.791131: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.791234: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:39.871382: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:39.871496: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.027665: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.027772: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.115533: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.115638: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.273357: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035401567038940115
2019-08-29 00:35:40.273461: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.273543: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.394230: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.394419: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.495666: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.495803: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.578868: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.578965: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.658188: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035401567038940578
2019-08-29 00:35:40.658293: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.658393: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.733400: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.733490: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.813995: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.814163: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.907589: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.907716: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:40.987771: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:40.987873: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.064912: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.065012: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.149777: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.149924: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.304768: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.304904: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.388975: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.389106: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.547755: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035411567038941388
2019-08-29 00:35:41.547853: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.547992: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.636644: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.636728: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.719947: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.720068: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.897549: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.897646: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:41.971144: E tensorflow/core/platform/s3/aws_logging.cc:60] No response body. Response code: 404
2019-08-29 00:35:41.971186: W tensorflow/core/platform/s3/aws_logging.cc:57] If the signature check failed. This could be because of a time skew. Attempting to adjust the signer.
2019-08-29 00:35:41.971243: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:41.971367: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:42.059414: I tensorflow/core/platform/s3/aws_logging.cc:54] Found secret key
2019-08-29 00:35:42.059526: I tensorflow/core/platform/s3/aws_logging.cc:54] Connection has been released. Continuing.
2019-08-29 00:35:42.219035: I tensorflow/core/platform/s3/aws_logging.cc:54] Deleting file: /tmp/s3_filesystem_XXXXXX20190829T0035421567038942059

Test accuracy: 0.883000016212

Saved model: s3://eks-ml-data/mnist/tf_saved_model/1
```
{{% /expand %}}

The last line shows that the exported model is saved to S3 bucket.
