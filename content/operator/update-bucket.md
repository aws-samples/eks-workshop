---
title: "Update Assets To Use Backend"
date: 2018-08-07T08:30:11-07:00
weight: 40
draft: true
---

Now we will deploy the dynamic assets with the URL from the Service Endpoint.

Before we build our manifest, we need to ensure we have gathered our account number
and region to use in the template:
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export ELB_ENDPOINT=http://$(kubectl get svc frontend --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
```

Paste the following:
```
cat <<EoF > ~/environment/dynamic-hydrate.yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: dynamic-hydrate
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
          - name: ELB_ENDPOINT
            value: ${ELB_ENDPOINT}
        command: ["python"]
        args: ["dynamic.py", "\$(ELB_ENDPOINT)", "\$(S3_BUCKET)"]
      restartPolicy: Never
  backoffLimit: 5
EoF
```

Apply the file updating the assets:
```
kubectl apply -f ~/environment/dynamic-hydrate.yaml
```

Now let's reload the S3 Bucket webite, if you lost it you can find it via the
`.outputs` on the `s3bucket` resource.

```
kubectl get s3 -o jsonpath="{.items[0].output.websiteURL} " # the space is intentional
```

Now you can see an application built using native AWS tools to reduce the
operational overhead, while being freed of the provisioning and lifecycle of the
resources.
