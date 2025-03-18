variable "location" {
  description = "Azure region where AKS will be deployed"
  default     = "East US"
}

variable "resource_group_name" {
  description = "Existing Azure Resource Group"
  default     = "myResourceGroup"
}

variable "aks_cluster_name" {
  description = "Azure Kubernetes Service (AKS) cluster name"
  default     = "my-aks-cluster"
}

variable "node_count" {
  description = "Number of AKS worker nodes"
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for the worker nodes"
  default     = "Standard_B2s"
}
