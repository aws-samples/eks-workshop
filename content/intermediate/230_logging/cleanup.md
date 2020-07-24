---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

```bash
cd  ~/environment/

kubectl delete -f ~/environment/logging/fluentbit.yaml

aws es delete-elasticsearch-domain \
    --domain-name ${ES_DOMAIN_NAME}

eksctl delete iamserviceaccount \
    --name fluent-bit \
    --namespace logging \
    --cluster eksworkshop-eksctl \
    --wait

aws iam delete-policy   \
  --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluent-bit-policy"

kubectl delete namespace logging

rm -rf ~/environment/logging

unset ES_DOMAIN_NAME
unset ES_VERSION
unset ES_DOMAIN_USER
unset ES_DOMAIN_PASSWORD
unset FLUENTBIT_ROLE
unset ES_ENDPOINT
```
