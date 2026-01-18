variable "project_id" {
  description = "project id"
  default     = "my-project-id"
}

variable "region" {
  description = "region"
  default     = "us-east1"
}

variable "cluster_name" {
  description = "gke cluster name"
  default     = "senior-devops-cluster"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "github_repo" {
  description = "GitHub repository in format user/repo"
}
