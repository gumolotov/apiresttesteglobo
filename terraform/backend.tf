terraform {
  backend "s3" {
    bucket         = "terraform-state-restapi-globo"  # Nome do bucket S3
    key            = "terraform/terraform.tfstate"  # Caminho dentro do bucket
    region         = "us-east-1"  # Região do S3
    encrypt        = true  # Habilitar criptografia
    dynamodb_table = "terraform-locks"  # Nome da tabela DynamoDB
  }
}
