resource "google_project_service" "apis" {
	disable_on_destroy=false
	for_each=toset([
		"artifactregistry.googleapis.com",
		"cloudresourcemanager.googleapis.com",
		"compute.googleapis.com",
		"container.googleapis.com",
		"iam.googleapis.com",
	])
	project=var.project_id
	service=each.key
}
