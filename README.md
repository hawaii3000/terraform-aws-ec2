# Terraform AWS EC2 Provisioning

このリポジトリは、Terraformを使用してAWS EC2インスタンスを作成する構成です。

## 使用方法

以下の手順でTerraformを実行します：

terraform init  
terraform plan  
terraform apply

## 変数ファイルの構成

変数は terraform.tfvars に定義します。  
このファイルには認証情報を含めるため、.gitignore で除外しています。

## 注意事項

- terraform.tfvars は Git に登録されないようになっています。
- AWS認証情報は漏れないように注意してください。
このプロジェクトは学習目的で作成されています。
