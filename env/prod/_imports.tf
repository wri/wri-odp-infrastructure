# Temporary one-shot import file. Used to bring the pre-existing
# `ckan-prod-storage` S3 bucket (~30 GB / 433 objects of CKAN data) into the
# prod state without going through a full plan, which currently fails because
# the helm provider and the eks-managed-node-group submodule reference values
# that only become known after the EKS cluster is created.
#
# Run from env/prod:
#   terraform plan \
#     -target='module.infrastructure.module.ckan_storage' \
#     -out=tfplan_import
#   terraform apply tfplan_import
#
# Then verify with:
#   terraform state list | grep ckan_storage
#
# Once `aws_s3_bucket.ckan_storage["ckan-prod-storage"]` is listed, DELETE THIS
# FILE and commit. Leaving import blocks in place after a successful import is
# harmless on subsequent applies but clutters the config.

import {
  to = module.infrastructure.module.ckan_storage.aws_s3_bucket.ckan_storage["ckan-prod-storage"]
  id = "ckan-prod-storage"
}
