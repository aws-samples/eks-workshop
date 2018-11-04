---
title: "Deploy The Spot Interrupt Handler"
date: 2018-08-07T12:32:40-07:00
weight: 20
draft: false
---

We need to deploy the Spot Interrupt Handler on each Spot Instance.


```
      nodeSelector:
        lifecycle: Ec2Spot
```


{{%attachments title="Related files" pattern=".yml"/%}}
