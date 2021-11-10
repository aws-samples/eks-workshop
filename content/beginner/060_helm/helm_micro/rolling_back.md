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
NAME                                READY   STATUS             RESTARTS   AGE
ecsdemo-crystal-56976b4dfd-9f2rf    1/1     Running            0          2m10s
ecsdemo-frontend-7f5ddc5485-8vqck   1/1     Running            0          2m10s
ecsdemo-nodejs-56487f6c95-mv5xv     0/1     ImagePullBackOff   0          6s
ecsdemo-nodejs-58977c4597-r6hvj     1/1     Running            0          2m10s
{{< /output >}}

Run `helm status workshop` to verify the `LAST DEPLOYED` timestamp. 

```sh
helm status workshop
```

{{< output >}}
NAME: workshop
LAST DEPLOYED: Fri Jul 16 13:53:22 2021
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
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

Validate `workshop` release status  and you will see a new revision that is based on the rollback.

```sh
helm status workshop
```

{{< output >}}
NAME: workshop
LAST DEPLOYED: Fri Jul 16 13:55:27 2021
NAMESPACE: default
STATUS: deployed
REVISION: 3
TEST SUITE: None

{{< /output >}}

Verify that the error is gone

```sh
kubectl get pods
```

{{< output >}}
NAME                                READY   STATUS    RESTARTS   AGE
ecsdemo-crystal-56976b4dfd-9f2rf    1/1     Running   0          6m
ecsdemo-frontend-7f5ddc5485-8vqck   1/1     Running   0          6m
ecsdemo-nodejs-58977c4597-r6hvj     1/1     Running   0          6m
{{< /output >}}
