# 1. S3 Bucket with Public Access and no Encryption
resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-very-insecure-test-bucket"
  acl    = "public-read" # Finding: Publicly readable bucket

  tags = {
    Environment = "Dev"
  }
}

# 2. Security Group allowing SSH to the whole world
resource "aws_security_group" "bad_sg" {
  name        = "allow_all_ssh"
  description = "Allow SSH from everywhere"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Finding: Port 22 open to the internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. EBS Volume without Encryption
resource "aws_ebs_volume" "unencrypted_volume" {
  availability_zone = "us-east-1a"
  size              = 40
  encrypted         = true
}

# 4. IAM Policy with Wildcard Permissions
resource "aws_iam_policy" "wildcard_policy" {
  name        = "dangerous_policy"
  path        = "/"
  description = "A very bad policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "*" # Finding: Overly permissive 'Allow All' action
        Effect   = "Allow"
        Resource = "*" # Finding: Resource wildcard
      },
    ]
  })
}
