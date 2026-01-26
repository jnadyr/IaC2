variable "regiao_aws" {
  type        = string
  default     = "us-east-2"
  description = "Região AWS onde os recursos serão criados"
}
variable "chave" {
  type        = string
  
}
variable "instancia" {
  type        = string
  default     = "t3.micro"
  description = "Tipo da instância EC2 a ser criada"
}