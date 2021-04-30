---
title: "Artifact Configuration"
weight: 30
draft: false
---

Lets configure all the artifacts and storage that we will need for our usecase.

#### Configure S3 Artifact
We will configure Spinnaker to access an  bucket as a source of artifacts. Spinnaker stages such as a Deploy Manifest read configuration from S3 files directly. Lets enable S3 as an artifact source.

Spinnaker requires an external storage provider for persisting our Application settings and configured Pipelines. In this workshop we will be using [S3](https://aws.amazon.com/s3/) as a storage source means that Spinnaker will store all of its persistent data in a Bucket.


* **Create S3 Bucket first**

	Go to AWS Console >>> S3 and create the bucket as below

	![Spinnaker](/images/spinnnaker/s3bucket.png)
	![Spinnaker](/images/spinnnaker/s3bucketdetail.png)

* **Set up environment variables**

`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are the AWS profile credentials for the user who have created the above S3 bucket.

{{< output >}}
export S3_BUCKET=<your_s3_bucket>
export AWS_ACCESS_KEY_ID=<your_access_key>
export AWS_SECRET_ACCESS_KEY=<your_secret_access_key>
{{< /output >}}


* **Configure persistentStorage**

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.config`.

{{< output >}}
  persistentStorage:
    persistentStoreType: s3
    s3:
      bucket: $S3_BUCKET
      rootFolder: front50
      region: $AWS_REGION
      accessKeyId: $AWS_ACCESS_KEY_ID
      secretAccessKey: $AWS_SECRET_ACCESS_KEY
{{< /output >}}

#### Configure ECR Artifact

Amazon ECR requires access tokens to access the images and those access tokens expire after a time. In order to automate updating the token, use a sidecar container with a script that does it for you. Since both Clouddriver and the sidecar container need access to the ECR access token, we will use a shared volume to store the access token.

The sidecar needs to be able to request an access token from ECR. The Spinnaker installation must have the `AmazonEC2ContainerRegistryReadOnly` policy attached to the role assigned in order to request and update the required access token.

- **Create ECR Repository**

We need to push a test container image to the newly created ECR repository. The resaon being, empty ECR respository does not show up in the Spinnaker UI when we set up the trigger in pipeline.

```
export ECR_REPOSITORY=eks-microservice-demo/test
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr describe-repositories --repository-name $ECR_REPOSITORY >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name $ECR_REPOSITORY >/dev/null
TARGET=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest
docker build -t $TARGET apps/detail
docker push $TARGET
```

- **Create a configmap**

Below we are creating the `spinnaker` namespace where all the Spinnaker services will be deployed and also creating configmap for ECR token.
```sh
kubectl create ns spinnaker

cat << EOF > config.yaml
interval: 30m # defines refresh interval
registries: # list of registries to refresh
  - registryId: "$ACCOUNT_ID"
    region: "$AWS_REGION"
    passwordFile: "/etc/passwords/my-ecr-registry.pass"
EOF

kubectl -n spinnaker create configmap token-refresh-config --from-file config.yaml
```
{{< output >}}
namespace/spinnaker created
configmap/token-refresh-config created
{{< /output >}}


Confirm if configmap is created correctly 
```sh
kubectl describe configmap token-refresh-config -n spinnaker
```

* **Add a sidecar for token refresh**

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.config`.

{{< output >}}
      deploymentEnvironment:
        sidecars:
          spin-clouddriver:
          - name: token-refresh
            dockerImage: quay.io/skuid/ecr-token-refresh:latest
            mountPath: /etc/passwords
            configMapVolumeMounts:
            - configMapName: token-refresh-config
              mountPath: /opt/config/ecr-token-refresh
 {{< /output >}}

* **Define an ECR Registry**

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.profiles`.

{{< output >}}
      clouddriver:
        dockerRegistry:
          enabled: true
          primaryAccount: my-ecr-registry
          accounts:
          - name: my-ecr-registry
            address: https://$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
            username: AWS
            passwordFile: /etc/passwords/my-ecr-registry.pass
            trackDigests: true
            repositories:
            - $ECR_REPOSITORY
 {{< /output >}}

#### Configure Igor

[Igor](https://github.com/spinnaker/igor/#common-polling-architecture) is a is a wrapper API that provides a single point of integration with Continuous Integration (CI) and Source Control Management (SCM) services for Spinnaker. It is responsible for kicking-off jobs and reporting the state of running or completing jobs.

[Clouddriver](https://github.com/spinnaker/clouddriver) can be configured to poll the ECR registries. When that is the case, igor can then create a poller that will list the registries indexed by clouddriver, check each one for new images and submit events to echo (hence allowing Docker triggers)

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.profiles`.

{{< output >}}
      igor:
        docker-registry:
          enabled: true
 {{< /output >}}

#### Add GitHub Repository

* **Set up environment variablesß**

{{< output >}}
export GITHUB_USER=<your_github_username>
export GITHUB_TOKEN=<your_github_accesstoken>
{{< /output >}}

* **Configure GitHub**

To access a GitHub repo as a source of artifacts. If you actually want to use a file from the GitHub commit in your pipeline, you’ll need to configure GitHub as an artifact source in Spinnaker.

Open the `SpinnakerService` manifest located at deploy/spinnaker/basic/spinnakerservice.yml, then add the below section under `spec.spinnakerConfig.config`.

{{< output >}}
      features:
        artifacts: true
      artifacts:
        github:
          enabled: true
          accounts:
          - name: $GITHUB_USER
            token: $GITHUB_TOKEN  # GitHub's personal access token. This fields supports `encrypted` references to secrets.
 {{< /output >}}
