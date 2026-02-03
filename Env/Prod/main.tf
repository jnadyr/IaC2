module "aws-prod" {
  source = "../../Infra" # Caminho para o módulo de infraestrutura

  regiao_aws = "us-east-2"
  chave      = "Key-IaC-Prod"
  instancia   = "t3.micro"
  grupo_de_seguranca = "producao" # Nome do grupo de segurança para o ambiente de produção
  minimo       = 1                # Número mínimo de instâncias no ASG 
  maximo       = 10               # Número máximo de instâncias no ASG
  nomeGrupoASG  = "ASG-Producao"  # Nome do grupo de Auto Scaling
  producao = true                 # Variável para indicar ambiente de produção (true para Prod)
  } 