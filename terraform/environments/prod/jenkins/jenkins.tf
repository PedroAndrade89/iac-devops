resource "aws_security_group" "jenkins" {
  name        = "jenkins_security_group"
  description = "Allow SSH and HTTP"
  vpc_id   = "vpc-4db6ac2a"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.111.4.0/24"] # Update this to your IP for better security
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.111.5.0/24"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.111.5.0/24"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.111.4.0/24"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.111.4.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "jenkins-master" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.medium"
  key_name      = "pedro" # Replace with your SSH key name

  subnet_id     = "subnet-be258693"

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    delete_on_termination = true
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.jenkins.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk11 -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade -y
              sudo yum install fontconfig java-17-openjdk -y
              sudo yum install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins-slave-1" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  key_name      = "pedro" # Replace with your SSH key name

  subnet_id     = "subnet-be258693"

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    delete_on_termination = true
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.jenkins.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk11 -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade -y
              sudo wget -O hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_65
              sudo chmod +x /bin/hadolint
              sudo curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
              sudo yum install fontconfig java-17-openjdk -y
              sudo yum install jenkins docker git python3-devel libffi-devel openssl-devel -y
              sudo yum groupinstall 'Development Tools' -y
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "jenkins-slave-1"
  }
}

resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins.id]
  subnets            = ["subnet-ce079b87", "subnet-6df05c40"] # Replace with your subnet IDs

  enable_deletion_protection = false

  tags = {
    Name = "jenkinsALB"
  }
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-4db6ac2a" # Replace with your VPC ID

  health_check {
    protocol = "HTTP"
    path     = "/login"
    port     = "8080"
  }

  tags = {
    Name = "jenkinsTG"
  }
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins_tg_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = 8080
}

output "jenkins_alb_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}