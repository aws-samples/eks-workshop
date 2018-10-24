---
title: "Create Bucket & Hydrate with Assets"
date: 2018-08-07T08:30:11-07:00
weight: 20
draft: true
---

With the AWS Service Operator running we can make a manifest for our S3
bucket and hydrate some assets.

Copy and paste this manifest so that we can `kubectl apply` it.

```
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

cat <<EoF > ~/environment/static-hydrate.yaml
---
apiVersion: operator.aws/v1alpha1
kind: S3Bucket
metadata:
  name: aws-operator-workshop-${ACCOUNT_ID}
spec:
  versioning: false
  accessControl: PublicRead
  website:
    enabled: true
    indexPage: index.html
    errorPage: 500.html
  logging:
    enabled: false
    prefix: "archive"
---
apiVersion: batch/v1
kind: Job
metadata:
  name: static-hydrate
spec:
  template:
    spec:
      containers:
      - name: hydrate
        image: omarlari/operator-demo-hydrate
        imagePullPolicy: Always
        env:
          - name: S3_BUCKET
            valueFrom:
              configMapKeyRef:
                name: aws-operator-workshop-${ACCOUNT_ID}
                key: bucketName
        command: ["aws"]
        args: ["s3", "cp", "static/index.html", "s3://\$(S3_BUCKET)"]
      restartPolicy: Never
  backoffLimit: 5
EoF
```

This pair of resources creates an `S3Bucket` in the top setting `versioning:
false` `PublicRead` on the `accessControl` and enabling the static website with
some setting.  The bottom is a Kubernetes job that uses a demo image, this image
has 1 static `html` page in it and the `aws` cli to upload the file to the
`s3://$(S3_BUCKET)` which comes from a `configMapKeyRef`.


{{% notice info %}}
We didn't set the `ConfigMap` values, these values come from a `ConfigMap` that
is generated when the `S3Bucket` is create from the above manifest.
{{% /notice %}}

Then we can and apply the config:
```
kubectl apply -f ~/environment/static-hydrate.yaml
```

While the bucket creates we can watch it's status buy running.

```
kubectl get s3 -o yaml -w
```

To see what we deployed we can run

```
kubectl get s3 -o jsonpath="{.items..output.websiteURL} " # the space is intentional
```

Then open the returned URL in the browser.

![Static Site](/images/static-site.png)

Let's deploy the backend!
