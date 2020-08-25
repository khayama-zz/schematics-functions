variable "region" {
  default = "jp-tok"
}

variable "ibmcloud_api_key" {}

variable "resource_group" {
  default = "khayama-rg"
}

variable "namespace" {
  default = "khayama-schematics-fn"
}

variable "package_name" {
  default = "khayama-schematics-pkg"
}

variable "action_name" {
  default = "khayama-schematics-act"
}

variable "trigger_name" {
  default = "khayama-schematics-trg"
}

variable "bucket_name" {
  default = "khayama-mime"
}

variable "rule_name" {
  default = "khayama-schematics-rule"
}
