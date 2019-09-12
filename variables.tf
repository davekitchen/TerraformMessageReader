# General Variables

variable "BaseName" {
  description = "Base name from which everything else is derived."
  type        = "string"
}

variable "Location" {
  description = "deployment location"
  type        = "string"
}

variable "TableName" {
  description = "Name of destination table"
  type        = "string"
}

variable "StorageAccountName" {
  description = "Name of storage account"
  type        = "string"
}

variable "GitInfo" {
  description   = "Everything you need for the function deploy"
  type          = "map"
  default       = {
    Branch       = "master"
    FunctionName = "MessageReader"
    RepoUrl      = ""
  }
}
