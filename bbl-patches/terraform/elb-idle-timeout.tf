# required for longer elb idle timeout (default is 60 seconds)
resource "aws_elb" "cf_router_lb" {
  idle_timeout = 300
}
