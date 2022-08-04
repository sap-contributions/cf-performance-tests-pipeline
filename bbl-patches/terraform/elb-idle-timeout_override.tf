resource "aws_elb" "cf_router_lb" {
  idle_timeout = "${var.idle_timeout}"
}

variable "idle_timeout" {
  type        = "string"
  default     = "60"
  description = "The time in seconds that a connection to the cf router load balancer is allowed to be idle"
}