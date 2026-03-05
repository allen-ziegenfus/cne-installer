variable "create_kms_key" {
	default=false
	type=bool
}
variable "deployment_name" {
	default="liferay-gcp"
}
variable "enable_public_gar_access" {
	default=false
	type=bool
}
variable "kms_key_name" {
	default=null
	type=string
}
variable "project_id" {
	type=string
}
variable "region" {
	type=string
}
