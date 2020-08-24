provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "resource-group" {
   name = var.resource_group
}

resource "ibm_function_namespace" "namespace" {
   name                = var.namespace
   description         = "created by schematics"
   resource_group_id   = data.ibm_resource_group.resource-group.id
}

resource "ibm_function_package" "package" {
  name      = var.package_name
  namespace = ibm_function_namespace.namespace.name
}

resource "ibm_function_action" "action" {
  name      = var.action_name
  namespace = ibm_function_namespace.namespace.name
  exec {
    kind  = "openwhisk/dockerskeleton"
    image = file("setCosContentType.sh")
  }
}

resource "ibm_function_trigger" "trigger" {
  name = var.trigger_name
  namespace = ibm_function_namespace.namespace.name
  feed {
      name = "/whisk.system/cos/changes"
      parameters = <<EOF
                [
                        {
                                "key":"bucket",
                                "value":"${var.bucket_name}"
                        },
                        {
                                "key":"endpoint",
                                "value":"s3.private.jp-tok.cloud-object-storage.appdomain.cloud"
                        },
                        {
                                "key":"event_types",
                                "value":"write"
                        }
                ]
                EOF
  }
}

resource "ibm_function_rule" "rule" {
  name         = var.rule_name
  namespace = ibm_function_namespace.namespace.name
  action_name  = ibm_function_action.action.name
  trigger_name = ibm_function_trigger.trigger.name
}
