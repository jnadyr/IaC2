module "aws-prod" {
  source = "../../Infra" # Caminho para o módulo Infra

  regiao_aws = "us-east-2"
  chave      = "Key-IaC-Prod"
  instancia   = "t3.micro"
}
output "IP_publico_prod" {
  value = module.aws-prod.IP_publico # Exibe o IP público da instância no ambiente de produção
} 