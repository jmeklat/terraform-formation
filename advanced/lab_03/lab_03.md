# [Advanced] DAVIDSON Terraform Course - Lab 03 :Version Constraints and variable conditions

## Introduction
![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

In this lab you will learn about the following Terraform **meta-arguments**:
- Version Constraints
- Variable conditions

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

  ![DAVIDSON_TERRAFORM](https://storage.googleapis.com/bkt-public-images/Davidson-Fond%20De%CC%81grade%CC%81.jpg)

  Run :
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS=<path-to-cred-file>
  ```
## Version constraints
Let's first install `tfswitch`, which is a command-line tool used in the context of working with Terraform. It is designed to simplify the process of managing multiple versions of Terraform on your local machine. It allows you to switch between different versions of Terraform with ease, ensuring that you can work with different projects or environments that may require specific versions of Terraform.

More information about tfswitch in [https://tfswitch.warrensbox.com/](https://tfswitch.warrensbox.com/) .

To install tfswitch, run:
```sh
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

```

Let's check which Terraform version you have right now in your Cloud shell environment:

```sh
terraform version
```

Let's deploy some resources in your project using that specefic version of Terraform;

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_03/iac/provider.tf">
    Edit provider.tf
</walkthrough-editor-open-file>
```tf
provider "google" {
  project     = "<walkthrough-project-id/>"
  region      = "europe-west1"
}
```

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_03/iac/main.tf">
    Edit main.tf
</walkthrough-editor-open-file>
```tf
resource "google_storage_bucket" "bucket" {
  name        = "tf-lab-advabced-bucket"
  location    = "europe-west1"
  storage_class = "STANDARD"
}
```

**Notice**: Bucket name should be unique accross the globe, we suggest you add your intials as suffix to the bucket name in `main.tf`.

__Example__ : John Do -> Bucket name = "auto-expiring-bucket-jdo"

**Notice**: Bucket name should be unique accross the globe, we suggest you add your intials as suffix to the bucket name in `main.tf`.

__Example__ : John Do -> Bucket name = "auto-expiring-bucket-jdo"

Now, it's time to fix the terraform version that can be used to run this code. By using version constraints, you can enforce compatibility and ensure that your configuration is used with the correct Terraform version. It helps prevent accidental use of incompatible features or behaviors introduced in different versions.

<walkthrough-editor-open-file
    filePath="cloudshell_open/wam-tf-labs/advanced/lab_03/iac/versions.tf">
    Edit versions.tf
</walkthrough-editor-open-file>
```tf
terraform {
  required_version = ">= 0.15, < 0.16"
}
```

## End of the lab

You're all set!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
