terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  # We tell Terraform to save its notes in the bucket we just created
  backend "gcs" {
    bucket  = "tf-state-cicd-learning" # REPLACE THIS if your bucket name is different
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = "ci-cd-learning-481620" # YOUR PROJECT ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 1. The Kubernetes Cluster (The "Manager")
resource "google_container_cluster" "primary" {
  name     = "cicd-cluster"
  location = "us-central1-a" # Zonal cluster (cheaper)

  # We delete the default node pool and create a custom one below
  remove_default_node_pool = true
  initial_node_count       = 1
}

# 2. The Node Pool (The "Workers")
resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1 # Just 1 machine to save money

  node_config {
    machine_type = "e2-medium" # Cheap, general purpose
    
    # Google recommends using OAuth scopes to grant permissions
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}