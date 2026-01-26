terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}


provider "aws"{
  region = var.regiao_aws
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f5fcdfbd140e4ab7"
  instance_type = var.instancia
  key_name      = var.chave # Linha CRUCIAL: Associando a chave SSH à instância
  security_groups = [aws_security_group.grupo_de_seguranca.name] # Associando o grupo de segurança à instância
}

resource "aws_key_pair" "chave_SSH"  {
    key_name   = var.chave
    public_key = file("${var.chave}.pub") # Lê a chave pública do arquivo
    
  }
output IP_publico {
    value = aws_instance.app_server.public_ip # Exibe o IP público da instância criada
  }
