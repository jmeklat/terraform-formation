# [Associate] Davidson Terraform Course - Lab 03 : resources/variables/locals/data/outputs
## Introduction
![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

In this lab, we will see :
  - Deploy resource
  - Use variables and locals
  - Use Data sources
  - Outputs
  - Resource dependencies

  ## Set up authentication

  First we need to authenticate and access our project
  ```bash
  gcloud auth application-default login --no-launch-browser
  ```
  Steps:
   - Answer **Yes** when prompted
   - Click the link that appears
   - Chose your account **(Make sure to select your Davidson account)**
   - Click allow
   - Copy the code and paste it back to cloud shell
   - Press Enter.

   <walkthrough-project-setup></walkthrough-project-setup>

  Run :
  ```bash
   gcloud auth application-default set-quota-project <walkthrough-project-id/>
  ```
  **Tips**: Socle Team should tell you which project you should select.

  This command will add a quota project in application default credentials and saves the credentials file to a temp directory :

  ![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

  Run :
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS=<path-to-cred-file>
  ```

## Deploy resource
Let's use what we have learned in previous labs to create a bigquery dataset.

Edit provider.tf and add the following bloc :

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/provider.tf">
    Open provider.tf
</walkthrough-editor-open-file>

```tf
provider "google" {
  project     = "<walkthrough-project-id/>"
  region      = "europe-west1"
}
```

Now, let's declare the resource :

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/main.tf">
    Open main.tf
</walkthrough-editor-open-file>

```tf
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "example_dataset"
  friendly_name               = "test"
  description                 = "This is a test"
  location                    = "EU"
}
```
dataset_id name should be unique in the project, to avoid potential conflict with other students we recomend you add your intials as suffix to the `dataset_id`
.

__Example__ : John Do -> dataset_id = "example_dataset_jdo"

Let's access the working directory :
```bash
cd ~/cloudshell_open/wam-tf-labs/associate/lab_03/iac/
```
Initialize terraform :
```bash
terraform init
```
Plan your infrastructure :
```bash
terraform plan
```
You should see similar output :
![tf_apply](https://storage.googleapis.com/bkt-public-images/tf_apply.png)

Let's deploy the resource :
```bash
terraform apply --auto-approve
```
[Go to Bigquery Dataset list page](https://console.cloud.google.com/bigquery?referrer=search&orgonly=true&project=<walkthrough-project-id/>)

Verify that the dataset is created successfully.

## Use variables

Let's make the code looks better by using variables.

Update `main.tf`
<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/main.tf">
    Open main.tf
</walkthrough-editor-open-file>

```tf
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.friendly_name
  description                 = var.description
  location                    = var.location
}
```

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/variables.tf">
    Open variables.tf
</walkthrough-editor-open-file>

```tf
variable "dataset_id" {
  type        = string
  description = "the dataset id"
}
variable "friendly_name" {
  type        = string
  description = "Dataset display name"
}
variable "description" {
  type        = string
  description = "Dataset description"
}
variable "location" {
  type        = string
  description = "the dataset location"
  default     = "EU"
}
```

Update `terraform.tfvars`

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/terraform.tfvars">
    Open terraform.tfvars
</walkthrough-editor-open-file>

```tf
dataset_id    = "example_dataset"
friendly_name = "test"
description   = "This is a test"
location      = "EU"
```
**Notice** : Make sure to keep the same `dataset_id` as before (which means don't forget to add your initials).

__Example__ : Your name is John Do -> dataset_id = "example_dataset_jdo"

Run
```bash
terraform plan
```

You should see `No changes`. Your infrastructure matches the configuration."

## Use locals
<em>Terraform local values (or "locals") assign a name to an expression or value. Using locals **simplifies** your Terraform configuration – since you can reference the local **multiple** times, you **reduce** duplication in your code. Locals can also help you write **more readable** configuration by using meaningful names **rather** than hard-coding values.</em>

We have a resource naming convention within **DAVIDSON** organization that says that a Bigquery Dataset should always be prefixed with `dav_bqd_`. We can use local variables to ensure that we meet this requirement:

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/main.tf">
    Update main.tf
</walkthrough-editor-open-file>

```tf
locals {
  org_dataset_id = "dav_bqd_${var.dataset_id}"

}
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = local.org_dataset_id
  friendly_name               = var.friendly_name
  description                 = var.description
  location                    = var.location
}
```
Run
```bash
terraform plan
```
Since the dataset id changes, the plan output indicates that a new dataset will be created and the old dataset is going to be destroyed.
`Plan: 1 to add, 0 to change, 1 to destroy.`

Let's apply the change :
```bash
terraform apply --auto-approve
```
[Go to Bigquery Dataset list page](https://console.cloud.google.com/bigquery?referrer=search&orgonly=true&project=<walkthrough-project-id/>)

Verify that the new dataset is created successfully and the old datset is deleted.

## Resource dependencies
Let's create a table in the dataset previously created. Add the table definition to main.tf :

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/main.tf">
    Update main.tf :
</walkthrough-editor-open-file>

```tf
resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  deletion_protection = false
  table_id   = "bar"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "permalink",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The Permalink"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "State where the head office is located"
  }
]
EOF

}
```

```bash
terraform plan
```

```bash
terraform apply --auto-approve
```

[Go to Bigquery Dataset list page](https://console.cloud.google.com/bigquery?referrer=search&orgonly=true&project=<walkthrough-project-id/>)

Expand the dataset and verify that the table is created successfully.

**Tips:** Resource dependency is simply referencing a resource in another resource definition bloc :

`dataset_id = google_bigquery_dataset.dataset.dataset_id`

In that case, terraform will create the bigquery Dataset prior to creating the table.

## Data source
<em>You can use Data Sources to get existing resource information created in GCP by other means (other than the current terraform code).</em>

We have created a service account named `sac-lab-terraform`. Let's use the data source `google_service_account` data source to get the email address of that service account and grant it the role "Bigquery Data Viewer" to be able to access our dataset.

Add the following data source to `main.tf`

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/main.tf">
    Update main.tf
</walkthrough-editor-open-file>

```tf
data "google_service_account" "lab_sa" {
  account_id = "sac-labo-training"
}

resource "google_project_iam_member" "project" {
  project = "<walkthrough-project-id/>"
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${data.google_service_account.lab_sa.email}"
}
```

Let's apply the changes:
```bash
terraform plan
```
```bash
terraform apply --auto-approve
```

Go to Google Cloud console > IAM & Admin, verify that the service account has the `Bigquery Data Viewer role`. (Make sure you select the project `<walkthrough-project-id/>`)

## Terraform outputs

<em>Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use. Output values are similar to return values in programming languages.</em>

Let's export some information about the dataset we have created in this lab. You can find the list of attributes that can be exported
[here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset#attributes-reference).

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_03/iac/outputs.tf">
    Edit outputs.tf
</walkthrough-editor-open-file>

```tf
output "id" {
  value = google_bigquery_dataset.dataset.dataset_id
}

output "self_link" {
  value = google_bigquery_dataset.dataset.self_link
}
```

Let's apply the changes and see what we get :
```bash
terraform plan
```
```bash
terraform apply --auto-approve
```
You should see similar output :
![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/output.png)

We will explore in more details how to use output values in the code in another advanced lab about Terraform modules.


## Cleanup

```bash
terraform destroy --auto-approve
```
In the Google Cloud console, go to the Cloud Storage Buckets page and verify that the bucket is no longer existing.

You're all set!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
