# [Advanced] DAVIDSON Terraform Course - Lab 02 : Meta arguments
## Introduction
![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

In this lab you will learn about the following Terraform **meta-arguments**:
- count
- depends_on
- foreach

We will also take a look on how to chain resources when using foreach.

## Set up authentication

  First we need to authenticate and access our project
  ```bash
  gcloud auth application-default login --no-launch-browser
  ```
  Steps:
   - Answer **Yes** when prompted
   - Click the link that appears
   - Chose your account **(Make sure to select your Sephora account)**
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

  ![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/cred_path.png)

  Run :
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS=<path-to-cred-file>
  ```

## How to use count meta-argument:
The count meta-argument accepts a number and creates the number of instances of the resource specified.
When each instance is created, it has its own distinct infrastructure object associated with it, so each can be managed separately. When the configuration is applied, each object can be created, destroyed, or updated as appropriate.

Let's see how it works:

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_02/iac/provider.tf">
    Edit provider.tf
</walkthrough-editor-open-file>
```tf
provider "google" {
  project     = "<walkthrough-project-id/>"
  region      = "europe-west1"
}
```

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_02/iac/main.tf">
    Edit main.tf
</walkthrough-editor-open-file>
```tf
resource "google_storage_bucket" "bucket" {
  count       = 3
  name        = "tf-lab-advabced-bucket-${count.index}"
  location    = "europe-west1"
  storage_class = "STANDARD"
}
```

**Tips** : Bucket name should be unique in the project, to avoid potential conflict with other students we recommend you to add your intials as suffix.
.

_*Example*_ : John Do -> name = "tf-lab-advabced-bucket-${count.index}-jdo"

Let's access the working directory :
```bash
cd ~/cloudshell_open/wam-tf-labs/advanced/lab_02/iac/
```
Initialize terraform :
```bash
terraform init
```
Plan your infrastructure :
```bash
terraform plan
```
Terraform should tell you that 3 buckets are going to be deployed in your project :
![tf_apply](https://storage.googleapis.com/bkt-public-images/tfplan_count.png)

Let's deploy the resource :
```bash
terraform apply --auto-approve
```

Verify that the buckets are created successfully.

[Buckets list page](https://console.cloud.google.com/storage/browser?hl=fr&project=<walkthrough-project-id/>)

**Notice**: The count.index variable is a special variable that represents the current index of an iteration when using the count meta-argument.

In the example we provided earlier, we used count.index to dynamically generate the bucket names. Let's take a closer look at how it works:

In this code snippet, we set count to 3, indicating that we want to create three instances of the google_storage_bucket resource.

Inside the resource block, we use the name parameter to generate the bucket names dynamically. By appending ${count.index} to the static part of the name, we create unique bucket names for each iteration. The value of count.index starts from 0 and increments by 1 for each iteration.

Here's how the bucket names will be generated in this case:

- First iteration: "tf-lab-advabced-bucket-0"
- Second iteration: "tf-lab-advabced-bucket-1"
- Third iteration: "tf-lab-advabced-bucket-2"

By leveraging count.index, you can create resources with dynamically generated names, tags, labels, or any other attribute that requires uniqueness or variation based on the iteration index.

Keep in mind that you can also use other expressions and functions in conjunction with count.index to further customize your resource configurations.

## How to use depends_on meta-argument:

The **depends_on** meta-argument is used in Terraform to define explicit dependencies between resources. It allows you to specify that one resource depends on the successful creation or modification of another resource.

Example:

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_02/iac/main.tf">
    Edit main.tf
</walkthrough-editor-open-file>

```tf
resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "my-dataset"
  location   = "EU"
  depends_on    = [google_project_service.bigquery]
}
```

**Tips** : Dataset_id should be unique in the project, to avoid potential conflict with other students we recommend you to add your intials as suffix.
.

_*Example*_ : John Do -> dataset_id = "my-dataset-jdo"

**Notice**: We have two resources: `google_project_service` and `google_bigquery_dataset`. The `google_project_service` resource enables the BigQuery API for your GCP project, and the `google_bigquery_dataset` resource deploys a BigQuery dataset.

we use the **depends_on** meta-argument in the google_bigquery_dataset resource block. The value of depends is set to `[google_project_service.bigquery]`, indicating that the dataset resource depends on the google_project_service.bigquery resource.

With this configuration, Terraform will enable the BigQuery API for your project before attempting to deploy the BigQuery dataset. It establishes the correct order of operations based on the defined dependency.

Run:

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply --auto-approve
```

The Plan should says: 2 to add, 0 to change, 0 to destroy.

## How to use foreach in terraform

In this section we will see how to deploy multiple secrets in your project using foreach.

Let's edit main.tf and add the folowing resources:

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_02/iac/main.tf">
    Edit main.tf
</walkthrough-editor-open-file>

```tf
provider "google" {
  project     = "test-ahn-dev"
  region      = "europe-west1"
}

variable "secrets" {
  type    = map(object({
    location  = string
    value     = string
  }))
  default = {
    "my-secret-a" = {
        location = "europe-west1",
        value    = "my-secret-a-value"
    }
     "my-secret-b" : {
        location = "europe-west1",
        value    = "my-secret-b-value"
    }

  }
}

resource "google_secret_manager_secret" "secret" {
  for_each = var.secrets
  secret_id = each.key
  replication {
    user_managed {
        replicas {
            location = each.value.location
        }

    }
  }
}

resource "google_secret_manager_secret_version" "version" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = each.value.value
}

```
```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply --auto-approve
```

the plan should tell you : 4 to add, 0 to change, 0 to destroy.

**Notice**: The foreach meta-argument in Terraform is used to iterate over a list, set, or map and create multiple instances of a resource or module based on the elements of the collection. It allows you to dynamically generate resources or modules by repeating a block of code for each element in the collection. It offers more flexibility in defining the resource object in a variable and easily access the different attributes within it.

## Clean up

You finished the lab, let's clean resources:

```bash
terraform destroy --auto-approve
```

## End of the lab

You're all set!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
