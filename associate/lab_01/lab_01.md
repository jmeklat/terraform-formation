# [Associate] DAVIDSON Terraform Course - Lab 01 : Full workflow
## Introduction
![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

After following the tutorial steps, you'll aquire the following knowledges:
- Know how to run terraform commands (init, plan and apply)
- know how to read and inspect Terraform code
- Apply modification to your infrastructure (update and destroy)

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
**Tips**: Trainer should tell you which project you should select.

This command will add a quota project in application default credentials and saves the credentials file to a temp directory :

![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/cred_path.png)

Run :
```bash
export GOOGLE_APPLICATION_CREDENTIALS=<path-to-cred-file>
```

## Connect to your GCP project

We have prepared a script that will do things on your behalf. Don't worry if you don't understand this for the moment.

Make the script executable:
```bash  
chmod +x associate/lab_01/setup_project.sh
```

Run the script:
```bash  
./associate/lab_01/setup_project.sh <walkthrough-project-id/>
```

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/associate/lab_01/setup_project.sh">
    check script
</walkthrough-editor-open-file>

## Inspect terraform code
Let's see what we have, open Cloud Shell Editor and take a look at the file named main.tf :

<walkthrough-editor-open-file filePath="cloudshell_open/wam-tf-labs/associate/lab_01/iac/main.tf">Open main.tf</walkthrough-editor-open-file>

Files in this directory are intended to deploy a GCS bucket to Google Cloud.
***
## Make changes to the code
Bucket name should be unique accross the globe, we suggest you add your intials as suffix to the bucket name in `main.tf`.

__Example__ : John Do -> Bucket name = "auto-expiring-bucket-jdo"

```tf
resource "google_storage_bucket" "auto-expire" {
  name          = "auto-expiring-bucket-jdo"
  location      = "EUROPE-WEST1"
  force_destroy = true
}
````

Save file 📝.

## Run Terraform commands

Go to the working directory :
```bash
cd ~/cloudshell_open/wam-tf-labs/associate/lab_01/iac
```

Run
```bash
terraform init
```
<em>The terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe to run this command multiple times.</em>  

<em><u>source</u> :  [https://www.terraform.io/cli/commands/init](https://www.terraform.io/cli/commands/init)</em>

```bash
terraform plan
```
<em>The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:
- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.  
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.</em>

<em><u>source</u> :  [https://www.terraform.io/cli/commands/plan](https://www.terraform.io/cli/commands/plan)</em>

It's time now to create the resources describe by our IaC. To do this run:
```bash
terraform apply
```
Optionally you can add the `--auto-approve` flag to the previous command to skip the approving prompt.

This can be usefull when running `terraform apply` command in CICD pipelines.


[Go to bucket list page](https://console.cloud.google.com/storage/browser?referrer=search&orgonly=true&project=<walkthrough-project-id/>)

Verify that the bucket is created successfully.

## Inspect Terraform tfstate

Notice that Terraform generates a `terraform.tfstate` file locally that contains traces of what has been created. Inspect the file:

<walkthrough-editor-open-file filePath="cloudshell_open/wam-tf-labs/associate/lab_01/iac/terraform.tfstate">Open terraform.tfstate</walkthrough-editor-open-file>

## Cleanup

```bash
terraform destroy --auto-approve
```
In the Google Cloud console, go to the Cloud Storage Buckets page and verify that the bucket is no longer existing.

You're all set!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
