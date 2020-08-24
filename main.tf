provider "ibm" {
  region     = var.region
}

data "ibm_resource_group" "resource-group" {
   name = var.resource_group
}

resource "ibm_function_namespace" "namespace" {
   name                = var.namespace
   resource_group_id   = data.ibm_resource_group.resource-group.id
}

resource "ibm_function_package" "package" {
  name      = var.packagename
  namespace = ibm_function_namespace.namespace.name
}
