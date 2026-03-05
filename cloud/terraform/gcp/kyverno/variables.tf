variable "deployment_name" {
	type=string
}
variable "kyverno_namespace" {
	default="kyverno"
	type=string
}
variable "project_id" {
	type=string
}
variable "region" {
	type=string
}
variable "spot" {
	default=true
	type=bool
}
