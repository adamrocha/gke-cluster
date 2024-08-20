provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "kubernetes-api" {
  service                    = "container.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  depends_on               = [google_project_service.kubernetes-api]
  name                     = "primary"
  location                 = var.region
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
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = google_service_account.default.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

/*
resource "google_container_cluster" "default" {
  name                = "gke-autopilot"
  enable_autopilot    = true
  deletion_protection = false
}
*/