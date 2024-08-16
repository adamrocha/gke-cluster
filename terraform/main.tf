terraform {
  required_version = "> 1.5"

  required_providers {
    google = {
      version = "~> 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "kubernetes-api" {
  //project = var.project_id
  service = "container.googleapis.com"
  /*
  timeouts {
    create = "30m"
    update = "40m"
  }
*/
  disable_on_destroy = false
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = var.region
  //enable_autopilot = true

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "gke-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

/*
resource "google_container_cluster" "default" {
  name     = "gke-autopilot-basic"
  //location = "us-central1"

  enable_autopilot = true

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}*/