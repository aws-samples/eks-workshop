---
title: "Cleanup"
weight: 70
draft: false
---

#### Delete Spinnaker artifacts
{{% notice info %}}
Namespace deletion may take few minutes, please wait till the process completes.
{{% /notice %}}
```bash
for i in $(kubectl get crd | grep spinnaker | cut -d" " -f1) ; do
kubectl delete crd $i
done

kubectl delete ns spinnaker-operator

kubectl delete ns spinnaker

kubectl delete ns detail
```

#### (Optional) Create Old Nodegroup
In case you have existing workloads to evit to this nodegroup before we delete the nodegroup created for this chapter
{{% notice info %}}
Nodegroup creation will take few minutes.
{{% /notice %}}
```bash
eksctl create nodegroup --cluster=eksworkshop-eksctl --name=nodegroup --nodes=3 --node-type=t3.small --enable-ssm --managed
```

#### Delete Nodegroup
```bash
eksctl delete nodegroup --cluster=eksworkshop-eksctl --name=spinnaker
```


