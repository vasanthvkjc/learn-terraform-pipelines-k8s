# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "google_compute_zones" "available" {}

data "google_container_engine_versions" "gke_version" {
  location       = var.location
  version_prefix = "1.29."
}

resource "google_container_cluster" "engineering" {
  name     = var.cluster_name
  location = var.location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}

resource "google_container_node_pool" "engineering_preemptible_nodes" {
  name     = "${var.cluster_name}-node-pool"
  cluster  = google_container_cluster.engineering.name
  location = var.location

  version    = "1.29.10-gke.1280000"
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
