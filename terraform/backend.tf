terraform {
  backend "s3" {
    bucket         = "nome-do-seu-bucket-terraform-state"  # Nome do bucket S3
    key            = "terraform/production/terraform.tfstate"  # Caminho dentro do bucket
    region         = "us-east-1"  # Região do S3
    encrypt        = true  # Habilitar criptografia
    dynamodb_table  = "terraform-locks"  # Nome da tabela DynamoDB
  }
}
