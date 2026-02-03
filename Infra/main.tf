terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92" # Versão do provedor AWS
       }
  }

  required_version = ">= 1.2"  # Versão mínima do Terraform
}


provider "aws"{
  region = var.regiao_aws
}

resource "aws_launch_template" "maquina" { # Recurso Launch Template
  image_id      = "ami-0f5fcdfbd140e4ab7" # imagem do Ubuntu 22.04 na região us-east-2
  instance_type = var.instancia
  key_name      = var.chave # Linha CRUCIAL: Associando a chave SSH à instância
  tags = {
    Name = "Terraform Ansible Python"
  }
 security_group_names = [var.grupo_de_seguranca] # Associando o grupo de segurança ao ASG
  user_data = var.producao ? filebase64("ansible.sh") : "" # Script de inicialização da instância
  # se o ambiente for produção (V), carrega o script ansible.sh codificado em base64
  # caso contrário (F), não carrega nenhum script!
}

resource "aws_key_pair" "chave_SSH"  {
    key_name   = var.chave
    public_key = file("${var.chave}.pub") # Lê a chave pública do arquivo
    
  }

resource "aws_autoscaling_group" "grupo"{
  availability_zones = ["${var.regiao_aws}a", "${var.regiao_aws}b"] # Zona de disponibilidade dentro da região
  name = var.nomeGrupoASG                         # Nome do grupo de Auto Scaling
  min_size = var.minimo
  max_size = var.maximo
   launch_template {
    id      = aws_launch_template.maquina.id # Referência ao Launch Template
    version = "$Latest" # Utiliza a versão mais recente do Launch Template
  }
  target_group_arns = var.producao ? [aws_lb_target_group.target_group_producao[0].arn] : [] # Associação ao Target Group do Load Balancer
}
resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.regiao_aws}a"
    tags = {
    Name = "Terraform Subnet 1"
  }
}
resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.regiao_aws}b"
      tags = {
    Name = "Terraform Subnet 2"
  }
}
resource "aws_lb" "load_balancer_producao" {      # Recurso Load Balancer
  name               = "load-balancer-terraform"  # Nome do Load Balancer
  internal           = false                      # Load Balancer público
  load_balancer_type = "application"              # Tipo do Load Balancer
#  security_groups    = [var.grupo_de_seguranca]
   subnets            =  [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]  # Subnets associadas ao Load Balancer
   count= var.producao ? 1 : 0                          # Cria o Load Balancer apenas se for ambiente de produção
  tags = {
    Name = "Terraform Load Balancer"              # Tags para o Load Balancer
  }
}
resource "aws_lb_target_group" "target_group_producao" {  # Recurso Target Group
  name     = "target-group-terraform"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id                   # VPC associada ao Target Group
  count= var.producao ? 1 : 0  # Cria o Target Group apenas se for ambiente de produção
  health_check {
    path                = "/"                     # Caminho para verificação de integridade
    protocol            = "HTTP"                  # Protocolo da verificação de integridade
    matcher             = "200"                   # Código de resposta esperado
    interval            = 30                      # Intervalo entre as verificações
    timeout             = 5                       # Tempo limite para a verificação
    healthy_threshold   = 5                       # Número de verificações bem-sucedidas para considerar saudável
    unhealthy_threshold = 2                     # Número de verificações malsucedidas para considerar não saudável
  }

  tags = {
    Name = "Terraform Target Group"
  }
}
resource "aws_default_vpc" "default" {            # Recurso VPC Padrão
   tags = {
     Name = "Terraform Default VPC"               # Tags para a VPC
   }
}
resource "aws_lb_listener" "entrada_listener_producao" {      # Recurso Listener do Load Balancer
  load_balancer_arn = aws_lb.load_balancer_producao[0].arn    # Referência ao Load Balancer
  port              = 8000                                    # Porta de escuta do Listener
  protocol          = "HTTP"                                  # Protocolo do Listener

  default_action {                                            # Ação padrão do Listener
    type             = "forward"                              # Tipo de ação: encaminhar
    target_group_arn = aws_lb_target_group.target_group_producao[0].arn    # Referência ao Target Group
  }
  count= var.producao ? 1 : 0                               # Cria o Listener apenas se for ambiente de produção
}
resource "aws_autoscaling_policy" "scale_out_policy_producao" {  # Recurso Política de Auto Scaling para scale out
  name                   = "scale-out-policy-terraform"       # Nome da política
  autoscaling_group_name = var.nomeGrupoASG                   # Referência ao grupo de Auto Scaling
  # depends_on = [aws_autoscaling_group.nomeGrupoASG]           # Garante que o ASG seja criado antes da política
  policy_type           = "TargetTrackingScaling"             # Tipo de política
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"     # Métrica pré-definida: Utilização média de CPU do ASG
    }
    target_value = 50.0                                       # Valor alvo da métrica (50% de CPU)
  }
  count= var.producao ? 1 : 0                                 # Cria a política apenas se for ambiente de produção
 # scaling_adjustment     = 1                                  # Ajuste de escala (adiciona 1 instância)
 # adjustment_type        = "ChangeInCapacity"                 # Tipo de ajuste
}
