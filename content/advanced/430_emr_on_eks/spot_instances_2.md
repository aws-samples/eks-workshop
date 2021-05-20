---
title: "Using Spot Instances Part 2 - Run Sample Workload"
date: 2021-05-11T13:38:18+08:00
weight: 51
draft: false
---

### Spark Pod Template 
With Amazon EMR versions `5.33.0 and later`, Amazon EMR on EKS supports pod template feature in Spark. Pod templates are specifications that determine how to run each pod. You can use pod template files to define the driver or executor pod’s configurations that Spark configurations do not support.

{{% notice info %}}
For more information about the pod templates support in EMR on EKS, see [Pod Templates](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/pod-templates.html).
{{% /notice %}}

To reduce costs, you can schedule Spark driver tasks to run on On-Demand instances while scheduling Spark executor tasks to run on Spot instances.

With pod templates you can define label `eks.amazonaws.com/capacityType` as a [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/), so that you can schedule Spark driver pods on On-demand Instances and Spark executor pods on the Spot Instances.

Now, you will create a sample pod template for Spark Driver. Using nodeSelector `eks.amazonaws.com/capacityType: ON_DEMAND` this will run on On-demand Instances.
```sh
cat > spark_driver_pod_template.yml <<EOF 
apiVersion: v1
kind: Pod
spec:
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  nodeSelector:
    eks.amazonaws.com/capacityType: ON_DEMAND
  containers:
  - name: spark-kubernetes-driver # This will be interpreted as Spark driver container
EOF
```

Next, you will create a sample pod template for Spark executors. Using nodeSelector `eks.amazonaws.com/capacityType: SPOT` this will run on Spot Instances.
```sh
cat > spark_executor_pod_template.yml <<EOF 
apiVersion: v1
kind: Pod
spec:
  volumes:
    - name: source-data-volume
      emptyDir: {}
    - name: metrics-files-volume
      emptyDir: {}
  nodeSelector:
    eks.amazonaws.com/capacityType: SPOT
  containers:
  - name: spark-kubernetes-executor # This will be interpreted as Spark executor container
EOF
```

Let's upload sample pod templates and python script to s3 bucket. 

```sh
aws s3 cp threadsleep.py ${s3DemoBucket}
aws s3 cp spark_driver_pod_template.yml ${s3DemoBucket}/pod_templates/
aws s3 cp spark_executor_pod_template.yml ${s3DemoBucket}/pod_templates/
```

Let's create a json input file for emr-container cli.

```sh
cat > request-spot.json <<EOF 
{
    "name": "pi-spot",
    "virtualClusterId": "{virtualClusterId}",
    "executionRoleArn": "{executionRoleArn}",
    "releaseLabel": "emr-5.33.0-latest",
    "jobDriver": {
        "sparkSubmitJobDriver": {
            "entryPoint": "{s3DemoBucket}/threadsleep.py",
            "sparkSubmitParameters": "--conf spark.kubernetes.driver.podTemplateFile={s3DemoBucket}/pod_templates/spark_driver_pod_template.yml \
            --conf spark.kubernetes.executor.podTemplateFile={s3DemoBucket}/pod_templates/spark_executor_pod_template.yml \
            --conf spark.executor.instances=15 \
            --conf spark.executor.memory=2G \
            --conf spark.executor.cores=2 \
            --conf spark.driver.cores=1"
        }
    },
    "configurationOverrides": {
        "applicationConfiguration": [
            {
                "classification": "spark-defaults",
                "properties": {
                  "spark.dynamicAllocation.enabled": "false",
                  "spark.kubernetes.executor.deleteOnTermination": "true"
                }
            }
        ],
        "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
                "logGroupName": "/emr-on-eks/eksworkshop-eksctl",
                "logStreamNamePrefix": "pi"
            },
            "s3MonitoringConfiguration": {
                "logUri": "{s3DemoBucket}/"
            }
        }
    }
}
EOF
```
Next we will replace placeholder variables in the the request-spot.json file

```sh
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?state=='RUNNING'].id" --output text)
export EMR_ROLE_ARN=$(aws iam get-role --role-name EMRContainers-JobExecutionRole --query Role.Arn --output text)

sed -i "s|{virtualClusterId}|${VIRTUAL_CLUSTER_ID}|g" request-spot.json
sed -i "s|{executionRoleArn}|${EMR_ROLE_ARN}|g" request-spot.json
sed -i "s|{s3DemoBucket}|${s3DemoBucket}|g" request-spot.json

```

Finally, let's trigger the Spark job

```
aws emr-containers start-job-run --cli-input-json file://request-spot.json
```

You will be able to see the completed job in EMR console. 

Let's check the pods deployed on On-Demand Instances and should now see Spark driver pods running on On-Demand instances.

```sh
 for n in $(kubectl get nodes -l eks.amazonaws.com/capacityType=ON_DEMAND --no-headers | cut -d " " -f1); do echo "Pods on instance ${n}:";kubectl get pods -n spark  --no-headers --field-selector spec.nodeName=${n} ; echo ; done
```

Let's check the pods deployed on Spot Instances and should now see Spark executor pods running on Spot Instances.

```sh
 for n in $(kubectl get nodes -l eks.amazonaws.com/capacityType=SPOT --no-headers | cut -d " " -f1); do echo "Pods on instance ${n}:";kubectl get pods -n spark  --no-headers --field-selector spec.nodeName=${n} ; echo ; done
```

