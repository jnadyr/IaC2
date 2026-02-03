resource "aws_security_group" "grupo_de_seguranca" {
  name        = var.grupo_de_seguranca  # Nome do grupo de segurança
  description = "Grupo de seguranca para acesso SSH e porta 8000"
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port   = 8000 
    to_port     = 8000
    protocol    = "tcp"

    }
  
egress {
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port   = 0 
    to_port     = 0
    protocol    = "-1"
    }
    tags = {
    Name = "acesso_geral"
    }
}