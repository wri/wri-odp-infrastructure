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

The Terraform setup employs a remote backend for storing the state file. The remote state storage configuration is defined in the `backend.tf` file.

Additionally, to ensure safe and concurrent access to the Terraform state, the [state locking](https://developer.hashicorp.com/terraform/language/state/locking) feature is enabled, leveraging DynamoDB for this purpose.

## Directory Structure

The Terraform setup is organized into two main directories:

1. **env**: This directory contains environment-specific files (e.g., dev, staging, prod) that use the modules located in the `k8s-infrastructure` directory. Environment variables are passed from this directory to the modules in `k8s-infrastructure`.

2. **k8s-infrastructure**: This directory contains various modules for infrastructure provisioning. These modules are called from the `main.tf` file within the `k8s-infrastructure` directory, utilizing the variables provided by the `env/<env_name>` folder, where `terraform plan` and `terraform apply` commands are executed.

## IAM Service Account

An IAM Service Account user for Terraform is added without console access, with least privilege permissions (only the permissions required for provisioning the needed components). It is created to provision the architecture with tags like "Purpose: Terraform Automation" and "Application: WRI ODP" to help differentiate between different service accounts.

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

## Usage

### How to deploy

1. Clone the repository locally and ensure that you have the credentials for the Terraform user already set up in your environment.

2. Navigate to the `env` directory corresponding to your working environment (e.g., `cd env/dev`).

3. Add the necessary environment variables in `.auto.tfvars`.

4. Run `terraform plan`. For example, if you are in the `env/dev` directory, run `terraform plan` after adding `.auto.tfvars`.

5. Run `terraform apply` once everything in the plan seems satisfactory.

These steps will allow you to deploy and manage the infrastructure efficiently.
