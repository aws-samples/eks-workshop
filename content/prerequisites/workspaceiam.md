---
title: "Update IAM settings for your Workspace"
chapter: false
weight: 30
---

{{% notice info %}}
Cloud9 normally manages IAM credentials dynamically. This isn't currently compatible with
the aws-iam-authenticator plugin, so we will disable it and rely on the IAM role instead.
{{% /notice %}}

- Return to your workspace and click the sprocket, or launch a new tab to open the Preferences tab
- Select **AWS SETTINGS**
- Turn off **AWS managed temporary credentials**
- Close the Preferences tab
![c9disableiam](/images/c9disableiam.png)

To ensure temporary credentials aren't already in place we will also remove
any existing credentials file:
```
rm -vf ${HOME}/.aws/credentials
```

We should configure our aws cli with our current region as default:
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```

### Validate the IAM role

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

<!--
First, get the IAM role name from the AWS CLI.
```bash
INSTANCE_PROFILE_NAME=`basename $(aws ec2 describe-instances --filters Name=tag:Name,Values=aws-cloud9-${C9_PROJECT}-${C9_PID} | jq -r '.Reservations[0].Instances[0].IamInstanceProfile.Arn' | awk -F "/" "{print $2}")`
aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --query "InstanceProfile.Roles[0].RoleName" --output text
```
-->

The output assumed-role name should contain:
```
eksworkshop-admin
or
TeamRole
```

#### VALID

If the _Arn_ contains the role name from above and an Instance ID, you may proceed.

```output
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef", 
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
or
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef", 
    "Arn": "arn:aws:sts::123456789012:assumed-role/TeamRole/i-01234567890abcdef"
}
```

#### INVALID

If the _Arn contains anything other than `TeamRole`, `MasterRole`, or does not match the role name output above, <span style="color: red;">**DO NOT PROCEED**</span>. Go back and confirm the steps on this page.

```output
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef", 
    "Arn": "arn:aws:sts::123456789012:assumed-role/TeamRole/MasterRole"
}
```
