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
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_project_service" "kubernetes-api" {
  project = var.project_id
  service = "container.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = true
}