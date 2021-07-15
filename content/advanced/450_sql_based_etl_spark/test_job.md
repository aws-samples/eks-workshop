---
title: "Test a job in Jupyter Notebook"
date: 2021-06-15T00:00:00-00:00
weight: 40
---

1. Log in with the details from the previous step output, it should look like this.
   ![Login](/images/sql-etl/login-details.png)
2. For Server Options, select the default server size.
3. The JupyterHub is configured to synchronize the latest code from this project GitHub repo. In practice, you must save all changes to a source repository in order to schedule your ETL job to run.

4. Open a sample job **spark-on-eks/source/example/notebook/scd2-job.ipynb** from your notebook instance.
5. Choose the refresh icon to see the file if needed.
6. Run each block and observe the result. The job outputs a table to support the Slowly
Changing Dimension Type 2 (SCD2) business need.

{{% notice info %}}
Following the security best practices, the notebook session times out if idle for 30 minutes.
You may need to refresh your web browser and log in again.
{{% /notice %}}
