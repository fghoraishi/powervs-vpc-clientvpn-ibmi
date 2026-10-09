# Look up an existing COS instance if instance_name is provided
#data "ibm_resource_instance" "cos_instance" {
#  count             = var.instance_name != "" ? 1 : 0
#  depends_on           = [ibm_resource_instance.cos_instance]
#  name              = var.name
#  resource_group_id = var.resource_group_id
#  service           = "cloud-object-storage"
#}

# Provision a new COS instance with Standard pricing if no existing instance_name is provided
resource "ibm_resource_instance" "cos_instance" {
  count             = var.instance_name != "" ? 1 : 0
  name              = format("%s-cos", var.name != "" ? var.name : var.bucket_name)
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = var.resource_group_id
}

locals {
#  cos_instance_id  = var.instance_name == "" ? data.ibm_resource_instance.cos_instance[0].id : ibm_resource_instance.cos_instance[0].id
#  cos_instance_crn = var.instance_name == "" ? data.ibm_resource_instance.cos_instance[0].crn : ibm_resource_instance.cos_instance[0].crn
  cos_instance_id  = ibm_resource_instance.cos_instance[0].id
  cos_instance_crn = ibm_resource_instance.cos_instance[0].crn
}

# Create Smart Tier regional COS bucket
resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = var.bucket_name
  resource_instance_id = local.cos_instance_id
  region_location      = var.bucket_region
  storage_class        = "smart"
}

resource "ibm_cos_bucket_object" "plaintext" {
  bucket_crn      = ibm_cos_bucket.cos_bucket.crn
  bucket_location = ibm_cos_bucket.cos_bucket.region_location
  content         = var.content
  key             = var.key
}

locals {
  bucket_url = format("https://cloud.ibm.com/objectstorage/%s?bucket=%s&bucketRegion=%s&endpoint=s3.%s.cloud-object-storage.appdomain.cloud&paneId=bucket_overview",
    urlencode(local.cos_instance_crn),
    var.bucket_name,
    var.bucket_region,
    var.bucket_region
  )
}
