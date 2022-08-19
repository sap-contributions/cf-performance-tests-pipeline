resource "aws_security_group_rule" "jumpbox_rdp" {
  security_group_id = "${aws_security_group.jumpbox.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3389
  to_port           = 3389
  cidr_blocks       = ["${var.bosh_inbound_cidr}"]
  count             = 0
}