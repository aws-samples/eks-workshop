---
title: "Simple Batch Workflow"
date: 2018-11-18T00:00:00-05:00
weight: 60
draft: false
---

### Simple Batch Workflow

Create the manifest `workflow-whalesay.yaml` and let's deploy the `whalesay` example from before using Argo.

```bash
cat <<EoF > ~/environment/batch_policy/workflow-whalesay.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: whalesay-
spec:
  entrypoint: whalesay
  templates:
  - name: whalesay
    container:
      image: docker/whalesay
      command: [cowsay]
      args: ["This is an Argo Workflow!"]
EoF
```

Now deploy the workflow using the argo CLI.

{{% notice note %}}
You can also run workflow specs directly using kubectl but the argo CLI provides syntax checking, nicer output, and requires less typing. For the equivalent `kubectl` commands, see [Argo CLI](https://argoproj.github.io/argo-workflows/walk-through/argo-cli/#argo-cli).
{{% /notice %}}

```bash
argo -n argo submit --watch ~/environment/batch_policy/workflow-whalesay.yaml
```

{{< output >}}
Name:                whalesay-rlssg
Namespace:           argo
ServiceAccount:      default
Status:              Succeeded
Conditions:
 Completed           True
Created:             Wed Jul 08 00:13:51 +0000 (3 seconds ago)
Started:             Wed Jul 08 00:13:51 +0000 (3 seconds ago)
Finished:            Wed Jul 08 00:13:54 +0000 (now)
Duration:            3 seconds
ResourcesDuration:   1s*(1 cpu),1s*(100Mi memory)

STEP               TEMPLATE  PODNAME         DURATION  MESSAGE
 ✔ whalesay-rlssg  whalesay  whalesay-rlssg  2s
{{< /output >}}

Confirm the output by running the following command:

```bash
argo -n argo logs $(argo -n argo list -o name)
```

{{< output >}}
whalesay-rlssg:  ___________________________
whalesay-rlssg: < This is an Argo Workflow! >
whalesay-rlssg:  ---------------------------
whalesay-rlssg:     \
whalesay-rlssg:      \
whalesay-rlssg:       \
whalesay-rlssg:                     ##        .
whalesay-rlssg:               ## ## ##       ==
whalesay-rlssg:            ## ## ## ##      ===
whalesay-rlssg:        /""""""""""""""""___/ ===
whalesay-rlssg:   ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
whalesay-rlssg:        \______ o          __/
whalesay-rlssg:         \    \        __/
whalesay-rlssg:           \____\______/
{{< /output >}}
