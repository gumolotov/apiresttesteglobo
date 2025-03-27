terraform {
  backend "s3" {
    bucket         = "terraform-state-restapi-globo"  # Nome do bucket S3
    key            = "terraform/terraform.tfstate"  # Caminho dentro do bucket
    region         = "us-east-1"  # Região do S3
    encrypt        = true  # Habilitar criptografia
    dynamodb_table  = "terraform-locks"  # Nome da tabela DynamoDB
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-restapi-globo"
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
