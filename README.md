# Terraform AWS EC2 Provisioning

このリポジトリは、Terraformを使用してAWS EC2インスタンスを作成する構成です。

## 使用方法

以下の手順でTerraformを実行します：

terraform init  
terraform plan  
terraform apply

## 変数ファイルの構成

変数は以下のような形式で `terraform.tfvars` ファイルを作成します。  
※認証情報や秘密鍵パスなどは外部に公開しないよう注意してください。

```hcl
aws_access_key       = "YOUR_AWS_ACCESS_KEY"
aws_secret_key       = "YOUR_AWS_SECRET_KEY"
ami_id               = "ami-xxxxxxxxxxxxxxxxx"
instance_type        = "t3a.nano"
instance_count       = 2
instance_name_prefix = "MyEC2"
key_name             = "your-key-name"
public_key_path      = "/path/to/your/public/key.pub"
```

このファイルには認証情報を含めるため、.gitignore で除外しています。

## 注意事項

- terraform.tfvars は Git に登録されないようになっています。
- AWS認証情報は漏れないように注意してください。
- このプロジェクトは学習目的で作成されています。
