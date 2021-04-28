---
title: "OPA Policy Example 1: Approved container registry policy"
weight: 20
draft: false
---

Within your Amazon EKS cluster, you may want to restrict users to use approved internal registry for container images. By default, the cluster will allow pulling images from public image repositories.

#### The Problem

Create a test Pod manifest that allows pulling `nginx` image from a public repository.

```
cat > public-nginx.yaml <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: nginx
  labels:
    app: nginx
  namespace: default
spec:
  containers:
  - image: nginx
    name: nginx
EOF
```

Run the `nginx` Pod.

```
kubectl apply -f public-nginx.yaml
```

Delete the Pod

```
kubectl delete -f public-nginx.yaml
```

#### The OPA policy solution

##### 1. Create an OPA policy using `rego`

The policy written in `rego` denies all the authenticated and authorised requests from the Kubernetes API server if the Pod image source does not start with `${ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com` and returns an error message `image '%v' comes from untrusted registry`.

```
cat > image_source.rego <<EOF
package kubernetes.admission                                                

deny[msg] {                                                                
  input.request.kind.kind == "Pod"                                        
  image := input.request.object.spec.containers[_].image                 
  not startswith(image, "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com") 
  msg := sprintf("image '%v' comes from untrusted registry", [image])  
}
EOF
```

##### 2. Deploy the OPA policy as ConfigMap

```
kubectl create configmap image-source --from-file=image_source.rego
```

Confirm the implementation of the policy in the OPA Validating Webhook Configuration.

```
kubectl get configmap image-source -o jsonpath="{.metadata.annotations}"
```

##### 3. Create a private Amazon ECR repository

Create an ECR repository named `nginx`

```
aws ecr create-repository --repository-name nginx
```

Get the repository name from the ECR API so we can tag our local nginx instance

```
export REPOSITORY=$(aws ecr describe-repositories --repository-name nginx --query "repositories[0].repositoryUri" --output text)
```

Pull the Docker Hub public nginx locally so that we can retag it

```
docker pull nginx
```

Retag `latest` with our repository name and push the image to your own Amazon ECR. We start by logging into Amazon ECR.

```
aws ecr get-login-password \
    --region <region> \
| docker login \
    --username AWS \
    --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```

Enlist the local docker images to capture the image ID

```
docker images nginx
```

Note the `nginx` image ID in the previous step and use it in the next command to re-tag the ECR repository

```
docker tag <IMAGE ID> $REPOSITORY
```

Push the latest tag to Amazon ECR

```
docker push ${REPOSITORY}:latest
```

##### 4. Create a Pod manifest that uses private ECR repository

Now we can recreate our `nginx` manifest file and push it to our Amazon EKS cluster:

```
cat > private-nginx.yaml <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: nginx
  labels:
    app: nginx
  namespace: default
spec:
  containers:
  - image: ${REPOSITORY}:latest
    name: nginx
EOF
```

#### Test the solution

1. Try creating the Pod that uses public repository again. It should throw an error.

```
kubectl apply -f public-nginx.yaml
```

2. Now create the Pod that using the private ECR repository. This should succeed.

```
kubectl apply -f private-nginx.yaml
```


