---
title: "Create kind cluster"
weight: 10
---

While our EKS cluster is being created we can create a kind cluster locally on the cloud9 instance.

![kind cluster](/images/migrate_to_eks/create-kind-cluster.png)

Before we create one lets make sure our network rules are set up

{{% notice note %}}
This is going to manually create some iptables rules to route traffic to your Cloud9 instance.
If you reboot the VM you will have to run these commands again as they are not persistent.
{{% /notice %}}

```bash
echo 'net.ipv4.conf.all.route_localnet = 1' | sudo tee /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
```

Create a config file for the kind cluster

```bash
cat > kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.11@sha256:07db187ae84b4b7de440a73886f008cf903fcf5764ba8106a9fd5243d6f32729
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
  - containerPort: 30001
    hostPort: 30001
EOF
```

Create the local kind cluster

```bash
kind create cluster --config kind.yaml
```

Set the default context to the EKS cluster.

```bash
kubectl config use-context "arn:aws:eks:${AWS_REGION}:${ACCOUNT_ID}:cluster/${CLUSTER}"
```
