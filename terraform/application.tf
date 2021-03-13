resource "aws_ecr_repository" "dev-armaps-ecr-repository" {
  name = "dev-armaps-ecr-repository"

  tags = {
    Name = "dev-armaps-ecr-repository"
  }
}

resource "aws_ecs_cluster" "dev-armaps-ecs-cluster" {
  name = "dev-armaps-ecs-cluster"

  tags = {
    Name = "dev-armaps-ecs-cluster"
  }
}

resource "aws_instance" "dev-armaps-api-instance-us-east-1a" {
  ami                    = "ami-0ec7896dee795dfa9"
  subnet_id              = aws_subnet.dev-armaps-vpc-public-us-east-1a.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs-instance-profile.name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.dev-armaps-public-sg.id
  ]
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = data.template_file.user_data.rendered
  key_name               = "armaps-us-east-1"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "dev-armaps-api-instance-us-east-1a"
  }
}

resource "aws_instance" "dev-armaps-api-instance-us-east-1b" {
  ami                    = "ami-0ec7896dee795dfa9"
  subnet_id              = aws_subnet.dev-armaps-vpc-public-us-east-1b.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs-instance-profile.name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.dev-armaps-public-sg.id
  ]
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = data.template_file.user_data.rendered
  key_name               = "armaps-us-east-1"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "dev-armaps-api-instance-us-east-1b"
  }
}

resource "aws_instance" "dev-armaps-api-instance-us-east-1c" {
  ami                    = "ami-0ec7896dee795dfa9"
  subnet_id              = aws_subnet.dev-armaps-vpc-public-us-east-1c.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs-instance-profile.name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.dev-armaps-public-sg.id
  ]
  ebs_optimized          = "false"
  source_dest_check      = "false"
  user_data              = data.template_file.user_data.rendered
  key_name               = "armaps-us-east-1"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "dev-armaps-api-instance-us-east-1c"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")
}

resource "aws_ecs_task_definition" "dev-armaps-api-ecs-task-definition" {
  container_definitions    = data.template_file.task_definition_json.rendered
  execution_role_arn       = aws_iam_role.ecs-service-role.arn
  family                   = "dev-armaps-api-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.ecs-service-role.arn
}

data "template_file" "task_definition_json" {
  template = file("${path.module}/task_definition.json")
}

resource "aws_ecs_service" "dev-armaps-api-ecs-service" {
  cluster                = aws_ecs_cluster.dev-armaps-ecs-cluster.id
  desired_count          = 3
  launch_type            = "EC2"
  name                   = "armaps-service"
  task_definition        = aws_ecs_task_definition.dev-armaps-api-ecs-task-definition.arn

  load_balancer {
    container_name       = "armaps-ecs-container"
    container_port       = "8080"
    target_group_arn     = aws_lb_target_group.lb_target_group.arn
  }

  network_configuration {
    security_groups       = [
      aws_security_group.dev-armaps-public-sg.id
    ]
    subnets = [
      aws_subnet.dev-armaps-vpc-public-us-east-1a.id,
      aws_subnet.dev-armaps-vpc-public-us-east-1b.id,
      aws_subnet.dev-armaps-vpc-public-us-east-1c.id,
    ]
    assign_public_ip      = "false"
  }

  depends_on              = [
    aws_lb_listener.lb_listener
  ]
}

resource "aws_lb" "loadbalancer" {
//  internal        = true
  name            = "dev-armaps-alb"
  subnets         = [
      aws_subnet.dev-armaps-vpc-public-us-east-1a.id,
      aws_subnet.dev-armaps-vpc-public-us-east-1b.id,
      aws_subnet.dev-armaps-vpc-public-us-east-1c.id,
  ]
  security_groups = [
    aws_security_group.dev-armaps-public-sg.id
  ]
}


resource "aws_lb_target_group" "lb_target_group" {
  name        = "dev-armaps-target-alb"
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev-armaps-vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "15"
    port                = "8080"
    path                = "/"
    protocol            = "HTTP"
    unhealthy_threshold = "10"
  }
}

resource "aws_lb_listener" "lb_listener" {
  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }

  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "dev-armaps-api-cw"
}