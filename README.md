# TerraformでWordPressをALB,ECS,Auroraにデプロイする

## 概要

Terraformを用いて以下の構成要素をデプロイします。

- WordPressアプリケーションを定義したECSタスク
- WordPressのユーザーデータを保存するAuroraデータベース
- 記事データを永続化するEFSファイルシステム
- 画像ファイルを保存するS3バケット
- ECSを配下に持つALB
- ALBへのレコードを持つRoute53 ホストゾーン
- Certificate Managerによる独自ドメインを使用したHTTPS対応

## 構成図

## デプロイ手順

### 前提条件

以下の環境で動作を確認しています。

- macOS `26.1`
- AWS CLI `aws-cli/2.32.6 Python/3.13.9 Darwin/25.1.0 source/arm64`
- Terraform `v1.14.0`
- Git `2.50.1 `

デプロイを行う作業者にAWSのAdministratorAccess権限等リソースのデプロイに必要な権限が割り当てられているものとします。

本コードでは既存のRoute53ホストゾーン及びACM証明書を発行済と想定しています。

また、ホストゾーン用に独自ドメインを取得済みとしています。

デフォルトではap-northeast-1にリソースが構築されます。

### セットアップ

AWS認証情報を設定済みorSSOログイン済みとします

```bash
git clone https://github.com/michinoku-YoRHa/terraform-aws-wordpress-infra.git
cd environment/dev
terraform init
```

### environment/dev/main.tf

`alb_module`内の`domain_name`を取得したドメイン名に変更してください。

```hcl
module "alb_module" {
  domain_name = "*.your-domain.com"
}
```

`route53_module`内の`host_zone_name`を作成済みのホストゾーン名に変更してください。

```hcl
module "route53_module" {
  host_zone_name = "your-domain.com"
}
```

### デプロイ

```bash
terraform apply
```

### 静的ファイル格納先の変更

**WordPressの初期設定完了後の作業となります**

プラグインを使用して画像ファイルをS3バケットに作成するように指定します。

## リソース選定理由

### Amazon Aurora
- 構築経験がなかったため練習として選択
- RDSと比較した際、水平スケーリングの実現による拡張性の向上が見込める点

### NAT Gateway
- 本検証において、データ転送量による利用量が無視できるほど小さいと想定。VPCエンドポイントの作成数からNAT Gatewayの方が利用料を抑えられると判断したため
- なお、ゲートウェイ型S3エンドポイントについては構築自体に料金がかからないことから構築することとした

### WordPressイメージ
- 本検証においてECR上にWordPressイメージを格納する必要がなくなる点、イメージの更新運用が不要となる点からDockerHubにて公開されているイメージを使用することとした

## 今後のTodo

- CloudWatchアラームによるリソース監視システムの構築
- CloudFrontディストリビューションによる静的コンテンツのキャッシュ
- AWS WAFを使用したネットワーク保護
- デプロイパイプラインの実装