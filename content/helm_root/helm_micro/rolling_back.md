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

The rolling upgrade will begin by creating a new nodejs pod with the new image. The new `ecsdemo-nodejs` Pod should fail to pull non-existing image. Run `helm status` command to see the `ImagePullBackOff` error:

```
helm status workshop
```

#### Rollback the failed upgrade

Now we are going to rollback the application to the previous working release revision.

First, list Helm release revisions:

```
helm history workshop
```

Then, rollback to the previous application revision (can rollback to any revision too):

```sh
# rollback to the 1st revision
helm rollback workshop 1
```

Validate `workshop` release status with:

```
helm status workshop
```
