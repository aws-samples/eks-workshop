---
title: "Deploy Fluentd"
date: 2018-08-07T08:30:11-07:00
weight: 30
---


```
mkdir ~/environment/fluentd
cat <<EoF> ~/environment/fluentd/fluentd_example.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluentd
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: fluentd
  namespace: kube-system
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: fluentd
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluentd
subjects:
- kind: ServiceAccount
  name: fluentd
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: kube-system
  labels:
    k8s-app: fluentd-cloudwatch
data:
  fluent.conf: |
    @include containers.conf
    @include systemd.conf

    <match fluent.**>
      @type null
    </match>
  containers.conf: |
    <source>
      @type tail
      @id in_tail_container_logs
      @label @containers
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag *
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>

    <label @containers>
      <filter **>
        @type kubernetes_metadata
        @id filter_kube_metadata
      </filter>

      <filter **>
        @type record_transformer
        @id filter_containers_stream_transformer
        <record>
          stream_name ${tag_parts[3]}
        </record>
      </filter>

      <match **>
        @type cloudwatch_logs
        @id out_cloudwatch_logs_containers
        region "#{ENV.fetch('REGION')}"
        log_group_name "/eks/#{ENV.fetch('CLUSTER_NAME')}/containers"
        log_stream_name_key stream_name
        remove_log_stream_name_key true
        auto_create_stream true
        <buffer>
          flush_interval 5
          chunk_limit_size 2m
          queued_chunks_limit_size 32
          retry_forever true
        </buffer>
      </match>
    </label>
  systemd.conf: |
    <source>
      @type systemd
      @id in_systemd_kubelet
      @label @systemd
      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      <entry>
        field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
        field_map_strict true
      </entry>
      path /run/log/journal
      pos_file /var/log/fluentd-journald-kubelet.pos
      read_from_head true
      tag kubelet.service
    </source>

    <source>
      @type systemd
      @id in_systemd_kubeproxy
      @label @systemd
      filters [{ "_SYSTEMD_UNIT": "kubeproxy.service" }]
      <entry>
        field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
        field_map_strict true
      </entry>
      path /run/log/journal
      pos_file /var/log/fluentd-journald-kubeproxy.pos
      read_from_head true
      tag kubeproxy.service
    </source>

    <source>
      @type systemd
      @id in_systemd_docker
      @label @systemd
      filters [{ "_SYSTEMD_UNIT": "docker.service" }]
      <entry>
        field_map {"MESSAGE": "message", "_HOSTNAME": "hostname", "_SYSTEMD_UNIT": "systemd_unit"}
        field_map_strict true
      </entry>
      path /run/log/journal
      pos_file /var/log/fluentd-journald-docker.pos
      read_from_head true
      tag docker.service
    </source>

    <label @systemd>
      <filter **>
        @type record_transformer
        @id filter_systemd_stream_transformer
        <record>
          stream_name ${tag}-${record["hostname"]}
        </record>
      </filter>

      <match **>
        @type cloudwatch_logs
        @id out_cloudwatch_logs_systemd
        region "#{ENV.fetch('REGION')}"
        log_group_name "/eks/#{ENV.fetch('CLUSTER_NAME')}/systemd"
        log_stream_name_key stream_name
        auto_create_stream true
        remove_log_stream_name_key true
        <buffer>
          flush_interval 5
          chunk_limit_size 2m
          queued_chunks_limit_size 32
          retry_forever true
        </buffer>
      </match>
    </label>
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd-cludwatch
  namespace: kube-system
  labels:
    k8s-app: fluentd-cloudwatch
spec:
  template:
    metadata:
      labels:
        k8s-app: fluentd-cloudwatch
    spec:
      serviceAccountName: fluentd
      terminationGracePeriodSeconds: 30
      # Because the image's entrypoint requires to write on /fluentd/etc but we mount configmap there which is read-only,
      # this initContainers workaround or other is needed.
      # See https://github.com/fluent/fluentd-kubernetes-daemonset/issues/90
      initContainers:
      - name: copy-fluentd-config
        image: busybox
        command: ['sh', '-c', 'cp /config-volume/..data/* /fluentd/etc']
        volumeMounts:
        - name: config-volume
          mountPath: /config-volume
        - name: fluentdconf
          mountPath: /fluentd/etc
      containers:
      - name: fluentd-cloudwatch
        image: fluent/fluentd-kubernetes-daemonset:v1.1-debian-cloudwatch
        env:
          - name: REGION
            value: us-west-2
          - name: CLUSTER_NAME
            value: eksworkshop-eksctl
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: config-volume
          mountPath: /config-volume
        - name: fluentdconf
          mountPath: /fluentd/etc
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: runlogjournal
          mountPath: /run/log/journal
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: fluentd-config
      - name: fluentdconf
        emptyDir: {}
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: runlogjournal
        hostPath:
          path: /run/log/journal
EoF
```
Explore fluentd_example.yaml to see what is being deployed. The Fluentd log agent configuration is locted in the Kubernetes ConfigMap. Fluentd will be deployed as a DaemonSet, i.e. one pod per worker node. In our case, a 3 node cluster is used and so 3 pods will be shown in the output when we deploy.
```
kubectl apply -f ~/environment/fluentd/fluentd_example.yaml
```

Watch for all of the pods to change to running status

```
kubectl get pods -w --namespace=kube-system
```

We are now ready to check that logs are arriving in [CloudWatch Logs](https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logStream:group=/eks/eksworkshop-eksctl/containers)




