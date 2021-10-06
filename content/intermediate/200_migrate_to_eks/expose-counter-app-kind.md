---
title: "Expose counter app from kind"
weight: 30
---

An app that's not exposed isn't very useful.
We'll manually create a load balancer to expose the app.

The first thing you need to do is get your **local computer's public ip address**.
Open a new browser tab and to [icanhasip.com](http://icanhazip.com/) and copy the IP address.

Go back to the Cloud9 shell and save that IP address as an environment variable

```bash
export PUBLIC_IP=#YOUR PUBLIC IP
```

Now allow your IP address to access port 80 of your Cloud9 instance's security group and allow traffic on the security group for a load balancer.

```bash
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP \
    --protocol tcp \
    --port 80 \
    --cidr ${PUBLIC_IP}/25

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP \
    --protocol -1 \
    --source-group $SECURITY_GROUP
```

Create an Application Load Balancer (ALB) in the same security group and subnet.
An ALB needs to be spread across a minimum of two subnets.

```bash
export ALB_ARN=$(aws elbv2 create-load-balancer \
    --name counter \
    --subnets $(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC" \
        --query 'Subnets[*].SubnetId' \
        --output text) \
    --type application --security-groups $SECURITY_GROUP \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)
```

Create a target group 

```bash
export TG_ARN=$(aws elbv2 create-target-group \
    --name counter-target --protocol HTTP \
    --port 30000 --target-type instance \
    --vpc-id ${VPC} --query 'TargetGroups[0].TargetGroupArn' \
    --output text)
```

Register our node to the TG

```bash
aws elbv2 register-targets \
    --target-group-arn ${TG_ARN} \
    --targets Id=${INSTANCE_ID}
```

Create a listener and default action

```bash
aws elbv2 wait load-balancer-available \
    --load-balancer-arns $ALB_ARN \
    && export ALB_LISTENER=$(aws elbv2 create-listener \
    --load-balancer-arn ${ALB_ARN} \
    --port 80 --protocol HTTP \
    --default-actions Type=forward,TargetGroupArn=${TG_ARN} \
    --query 'Listeners[0].ListenerArn' \
    --output text)
```

Our local counter app should now be exposed from the ALB

```bash
echo "http://"$(aws elbv2 describe-load-balancers \
    --load-balancer-arns $ALB_ARN \
    --query 'LoadBalancers[0].DNSName' --output text)
```

Make sure you click the button a lot because that's the important data we're going to migrate to EKS later.

![counter app screenshot](/images/migrate_to_eks/counter-app.gif)
