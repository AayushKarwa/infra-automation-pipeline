#----------------VPC---------------------
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.project_name}-vpc"
    }
}
#-----------------IGW----------------------
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "${var.project_name}-igw"
    }
  
}
#------------------PUBLIC SUBNETS---------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  # Instances in public subnets get a public IP automatically
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Tier = "public"
  }
}
#----------------------PRIVATE SUBNET------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  #Instances in private subnets do not get public IP's
  map_public_ip_on_launch = false 

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Tier = "private"
  }
}
#--------------ELASTIC IP FOR NAT GW----------------------------
# NAT GW NEEDS A STATIC PUBLIC IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [ aws_internet_gateway.main ]
}
#-----------------------NAT GW----------------------------------
# LIVES IN PUBLIC SUBNETS, ALLOWS PRIVATE SUBNET ----> INTERNET (NOT REVERSE)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [ aws_internet_gateway.main ]
}
#--------------------------ROUTE TABLE: PUBLIC-------------------------------
# PUBLIC SUBNETS ROUTE INTERNET TRAFFIC THROUGH THE IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
  
}

#------------------ROUTE TABLE: PRIVATE------------------------------------
# private subnets route the internet traffic through the nat gw
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id 
}