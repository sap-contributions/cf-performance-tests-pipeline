# Needed because this pipeline deploys on an AWS account controlled by SAP, which is subject to the automated removal of security rules that open port 22 unless they are tagged like this

resource "aws_security_group" "jumpbox" {
  name        = "${var.env_id}-jumpbox-security-group"
  description = "Jumpbox"
  vpc_id      = local.vpc_id

  tags = {
    Name                         = "${var.env_id}-jumpbox-security-group",
    sec-by-def-network-exception = "SSH"
  }

  lifecycle = {}
}
