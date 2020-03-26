---
title: "Advanced Batch Workflow"
date: 2018-11-18T00:00:00-05:00
weight: 70
draft: false
---

### Advanced Batch Workflow

Let's take a look at a more complex workflow, involving passing artifacts between jobs, multiple dependencies, etc.

Save the below manifest as `teardrop.yaml` using your favorite editor.

```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: teardrop-
spec:
  entrypoint: teardrop
  templates:
  - name: create-chain
    container:
      image: alpine:latest
      command: ["sh", "-c"]
      args: ["echo '' >> /tmp/message"]
    outputs:
      artifacts:
      - name: chain
        path: /tmp/message
  - name: whalesay
    inputs:
      parameters:
      - name: message
      artifacts:
      - name: chain
        path: /tmp/message
    container:
      image: docker/whalesay
      command: ["sh", "-c"]
      args: ["echo Chain: ; cat /tmp/message* | sort | uniq | tee /tmp/message; cowsay This is Job {{inputs.parameters.message}}! ; echo {{inputs.parameters.message}} >> /tmp/message"]
    outputs:
      artifacts:
      - name: chain
        path: /tmp/message
  - name: whalesay-reduce
    inputs:
      parameters:
      - name: message
      artifacts:
      - name: chain-0
        path: /tmp/message.0
      - name: chain-1
        path: /tmp/message.1
    container:
      image: docker/whalesay
      command: ["sh", "-c"]
      args: ["echo Chain: ; cat /tmp/message* | sort | uniq | tee /tmp/message; cowsay This is Job {{inputs.parameters.message}}! ; echo {{inputs.parameters.message}} >> /tmp/message"]
    outputs:
      artifacts:
      - name: chain
        path: /tmp/message
  - name: teardrop
    dag:
      tasks:
      - name: create-chain
        template: create-chain
      - name: Alpha
        dependencies: [create-chain]
        template: whalesay
        arguments:
          parameters: [{name: message, value: Alpha}]
          artifacts:
            - name: chain
              from: "{{tasks.create-chain.outputs.artifacts.chain}}"
      - name: Bravo
        dependencies: [Alpha]
        template: whalesay
        arguments:
          parameters: [{name: message, value: Bravo}]
          artifacts:
            - name: chain
              from: "{{tasks.Alpha.outputs.artifacts.chain}}"
      - name: Charlie
        dependencies: [Alpha]
        template: whalesay
        arguments:
          parameters: [{name: message, value: Charlie}]
          artifacts:
            - name: chain
              from: "{{tasks.Alpha.outputs.artifacts.chain}}"
      - name: Delta
        dependencies: [Bravo]
        template: whalesay
        arguments:
          parameters: [{name: message, value: Delta}]
          artifacts:
            - name: chain
              from: "{{tasks.Bravo.outputs.artifacts.chain}}"
      - name: Echo
        dependencies: [Bravo, Charlie]
        template: whalesay-reduce
        arguments:
          parameters: [{name: message, value: Echo}]
          artifacts:
            - name: chain-0
              from: "{{tasks.Bravo.outputs.artifacts.chain}}"
            - name: chain-1
              from: "{{tasks.Charlie.outputs.artifacts.chain}}"
      - name: Foxtrot
        dependencies: [Charlie]
        template: whalesay
        arguments:
          parameters: [{name: message, value: Foxtrot}]
          artifacts:
            - name: chain
              from: "{{tasks.create-chain.outputs.artifacts.chain}}"
      - name: Golf
        dependencies: [Delta, Echo]
        template: whalesay-reduce
        arguments:
          parameters: [{name: message, value: Golf}]
          artifacts:
            - name: chain-0
              from: "{{tasks.Delta.outputs.artifacts.chain}}"
            - name: chain-1
              from: "{{tasks.Echo.outputs.artifacts.chain}}"
      - name: Hotel
        dependencies: [Echo, Foxtrot]
        template: whalesay-reduce
        arguments:
          parameters: [{name: message, value: Hotel}]
          artifacts:
            - name: chain-0
              from: "{{tasks.Echo.outputs.artifacts.chain}}"
            - name: chain-1
              from: "{{tasks.Foxtrot.outputs.artifacts.chain}}"
```

This workflow uses a [Directed Acyclic Graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph) (DAG) to explicitly define job dependencies. Each job in the workflow calls a `whalesay` template and passes a parameter with a unique name. Some jobs call a `whalesay-reduce` template which accepts multiple artifacts and combines them into a single artifact.

Each job in the workflow pulls the artifact(s) and lists them in the "Chain", then calls `whalesay` for the current job. Each job will then have a list of the previous job dependency chain (list of all jobs that had to complete before current job could run).

Run the workflow.

```bash
argo submit --watch teardrop.yaml
```

{{< output >}}
Name:                teardrop-jfg5w
Namespace:           default
ServiceAccount:      default
Status:              Succeeded
Created:             Sat Nov 17 16:01:42 -0500 (7 minutes ago)
Started:             Sat Nov 17 16:01:42 -0500 (7 minutes ago)
Finished:            Sat Nov 17 16:03:35 -0500 (5 minutes ago)
Duration:            1 minute 53 seconds

STEP               PODNAME                    DURATION  MESSAGE
 ✔ teardrop-jfg5w                                       
 ├-✔ create-chain  teardrop-jfg5w-3938249022  3s        
 ├-✔ Alpha         teardrop-jfg5w-3385521262  6s        
 ├-✔ Bravo         teardrop-jfg5w-1878939134  35s       
 ├-✔ Charlie       teardrop-jfg5w-3753534620  35s       
 ├-✔ Foxtrot       teardrop-jfg5w-2036090354  5s        
 ├-✔ Delta         teardrop-jfg5w-37094256    34s       
 ├-✔ Echo          teardrop-jfg5w-4165010455  31s       
 ├-✔ Hotel         teardrop-jfg5w-2342859904  4s        
 └-✔ Golf          teardrop-jfg5w-1687601882  30s       
{{< /output >}}

Continue to the [Argo Dashboard](/advanced/410_batch/dashboard/) to explore this model further.
