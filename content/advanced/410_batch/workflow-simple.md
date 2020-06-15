---
title: "Simple Batch Workflow"
date: 2018-11-18T00:00:00-05:00
weight: 60
draft: false
---

### Simple Batch Workflow

Save the below manifest as 'workflow-whalesay.yaml' using your favorite editor and let's deploy the `whalesay` example from before using Argo.

```
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
```

Now deploy the workflow using the argo CLI.

{{% notice note %}}
You can also run workflow specs directly using kubectl but the argo CLI provides syntax checking, nicer output, and requires less typing. For the equivalent `kubectl` commands, see [Argo CLI](https://argoproj.github.io/docs/argo/examples/readme.html#argo-cli).
{{% /notice %}}

```bash
argo submit --watch workflow-whalesay.yaml
```

{{< output >}}
Name:                whalesay-2kfxb
Namespace:           default
ServiceAccount:      default
Status:              Succeeded
Created:             Sat Nov 17 10:32:13 -0500 (3 seconds ago)
Started:             Sat Nov 17 10:32:13 -0500 (3 seconds ago)
Finished:            Sat Nov 17 10:32:16 -0500 (now)
Duration:            3 seconds

STEP               PODNAME         DURATION  MESSAGE
 ✔ whalesay-2kfxb  whalesay-2kfxb  2s        
{{< /output >}}
Make a note of the workflow's name from your output (It should be similar to whalesay-xxxxx).

Confirm the output by running the following command, substituting name of your workflow for "whalesay-xxxxx":

```bash
argo logs whalesay-xxxxx
```

{{< output >}}
 ___________________________ 
< This is an Argo Workflow! >
 --------------------------- 
    \
     \
      \     
                    ##        .            
              ## ## ##       ==            
           ## ## ## ##      ===            
       /""""""""""""""""___/ ===        
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
       \______ o          __/            
        \    \        __/             
          \____\______/   
{{< /output >}}
