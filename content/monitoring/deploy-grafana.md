---
title: "Deploy Grafana"
date: 2018-10-14T20:54:13-04:00
weight: 15
draft: false
---

#### Download Grafana and update configuration

```sh
curl -o grafana-values.yaml https://raw.githubusercontent.com/helm/charts/master/stable/grafana/values.yaml
```

You will make **_three_** edits to grafana-values.yaml. Search for **storageClassName**, uncomment and change the value to **"prometheus"**. Search for **adminPassword**, uncomment and change the password to **"EKS!sAWSome"** or something similar. Make a note of this password as you will need it for logging into grafana dashboard later

The third edit you will do is for adding Prometheus as a datasource. Search for **datasources.yaml** and uncomment entire block, update prometheus to the endpoint referred earlier by helm response. The configuration will look similar to below

```yaml
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus-server.prometheus.svc.cluster.local
     access: proxy
     isDefault: true
```

Now let's expose Grafana dashboard using AWS ELB service. Search for **service:**, and update the value of **type: ClusterIP** to **type: LoadBalancer**

{{% expand "Expand here to see the complete yaml"%}}
```yaml
rbac:
  create: true
  pspEnabled: true
serviceAccount:
  create: true
  name:

replicas: 1

deploymentStrategy: RollingUpdate

readinessProbe:
  httpGet:
    path: /api/health
    port: 3000

livenessProbe:
  httpGet:
    path: /api/health
    port: 3000
  initialDelaySeconds: 60
  timeoutSeconds: 30
  failureThreshold: 10

image:
  repository: grafana/grafana
  tag: 5.3.1
  pullPolicy: IfNotPresent

  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ##
  # pullSecrets:
  #   - myRegistrKeySecretName

securityContext:
  runAsUser: 472
  fsGroup: 472

downloadDashboardsImage:
  repository: appropriate/curl
  tag: latest
  pullPolicy: IfNotPresent

## Pod Annotations
# podAnnotations: {}

## Deployment annotations
# annotations: {}

## Expose the grafana service to be accessed from outside the cluster (LoadBalancer service).
## or access it from within the cluster (ClusterIP service). Set the service type and the port to serve it.
## ref: http://kubernetes.io/docs/user-guide/services/
##
service:
  type: LoadBalancer
  port: 80
  annotations: {}
  labels: {}

ingress:
  enabled: false
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  labels: {}
  path: /
  hosts:
    - chart-example.local
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

resources: {}
#  limits:
#    cpu: 100m
#    memory: 128Mi
#  requests:
#    cpu: 100m
#    memory: 128Mi

## Node labels for pod assignment
## ref: https://kubernetes.io/docs/user-guide/node-selection/
#
nodeSelector: {}

## Tolerations for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
tolerations: []

## Affinity for pod assignment
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
##
affinity: {}

## Enable persistence using Persistent Volume Claims
## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
##
persistence:
  enabled: false
  storageClassName: prometheus
  # accessModes:
  #   - ReadWriteOnce
  # size: 10Gi
  # annotations: {}
  # subPath: ""
  # existingClaim:

adminUser: admin
adminPassword: EKS!sAWSome

## Use an alternate scheduler, e.g. "stork".
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
# schedulerName:

## Extra environment variables that will be pass onto deployment pods
env: {}

## The name of a secret in the same kubernetes namespace which contain values to be added to the environment
## This can be useful for auth tokens, etc
envFromSecret: ""

## Additional grafana server secret mounts
# Defines additional mounts with secrets. Secrets must be manually created in the namespace.
extraSecretMounts: []
  # - name: secret-files
  #   mountPath: /etc/secrets
  #   secretName: grafana-secret-files
  #   readOnly: true

## Pass the plugins you want installed as a list.
##
plugins: []
  # - digrich-bubblechart-panel
  # - grafana-clock-panel

## Configure grafana datasources
## ref: http://docs.grafana.org/administration/provisioning/#datasources
##
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true

## Configure grafana dashboard providers
## ref: http://docs.grafana.org/administration/provisioning/#dashboards
##
## `path` must be /var/lib/grafana/dashboards/<provider_name>
##
dashboardProviders: {}
#  dashboardproviders.yaml:
#    apiVersion: 1
#    providers:
#    - name: 'default'
#      orgId: 1
#      folder: ''
#      type: file
#      disableDeletion: false
#      editable: true
#      options:
#        path: /var/lib/grafana/dashboards/default

## Configure grafana dashboard to import
## NOTE: To use dashboards you must also enable/configure dashboardProviders
## ref: https://grafana.com/dashboards
##
## dashboards per provider, use provider name as key.
##
dashboards: {}
#  default:
#    some-dashboard:
#      json: |
#        $RAW_JSON
#    prometheus-stats:
#      gnetId: 2
#      revision: 2
#      datasource: Prometheus
#    local-dashboard:
#      url: https://example.com/repository/test.json

## Reference to external ConfigMap per provider. Use provider name as key and ConfiMap name as value.
## A provider dashboards must be defined either by external ConfigMaps or in values.yaml, not in both.
## ConfigMap data example:
##
## data:
##   example-dashboard.json: |
##     RAW_JSON
##
dashboardsConfigMaps: {}
#  default: ""

## Grafana's primary configuration
## NOTE: values in map will be converted to ini format
## ref: http://docs.grafana.org/installation/configuration/
##
grafana.ini:
  paths:
    data: /var/lib/grafana/data
    logs: /var/log/grafana
    plugins: /var/lib/grafana/plugins
    provisioning: /etc/grafana/provisioning
  analytics:
    check_for_updates: true
  log:
    mode: console
  grafana_net:
    url: https://grafana.net
## LDAP Authentication can be enabled with the following values on grafana.ini
## NOTE: Grafana will fail to start if the value for ldap.toml is invalid
  # auth.ldap:
  #   enabled: true
  #   allow_sign_up: true
  #   config_file: /etc/grafana/ldap.toml

## Grafana's LDAP configuration
## Templated by the template in _helpers.tpl
## NOTE: To enable the grafana.ini must be configured with auth.ldap.enabled
## ref: http://docs.grafana.org/installation/configuration/#auth-ldap
## ref: http://docs.grafana.org/installation/ldap/#configuration
ldap:
  # `existingSecret` is a reference to an existing secret containing the ldap configuration
  # for Grafana in a key `ldap-toml`.
  existingSecret: ""
  # `config` is the content of `ldap.toml` that will be stored in the created secret
  config: ""
  # config: |-
  #   verbose_logging = true

  #   [[servers]]
  #   host = "my-ldap-server"
  #   port = 636
  #   use_ssl = true
  #   start_tls = false
  #   ssl_skip_verify = false
  #   bind_dn = "uid=%s,ou=users,dc=myorg,dc=com"

## Grafana's SMTP configuration
## NOTE: To enable, grafana.ini must be configured with smtp.enabled
## ref: http://docs.grafana.org/installation/configuration/#smtp
smtp:
  # `existingSecret` is a reference to an existing secret containing the smtp configuration
  # for Grafana in keys `user` and `password`.
  existingSecret: ""

## Sidecars that collect the configmaps with specified label and stores the included files them into the respective folders
## Requires at least Grafana 5 to work and can't be used together with parameters dashboardProviders, datasources and dashboards
sidecar:
  image: kiwigrid/k8s-sidecar:0.0.3
  imagePullPolicy: IfNotPresent
  resources:
#   limits:
#     cpu: 100m
#     memory: 100Mi
#   requests:
#     cpu: 50m
#     memory: 50Mi
  dashboards:
    enabled: false
    # label that the configmaps with dashboards are marked with
    label: grafana_dashboard
    # folder in the pod that should hold the collected dashboards
    folder: /tmp/dashboards
  datasources:
    enabled: false
    # label that the configmaps with datasources are marked with
    label: grafana_datasource

```
{{%/expand%}}

#### Deploy grafana

```sh
helm install -f grafana-values.yaml stable/grafana --name grafana --namespace grafana
```

Run the command to check if Grafana is running properly

```sh
kubectl get all -n grafana
```

You should see similar results. They should all be Ready and Available

```text
NAME                          READY     STATUS    RESTARTS   AGE
pod/grafana-b9697f8b5-t9w4j   1/1       Running   0          2m

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
service/grafana   LoadBalancer   10.100.49.172   abe57f85de73111e899cf0289f6dc4a4-1343235144.us-west-2.elb.amazonaws.com   80:31570/TCP   3m


NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana   1         1         1            1           2m

NAME                                DESIRED   CURRENT   READY     AGE
replicaset.apps/grafana-b9697f8b5   1         1         1         2m
```

You can get Grafana ELB URL using this command. Copy & Paste the value into browser to access Grafana web UI

```sh
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"
```
