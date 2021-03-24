---
title: "Clean up"
weight: 30
draft: false
---

#### Clean up steps

```bash
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

Make sure that all the CRD were deleted:

```bash
kubectl delete crd \
  configs.config.gatekeeper.sh \
  constraintpodstatuses.status.gatekeeper.sh \
  constrainttemplatepodstatuses.status.gatekeeper.sh \
  constrainttemplates.templates.gatekeeper.sh
```