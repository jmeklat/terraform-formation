resource "google_storage_bucket" "auto-expire" {
  name          = "auto-expiring-bucket"
  location      = "EUROPE-WEST1"
  force_destroy = true
}
