resource "aws_vpc" "test-vpc" {
  cidr_block = "10.10.0.0/16"
  # enable_dns_support   = true # -- 이 옵션은 cloud front가 public으로 연결되어있는 것이라 필요 없을 것 같음
  # enable_dns_hostnames = true # -- 이 옵션은 cloud front가 public으로 연결되어있는 것이라 필요 없을 것 같음
  tags = {
    Name = "Test Codedang VPC"
  }
}

resource "aws_internet_gateway" "test-internet_gateway" {
  vpc_id = aws_vpc.test-vpc.id
}

resource "aws_subnet" "test-pub_subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = "10.10.0.0/22"
}

resource "aws_route_table" "test-public" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-internet_gateway.id # 수정할 부분
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.test-pub_subnet.id
  route_table_id = aws_route_table.test-public.id # 수정할 부분
}


resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.test-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # cloud front로 하려면 수정할수도 -> ALB security group 으로 변경해야할 것 같음
  }
  # Inbound traffic is narrowed to two ports: 22 for SSH and 443 for HTTPS needed to download the docker image from ECR. public이 필수인가..?
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # cloud front로 하려면 수정할수도 -> ALB security group 으로 변경해야할 것 같음
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # cloud front로 하려면 수정할수도 -> ALB security group 으로 변경해야할 것 같음
  }
}


