module "aws-dev" {
  source = "../../Infra" # Caminho para o módulo Infra

  regiao_aws = "us-east-2"
  chave      = "Key-IaC-Dev"
  instancia   = "t3.micro"
  grupo_de_seguranca = "DEV"  # Nome do grupo de segurança para o ambiente de desenvolvimento
  minimo       = 1            # Número mínimo de instâncias no ASG 
  maximo       = 1            # Número máximo de instâncias no ASG
  nomeGrupoASG = "ASG-Dev"    # Nome do grupo de Auto Scaling
  producao = true             # Variável para indicar ambiente de produção (false para Dev) 
}
