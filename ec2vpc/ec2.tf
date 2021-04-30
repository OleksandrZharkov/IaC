resource "aws_instance" "linux-instance" {
  ami           = "ami-0767046d1677be5a0"  #Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

  subnet_id = aws_subnet.32bits-subnet-public-3.id

  vpc_security_group_ids = [aws_security_group.32bits-all.id]

  key_name = "itea"

  tags = {
    "Name" = "linux-instance"
  }

  depends_on = [
    aws_db_instance.32bits-rds,
  ]
}