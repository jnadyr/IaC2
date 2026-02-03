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
variable "grupo_de_seguranca" {
  type        = string
  description = "grupo de segurança a ser associado ao ASG"
}
variable minimo{
  type        = number
  description = "numero mínimo de instâncias no ASG"
}
variable maximo{
  type        = number
  description = "numero máximo de instâncias no ASG"
}
variable "nomeGrupoASG" {
  type        = string
  description = "nome do grupo de ASG"
}
variable "producao" {
  type        = bool
 # default     = false
  description = "Indica se o ambiente é de produção"
}