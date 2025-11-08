# variables.tf
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "k8s-lab"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "k8s-lab-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "k8s-vnet"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "k8s-subnet"
}

variable "nsg_name" {
  description = "Network security group name"
  type        = string
  default     = "k8s-nsg"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  description = "VM size for Kubernetes nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "vnet_cidr" {
  description = "CIDR block for the VNet"
  type        = string
  default     = "10.240.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the Subnet"
  type        = string
  default     = "10.240.0.0/24"
}

variable "admin_public_ip" {
  description = "Your public IP address for SSH and API access (e.g. 203.0.113.25/32)"
  type        = string
  default = "163.116.162.115"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}


# a map is a collection of key-value pairs, where each key is unique
# all the keys in the map must be of the same type, and all the values must also be of the same type
variable "resource_tags" {
  type = map(string) # Type of the variable is a map of strings
  default = {
        businesscriticality = "Low" # Tag to indicate the business criticality
        businessunit = "IT" # Tag to indicate the business unit
        costcentre = "tf" # Tag to indicate the cost center
        dataclassification = "Internal" # Tag to indicate the data classification
        workloadname = "tf" # Tag to indicate the workload name
  }
  description = "Map of tags to apply to resources"
  
}
