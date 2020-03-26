---
title: "Rolling Back"
date: 2018-08-07T08:30:11-07:00
weight: 50
---

Mistakes will happen during deployment, and when they do, Helm makes it easy to undo, or "roll back" to the previously deployed version.

#### Update the demo application chart with a breaking change

Open **values.yaml** and modify the image name under `nodejs.image` to **brentley/ecsdemo-nodejs-non-existing**. This image does not exist, so this will break our deployment.

Deploy the updated demo application chart:
```sh
helm upgrade workshop ~/environment/eksdemo
```

The rolling upgrade will begin by creating a new nodejs pod with the new image. The new `ecsdemo-nodejs` Pod should fail to pull non-existing image. Run `kubectl get pods` to see the `ImagePullBackOff` error.

```sh
kubectl get pods
```
{{< output >}}
NAME                               READY   STATUS             RESTARTS   AGE
ecsdemo-crystal-844d84cb86-56gpz   1/1     Running            0          23m
ecsdemo-crystal-844d84cb86-5vvcg   1/1     Running            0          23m
ecsdemo-crystal-844d84cb86-d2plf   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-dpcsl   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-lzlwh   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-psg69   1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-6cnzl    1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-fbcjv    1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-v88jn    1/1     Running            0          23m
ecsdemo-nodejs-7c6575b56c-hrrsp    0/1     ImagePullBackOff   0          15m
{{< /output >}}

Run `helm status workshop` to verify the `LAST DEPLOYED` timestamp. 

```sh
helm status workshop
```

{{< output >}}
LAST DEPLOYED: Tue Feb 18 22:14:00 2020
NAMESPACE: default
STATUS: deployed
...
{{< /output >}}

This should correspond to the last entry on `helm history workshop`

```sh
helm history workshop
```

#### Rollback the failed upgrade

Now we are going to rollback the application to the previous working release revision.

First, list Helm release revisions:

```sh
helm history workshop
```

Then, rollback to the previous application revision (can rollback to any revision too):

```sh
# rollback to the 1st revision
helm rollback workshop 1
```

Validate `workshop` release status with:

```sh
helm status workshop
```

Verify that the error is gone

```sh
kubectl get pods
```

{{< output >}}
NAME                               READY   STATUS             RESTARTS   AGE
ecsdemo-crystal-844d84cb86-56gpz   1/1     Running            0          23m
ecsdemo-crystal-844d84cb86-5vvcg   1/1     Running            0          23m
ecsdemo-crystal-844d84cb86-d2plf   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-dpcsl   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-lzlwh   1/1     Running            0          23m
ecsdemo-frontend-6df6d9bb9-psg69   1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-6cnzl    1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-fbcjv    1/1     Running            0          23m
ecsdemo-nodejs-6fdf964f5f-v88jn    1/1     Running            0          23m
{{< /output >}}
