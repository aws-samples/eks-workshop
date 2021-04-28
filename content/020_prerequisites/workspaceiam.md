---
title: "Update IAM settings for your Workspace"
chapter: false
weight: 19
---

{{% notice info %}}
Cloud9 normally manages IAM credentials dynamically. This isn't currently compatible with
the EKS IAM authentication, so we will disable it and rely on the IAM role instead.
{{% /notice %}}

- Return to your Cloud9 workspace and click the gear icon (in top right corner)
- Select **AWS SETTINGS**
- Turn off **AWS managed temporary credentials**
- Close the Preferences tab
![c9disableiam](/images/prerequisites/c9disableiam.png)

To ensure temporary credentials aren't already in place we will also remove
any existing credentials file:

```sh
rm -vf ${HOME}/.aws/credentials
```

We should configure our aws cli with our current region as default.

{{% notice info %}}
If you are [at an AWS event](https://eksworkshop.com/020_prerequisites/aws_event/), ask your instructor which **AWS region** to use.
{{% /notice %}}

```sh
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))

```

Check if AWS_REGION is set to desired region

```sh
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
```

 Let's save these into bash_profile

```sh
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export AZS=(${AZS[@]})" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```

### Validate the IAM role

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```bash
aws sts get-caller-identity --query Arn | grep eksworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"
```

If the IAM role is not valid, <span style="color: red;">**DO NOT PROCEED**</span>. Go back and confirm the steps on this page.
