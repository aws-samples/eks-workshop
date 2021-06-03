---
title: "OPA Policy Example 1: Approved container registry policy"
weight: 20
draft: false
---

Within your Amazon EKS cluster, you may want to restrict users to use approved internal registry for container images. By default, the cluster will allow pulling images from public image repositories.

Create a test Pod manifest that allows pulling `nginx` image from a public repository.

```
mkdir ~/environment/opa

cat > ~/environment/opa/public-nginx.yaml <<EOF
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

The following command will pull the 'nginx' image and run it in a Pod.

```
kubectl apply -f ~/environment/opa/public-nginx.yaml
```

Notice that you are able to deploy container images from any repository you are able to access. Now let us delete the Pod.

```
kubectl delete -f ~/environment/opa/public-nginx.yaml
```

#### The Open Policy Agent (OPA) Gatekeeper policy solution

We can use OPS Gatekeeper to restrict which repositories are allow to be used in this cluster.

##### 1. Deploy OPA Gatekeeper

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.4/deploy/gatekeeper.yaml
```

##### 2. Create and apply the Gatekeeper template file

This template will be used to check if the container images are being pulled from the an approved repository.

```
cat > ~/environment/opa/template.yaml <<EOF
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sallowedrepos
  annotations:
    description: Requires container images to begin with a repo string from a specified
      list.
spec:
  crd:
    spec:
      names:
        kind: K8sAllowedRepos
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          properties:
            repos:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sallowedrepos
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
          not any(satisfied)
          msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
        }
EOF

kubectl apply -f ~/environment/opa/template.yaml
```



##### 3. Create and apply the constraint file

The constraint file allows us to define which resources we what to apply the limiting constraint. In this case, we are limiting Pods to only the ECR repositary in our current account and region. 

```
cat > ~/environment/opa/constraint.yaml <<EOF
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: repo-is-ecr-local
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces:
      - "default"
  parameters:
    repos:
      - "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
EOF

kubectl apply -f ~/environment/opa/constraint.yaml

```

##### 4. Create a private Amazon ECR repository

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
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
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

##### 5. Create a Pod manifest that uses private ECR repository

Now we can recreate our `nginx` manifest file and push it to our Amazon EKS cluster:

```
cat > ~/environment/opa/private-nginx.yaml <<EOF
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
kubectl apply -f ~/environment/opa/public-nginx.yaml
```

2. Now create the Pod that using the private ECR repository. This should succeed.

```
kubectl apply -f ~/environment/opa/private-nginx.yaml
```


#### Clean Up

Run the following commands to undo this lab's effects on your cluster.

```
kubectl delete -f ~/environment/opa/private-nginx.yaml
kubectl delete -f ~/environment/opa/constraint.yaml
kubectl delete -f ~/environment/opa/template.yaml
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.4/deploy/gatekeeper.yaml
rm -rf ~/environment/opa
```