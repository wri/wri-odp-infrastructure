# WRI Open Data Portal Infrastructure

This repository contains Terraform scripts designed to provision the infrastructure for the WRI Open Data Portal. The infrastructure is built to support containerized applications deployed on an Amazon Elastic Kubernetes Service (EKS) cluster hosted on AWS. Additionally, it utilizes a managed PostgreSQL server for data storage and management, along with provisioning an S3 file store for backend storage.

These scripts enable the automated setup and management of the infrastructure components required to host and maintain the WRI Open Data Portal.

## Table of Contents

- [Remote State and State Locking](#remote-state-and-state-locking)
- [Directory Structure](#directory-structure)
- [IAM Service Account](#iam-service-account)
- [k8s-infrastructure Modules](#k8s-infrastructure-modules)
  - [ecr](#ecr)
  - [eks](#eks)
  - [rds](#rds)
  - [s3](#s3)
  - [vpc](#vpc)
- [Usage](#usage)

## Remote State and State Locking

The Terraform setup employs a remote backend for storing the state file. The remote state storage configuration is defined in the `main.tf` file in each environment directory.

The state is stored in:
- **S3 Bucket**: `wri-odp-tfm-state-bucket`
- **DynamoDB Table**: `tfm-state-lock` (for state locking)
- **State Key**: `global/statefile/terraform.state`

Additionally, to ensure safe and concurrent access to the Terraform state, the [state locking](https://developer.hashicorp.com/terraform/language/state/locking) feature is enabled, leveraging DynamoDB for this purpose.

### Required IAM Permissions for State Access

To access the Terraform state, your AWS credentials must have the following permissions:

**S3 Bucket Permissions:**
- `s3:ListBucket` on `arn:aws:s3:::wri-odp-tfm-state-bucket`
- `s3:GetObject` on `arn:aws:s3:::wri-odp-tfm-state-bucket/global/statefile/*`
- `s3:PutObject` on `arn:aws:s3:::wri-odp-tfm-state-bucket/global/statefile/*`
- `s3:DeleteObject` on `arn:aws:s3:::wri-odp-tfm-state-bucket/global/statefile/*`

**DynamoDB Table Permissions:**
- `dynamodb:GetItem` on `arn:aws:dynamodb:us-east-1:*:table/tfm-state-lock`
- `dynamodb:PutItem` on `arn:aws:dynamodb:us-east-1:*:table/tfm-state-lock`
- `dynamodb:DeleteItem` on `arn:aws:dynamodb:us-east-1:*:table/tfm-state-lock`

### Troubleshooting State Access Issues

If you encounter a `403 Forbidden` error when accessing the state file:

1. **Verify your AWS credentials**: Check which AWS user/role you're using:
   ```bash
   aws sts get-caller-identity
   ```

2. **Switch to Terraform service account credentials**: You should be using the Terraform service account credentials, not your personal IAM user credentials. The service account should be part of the `wri-odp-devops` group with appropriate permissions.

3. **Configure AWS credentials**: If using a different profile:
   ```bash
   export AWS_PROFILE=245948672511_dataExplorerDevsPermissionSet  # or your Terraform service account profile name
   ```
   
   Or update your `~/.aws/credentials` file with the Terraform service account access keys.

4. **Verify bucket access**: Test if you can access the state bucket:
   ```bash
   aws s3 ls s3://wri-odp-tfm-state-bucket/
   ```

5. **Check IAM permissions**: Ensure your IAM user/role has the required S3 and DynamoDB permissions listed above. Contact your AWS administrator if you need these permissions added.

## Directory Structure

The Terraform setup is organized into two main directories:

1. **env**: This directory contains environment-specific files (e.g., dev, staging, prod) that use the modules located in the `k8s-infrastructure` directory. Environment variables are passed from this directory to the modules in `k8s-infrastructure`.

2. **k8s-infrastructure**: This directory contains various modules for infrastructure provisioning. These modules are called from the `main.tf` file within the `k8s-infrastructure` directory, utilizing the variables provided by the `env/<env_name>` folder, where `terraform plan` and `terraform apply` commands are executed.

## Usage

### Prerequisites

1. Clone the repository locally and ensure that the credentials for the Terraform user are already set up in your environment. You can use the Terraform service account user key (which can be created through IAM) to establish the connection. For example:

```bash
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
```

Add the Terraform service account key to the `wri-aws-terraform` profile, as this profile is referenced in the AWS provider block. To do so, run:

```bash
aws configure --profile wri-aws-terraform
```

and enter the Terraform service account credentials from IAM when prompted.

1. **Terraform** (v1.0 or later)
   - Check installation: `terraform version`
   - Install from: https://www.terraform.io/downloads

2. **AWS CLI** (v2.0 or later)
   - Check installation: `aws --version`
   - Install from: https://aws.amazon.com/cli/

3. **Terraform Service Account Access Keys**
   - Obtain from your AWS administrator or IAM console
   - The service account should be part of the `wri-odp-devops` group
   - Must have permissions to access the state bucket (see [Required IAM Permissions](#required-iam-permissions-for-state-access))

### Step-by-Step Guide: Running Terraform Plan on a New Project

Follow these steps to set up and run `terraform plan` for the first time:

#### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd wri-odp-infrastructure
```

#### Step 2: Configure AWS Credentials

You must use the **Terraform service account** credentials (not your personal IAM user).

**Option A: Using AWS CLI Profile (Recommended)**

1. Configure AWS credentials with a named profile:
   ```bash
   aws configure --profile terraform
   ```
   When prompted, enter:
   - AWS Access Key ID: [Your Terraform service account access key]
   - AWS Secret Access Key: [Your Terraform service account secret key]
   - Default region: `us-east-1`
   - Default output format: `json`

2. Set the profile as the active profile:
   ```bash
   export AWS_PROFILE=terraform
   ```

**Option B: Using Environment Variables**

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Verify your credentials:**

```bash
aws sts get-caller-identity
```

This should show the Terraform service account user, not a personal IAM user.

**Test state bucket access:**

```bash
aws s3 ls s3://wri-odp-tfm-state-bucket/
```

If you get a `403 Forbidden` error, you need to switch to the Terraform service account credentials.

#### Step 3: Navigate to the Environment Directory

```bash
cd env/dev
```

Or for other environments: `cd env/staging` or `cd env/prod`

#### Step 4: Create the `.auto.tfvars` File

The `.auto.tfvars` file contains environment-specific variable values. Create it in the environment directory:

> **Note:** The complete `.auto.tfvars` template is available in the [secrets repo](https://github.com/wri/wri-odp-secrets/blob/main/infrastructure/.auto.tfvars). Copy it from there and customize for your environment.

#### Step 5: Initialize Terraform

Initialize Terraform to download required providers and configure the backend:

```bash
terraform init
```

This will:
- Download the required Terraform providers (AWS, etc.)
- Configure the S3 backend for state storage
- Set up the remote state configuration

**Expected output:** `Terraform has been successfully initialized!`

If you encounter errors:
- **Backend initialization error**: Verify AWS credentials and S3 bucket access (see Step 2)
- **Provider download error**: Check your internet connection

#### Step 6: Run Terraform Plan

Generate and review the execution plan:

```bash
terraform plan -var-file=.auto.tfvars
```

Or simply (since `.auto.tfvars` is automatically loaded):

```bash
terraform plan
```

**What to expect:**
- Terraform will read the configuration files
- It will connect to AWS to check current state
- It will generate a plan showing what resources will be created, modified, or destroyed
- Review the plan carefully before proceeding

**Common plan output sections:**
- `Plan: X to add, Y to change, Z to destroy`
- Detailed list of resources and their configurations

#### Step 7: Apply Changes (Optional)

Once you've reviewed the plan and it looks correct, apply the changes:

```bash
terraform apply -var-file=.auto.tfvars
```

Or:

```bash
terraform apply
```

Terraform will prompt you to confirm. Type `yes` to proceed.

> **Warning:** This will create actual AWS resources and incur costs. Ensure you understand what will be created before applying.

### Quick Reference Commands

```bash
# Check Terraform version
terraform version

# Verify AWS credentials
aws sts get-caller-identity

# Test state bucket access
aws s3 ls s3://wri-odp-tfm-state-bucket/

# Initialize Terraform
cd env/dev
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure (use with caution!)
terraform destroy
```

### Troubleshooting

**Error: "Error refreshing state: Unable to access object"**
- See [Troubleshooting State Access Issues](#troubleshooting-state-access-issues)
- Ensure you're using Terraform service account credentials

**Error: "Backend configuration changed"**
- If you've modified the backend configuration, run `terraform init -reconfigure`

**Error: "Module not found"**
- Ensure you're in the correct directory (`env/dev`, `env/staging`, etc.)
- Run `terraform init` to download modules

**Error: "Variable not set"**
- Ensure `.auto.tfvars` exists in the environment directory
- Check that all required variables are defined in the file

## IAM Users and Service Accounts

An IAM Service Account user for Terraform is added without console access, with least privilege permissions (only the permissions required for provisioning the needed components). It is created to provision the architecture with tags like "Purpose: Terraform Automation" and "Application: WRI ODP" to help differentiate between different service accounts.

The users and service accounts are added manually to the IAM.

### IAM Groups

* wri-odp-devops (for devops)
  * Users: Terraform service account (doesn't have console access) and devops engineer
  * Purpose: The terraform service account and the devops engineer are a part of this group so that terraform can provision all the resources needed for the infrastructure and the devops engineer can manually intervene if something goes wrong and manual intervention is required to resolve the terraform runs.
    * The terraform user can add/remove users but the users of the group wri-odp-devops don't have the access to manage IAM users, so the devops engineer is not going to have the IAM access other than just ReadOnlyAccess to check if the roles needed for the cluster are created/present if needed.
* wri-odp-dev (for developers)
  * Users: Developers
  * Purpose: To provide all the devs the ability to assume the role “eks-admin“ so that they can access and perform activities on the eks cluster along with access to the buckets needed for development
  * Permissions (ListAndReadIAMUser and S3 Access Policy)
    * Full access to the EKS dev cluster via the eks-admin role (the users can assume the eks-admin)
    * Access to the dev buckets only (Admin access for the dev CKAN buckets)

### Policies Attached to the Users

* **ListAndReadIAMUser:** This Policy allows the user to list the users but only manage their own IAM users so that they can create and handle API keys.
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "iam:ListUsers",
                    "iam:ListRoles",
                    "iam:ListGroups",
                    "iam:ListPolicies",
                    "iam:ListGroupPolicies",
                    "iam:ListAttachedGroupPolicies"
                ],
                "Resource": [
                    "*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:*"
                ],
                "Resource": [
                    "arn:aws:iam::{account-id}:user/{user-arn}"
                ]
            }
        ]
    }
    ```
* **S3BucketAccessDev:** allows to list all buckets but full control over the dev bucket only
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket",
                    "s3:ListAllMyBuckets",
                    "s3:GetAccountPublicAccessBlock",
                    "s3:GetBucketPublicAccessBlock",
                    "s3:GetBucketPolicyStatus",
                    "s3:GetBucketAcl",
                    "s3:ListAccessPoints"
                ],
                "Resource": [
                    ""
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:"
                ],
                "Resource": [
                    "arn:aws:s3:::{storage bucket}",
                    "arn:aws:s3:::{storage bucket}/*"
                ]
            }
        ]
    }
    ```

### IAM Roles

* `eks-admin`  (for RBAC access to eks cluster as an admin, the users can assume this role)
  * Has full eks access to the dev cluster only.
* `github-actions-oidc-role` is also added to enable github actions to deploy to EKS using OIDC instead of storing long-lived credentials as secrets. The name of the github org/repo is added in the trust policy attached to the role i.e.`"token.actions.githubusercontent.com:sub": "repo:wri/wri-odp:*"`
    * The policies attached to the role for EKS access and ECR access (pushing docker images). The usage of this role can be viewed [`main.yml`](..github/workflows/main.yml#L125). It connects to the AWS cluster as eks-admin role. For more info. regarding OIDC with AWS, the docs are available [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).
* A service account `sa-ckan-dev-s3` is added to enable s3 storage for ckan with only access to the dev bucket.

### Instructions to connect to AWS cluster


* Create Access Keys for your IAM user by navigating to the Security Credentials tab for your IAM user and store them locally
* Run the command (You would need to install aws cli if not already present on your machine)
    ```
    aws configure --profile wri-aws
    ```
* Enter your access keys when prompted by the above command
* Once configure is complete edit the file `~/.aws/config` and add the following lines at the end and save
    ```
    [profile eks-admin]
    role_arn = arn:aws:iam::{account_id}:role/{role_name}
    source_profile = wri-aws
    ```
* Once that is done, now your IAM user should be able to assume the `eks-admin`` role to connect to the eks cluster by running the command
    ```
    aws eks update-kubeconfig --name {cluster-name} --region {region-name} --profile eks-admin
    ```
* Now you should be able to access the cluster through your kubectl command line tool.

## k8s-infrastructure Modules

The `k8s-infrastructure` directory contains several modules, each responsible for specific infrastructure provisioning tasks. Below, we provide detailed explanations for each module:

### ecr

The `ecr` module is used for storing built Docker images, which are essential for deploying applications in your Kubernetes cluster. It ensures a reliable and versioned repository for your container images.

The module contains the following files with their functionalities:

- `main.tf`: This adds a private ECR registry with IMMUTABLE images.

### eks

The `eks` module is responsible for provisioning and managing an Amazon Elastic Kubernetes Service (EKS) cluster. EKS provides a scalable and managed Kubernetes environment, making it easier to deploy, manage, and scale containerized applications.

The module contains the following files with their functionalities:

- `main.tf`: It uses the module [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) for provisioning the EKS cluster with one managed node group.
  - Uses IAM Roles for Service Accounts (IRSA) to grant roles to applications running in the EKS cluster.
  - Managed node group (i.e., node group 1) with "t3.xlarge" instance type, tagged with the deployed environment.
- `iam.tf`: We create an IAM role with access to EKS with necessary permissions.
  - Provide Describe Cluster access to the role to access the cluster.
  - IAM role (eks-admin) is created, which is bound to the Kubernetes system masters RBAC group to allow full access to the Kubernetes API.
  - With trusted_role_arn, every user can assume the role if the user has needed policies attached to it.
  - Allow users to assume a role that has access to EKS.
  - Enable the EKS cluster `manage_aws_auth_configmap` and allow the role we just created in the aws_auth_roles (i.e., mapping eks-admin role with the Kubernetes system master RBAC group).
- `autoscaler-iam.tf` and `autoscaler-manifest.tf`: Uses OIDC provider for IAM role service account.
  - Adds Cluster autoscaler to automatically scale the EKS cluster using the manifest files.
- `csi-driver-iam.tf` and `csi-driver-addons.tf`: Add EBS CSI driver as an add-on to ensure that we can attach volumes to the pods along with the user permissions needed for the IAM role.
- `helm.tf`: Deploys nginx ingress controller and cert-manager.

### rds

The `rds` module handles the provisioning of a PostgreSQL database server. This database server is crucial for your applications, providing a secure and scalable storage solution for data.

The module contains the following files with their functionalities:

- `main.tf`: To create a PostgreSQL instance depending on the values provided to it via environment variables.

### s3

The `s3` module manages the provisioning of backend storage using Amazon S3. This storage is utilized by your applications to store and retrieve various data types, such as static assets, logs, and backups.

The module contains the following files with their functionalities:

- `main.tf`: Creates a private bucket for storing backend files for the WRI ODP.

### vpc

The `vpc` module takes care of provisioning a Virtual Private Cloud (VPC) and network policies for your entire infrastructure. It ensures a secure and isolated network environment for your Kubernetes cluster and associated resources.

The module contains the following files with their functionalities:

- `main.tf`: Uses the open-source module `terraform-aws-modules/vpc/aws` to deploy the VPC.
  - Uses a single NAT gateway and enables DNS hostname and DNS support.
  - Tags the VPC with the environment name.
  - Adds a security group to allow traffic to the RDS instance on port 5432.

Each of these modules plays a crucial role in building and maintaining your Kubernetes-based infrastructure. In the following sections, we will delve into the specific configurations and usage of each module.

