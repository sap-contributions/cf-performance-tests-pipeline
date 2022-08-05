provider "aws" {
  default_tags {
    tags = {
      performance_test_environment = "${var.env_name}"
      managed_by = "bbl"
    }
  }
}
