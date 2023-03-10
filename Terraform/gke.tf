resource "google_container_cluster" "my_gke" {
  name                     = "my-gke"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.my_vpc.name
  subnetwork               = google_compute_subnetwork.my_subnet["restricted"].name
  ip_allocation_policy {
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/24"
      display_name = "Management Subnet"
    }
    cidr_blocks {
      cidr_block   = "10.0.1.0/24"
      display_name = "Restricted Subnet"
    }
  }
}
resource "google_container_node_pool" "my_gke_node_pool" {
  name       = "my-gke-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.my_gke.name
  node_count = 1
  node_config {
    preemptible     = true
    machine_type    = "e2-standard-4"
    service_account = google_service_account.custom_gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}