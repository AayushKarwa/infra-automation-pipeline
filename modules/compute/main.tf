#INSTEAD OF HARCODING AMI ID FETCH IT DYNAMICALLY
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (official Ubuntu owner ID)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
#------------KEY PAIR--------------------
resource "aws_key_pair" "main" {
    key_name = "${var.project_name}-keypair"
    public_key = file("infra-auto-key.pub")
  
}
#---------------EC2 INSTANCES-------------------------------
resource "aws_instance" "app" {
    count = var.instance_count

    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    subnet_id = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
    vpc_security_group_ids = [ var.ec2_sg_id ]
    key_name = aws_key_pair.main.key_name

      # Runs on first boot — installs basic packages
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y python3 python3-pip git
    echo "App server ${count.index + 1} ready" > /tmp/ready.txt
  EOF

   root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "${var.project_name}-app-server-${count.index + 1}"
    Role = "app"
  }
}
# ─── ALB ───────────────────────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false          # internet-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids   # ALB lives in public subnets

  enable_deletion_protection = false  # set true in production

  tags = { Name = "${var.project_name}-alb" }
}
# ─── TARGET GROUP ──────────────────────────────────────────────────────────
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}
# ─── REGISTER EC2 INSTANCES INTO TARGET GROUP ──────────────────────────────
resource "aws_lb_target_group_attachment" "app" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 8080
}
# ─── ALB LISTENER ──────────────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
  
