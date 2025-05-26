provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# デフォルトVPC取得
data "aws_vpc" "default" {
  default = true
}

# セキュリティグループ
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair作成
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# IAMロール
resource "aws_iam_role" "cwagent_role" {
  name = "cwagent-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAMポリシーアタッチ
resource "aws_iam_role_policy_attachment" "cwagent_server_policy" {
  role       = aws_iam_role.cwagent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_readonly_policy" {
  role       = aws_iam_role.cwagent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "cwagent_instance_profile" {
  name = "cwagent-instance-profile"
  role = aws_iam_role.cwagent_role.name
}

# EC2インスタンス
resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  iam_instance_profile   = aws_iam_instance_profile.cwagent_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y unzip curl

              cd /tmp
              curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
              rpm -U ./amazon-cloudwatch-agent.rpm

              cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              {
                 "agent":{
                    "metrics_collection_interval":60,
                    "logfile":"/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
                 },
                 "metrics":{
                    "metrics_collected":{
                       "mem":{
                          "measurement":[
                             {"name":"mem_used","rename":"MemoryUsed"},
                             {"name":"mem_available_percent","rename":"MemoryAvailablePercent"},
                             {"name":"mem_used_percent","rename":"MemoryUsedPercent"},
                             {"name":"mem_available","rename":"MemoryAvailable"}
                          ]
                       }
                    },
                    "append_dimensions":{
                       "InstanceId":"$${aws:InstanceId}",
                       "ImageId":"$${aws:ImageId}",
                       "InstanceType":"$${aws:InstanceType}",
                       "AutoScalingGroupName":"$${aws:AutoScalingGroupName}"
                    },
                    "aggregation_dimensions":[["AutoScalingGroupName"]]
                 }
              }
              EOT

              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              EOF

  tags = {
    Name = "${var.instance_name_prefix}-${count.index}"
  }
}

# 出力
output "instance_public_ips" {
  value = [for instance in aws_instance.example : instance.public_ip]
}
