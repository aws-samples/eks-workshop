---
title: "Submit a job in Argo"
date: 2021-06-15T00:00:00-00:00
weight: 50
---

1. Get Argo login details by running this script. The authentication token refreshes every 10 minutes (configurable). Run the script again if timeout. Use your CFN stack name if it is different.

    ```bash
    ARGO_URL=$(aws cloudformation describe-stacks --stack-name SparkOnEKS --query "Stacks[0].Outputs[?OutputKey=='ARGOURL'].OutputValue" --output text)
    LOGIN=$(argo auth token)
    echo -e "\nArgo website:\n$ARGO_URL\n" && echo -e "Login token:\n$LOGIN\n"
    ```

2. Use a browser to open the Argo link and use the token to log in.
3. Click on the Workflows side menu then **SUBMIT NEW WORKFLOW** button.
    ![Argo](/images/sql-etl/argo-sidemenu.png)
4. Go to Edit using full workflow options, and replace the content by the followings.

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Workflow
    metadata:
    generateName: nyctaxi-job-
    namespace: spark
    spec:
    serviceAccountName: arcjob
    entrypoint: nyctaxi
    templates:
    - name: nyctaxi
        dag:
        tasks:
            - name: step1-query
            templateRef:
                name: spark-template
                template: sparkLocal  
            arguments:
                parameters:
                - name: jobId
                value: nyctaxi  
                - name: tags
                value: "project=sqlbasedetl, owner=myowner, costcenter=66666"  
                - name: configUri
                value: https://raw.githubusercontent.com/tripl-ai/arc-starter/master/examples/kubernetes/nyctaxi.ipynb
                - name: parameters
                value: "--ETL_CONF_DATA_URL=s3a://nyc-tlc/trip*data \
                --ETL_CONF_JOB_URL=https://raw.githubusercontent.com/t
    ```

5. Finally, click **CREATE**. Select a pod (dot) to check the job status and application logs.
