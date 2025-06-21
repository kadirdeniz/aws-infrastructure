# AWS Infrastructure Scripts

Bu dizin, AWS altyapısını deploy etmek ve destroy etmek için kullanılan scriptleri içerir.

## Scriptler

### 1. `deploy.sh` - Deployment Scripti

AWS altyapısını deploy etmek için kullanılır.

#### Kullanım:
```bash
./deploy.sh [OPTIONS]
```

#### Seçenekler:
- `-e, --environment ENV` - Deploy edilecek environment (dev/prod) [varsayılan: dev]
- `-a, --auto-approve` - Terraform değişikliklerini otomatik onayla
- `-p, --plan-only` - Sadece plan oluştur, uygulama
- `-n, --no-backup` - Terraform state'ini yedekleme
- `-h, --help` - Yardım mesajını göster

#### Örnekler:
```bash
# Dev environment'ı prompt'larla deploy et
./deploy.sh

# Prod environment'ı otomatik onayla deploy et
./deploy.sh -e prod -a

# Sadece dev environment için plan oluştur
./deploy.sh -e dev -p

# Prod environment'ı state yedeklemeden deploy et
./deploy.sh -e prod -a -n
```

#### Gerekli Environment Variables:
```bash
export TF_VAR_db_username=myuser
export TF_VAR_db_password=mypassword
```

### 2. `destroy.sh` - Destroy Scripti

AWS altyapısını güvenli bir şekilde destroy etmek için kullanılır.

⚠️ **UYARI**: Bu script tüm AWS kaynaklarını kalıcı olarak siler!

#### Kullanım:
```bash
./destroy.sh [OPTIONS]
```

#### Seçenekler:
- `-e, --environment ENV` - Destroy edilecek environment (dev/prod) [varsayılan: dev]
- `-a, --auto-approve` - Terraform destroy'ı otomatik onayla
- `-p, --plan-only` - Sadece destroy planı oluştur, çalıştırma
- `-n, --no-backup` - Terraform state'ini yedekleme
- `-f, --force` - Onay prompt'larını atla
- `-h, --help` - Yardım mesajını göster

#### Örnekler:
```bash
# Dev environment'ı prompt'larla destroy et
./destroy.sh

# Prod environment'ı otomatik onayla destroy et
./destroy.sh -e prod -a

# Sadece dev environment için destroy planı oluştur
./destroy.sh -e dev -p

# Dev environment'ı force ile destroy et
./destroy.sh -e dev -f
```

### 3. `generate_env.sh` - .env Dosyası Oluşturma Scripti

AWS Secrets Manager'dan .env dosyası oluşturmak için kullanılır.

#### Kullanım:
```bash
./generate_env.sh [OPTIONS]
```

#### Seçenekler:
- `-e, --environment ENV` - Environment (dev/prod) [varsayılan: dev]
- `-p, --project NAME` - Proje adı [varsayılan: aws-infrastructure]
- `-s, --secret-name NAME` - Secret adı (otomatik oluşturulan adı geçersiz kılar)
- `-r, --region REGION` - AWS region [varsayılan: eu-central-1]
- `-f, --force` - Mevcut .env dosyasını zorla üzerine yaz
- `-h, --help` - Yardım mesajını göster

#### Örnekler:
```bash
# Dev environment için .env dosyası oluştur
./generate_env.sh

# Prod environment için .env dosyası oluştur
./generate_env.sh -e prod

# Mevcut .env dosyasını zorla üzerine yaz
./generate_env.sh -e dev -f

# Özel secret adı kullan
./generate_env.sh -s my-custom-secret
```

#### Oluşturulan .env Dosyası İçeriği:
```bash
# Database credentials
db_host=your-rds-endpoint
db_port=5432
db_name=appdb
db_username=myuser
db_password=mypassword

# S3 bucket information
s3_backend_bucket_name=aws-infrastructure-dev-backend-storage
s3_frontend_bucket_name=aws-infrastructure-dev-frontend-storage
s3_backend_bucket_arn=arn:aws:s3:::aws-infrastructure-dev-backend-storage
s3_frontend_bucket_arn=arn:aws:s3:::aws-infrastructure-dev-frontend-storage

# Environment information
environment=dev
project=aws-infrastructure
region=eu-central-1
```

## Ön Gereksinimler

### 1. Terraform Kurulumu
```bash
# macOS (Homebrew)
brew install terraform

# Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs)"
sudo apt-get update && sudo apt-get install terraform

# Windows (Chocolatey)
choco install terraform
```

### 2. AWS CLI Kurulumu
```bash
# macOS (Homebrew)
brew install awscli

# Ubuntu/Debian
sudo apt-get install awscli

# Windows (Chocolatey)
choco install awscli
```

### 3. jq Kurulumu (generate_env.sh için)
```bash
# macOS (Homebrew)
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Windows (Chocolatey)
choco install jq
```

### 4. AWS Kimlik Bilgileri
```bash
aws configure
```

### 5. Terraform Konfigürasyonu
```bash
# terraform.tfvars dosyasını oluştur
cp ../terraform/terraform.tfvars.example ../terraform/terraform.tfvars

# Dosyayı düzenle
nano ../terraform/terraform.tfvars
```

## Deployment Süreci

### 1. İlk Deployment
```bash
# Environment variables'ları ayarla
export TF_VAR_db_username=myuser
export TF_VAR_db_password=mypassword

# Dev environment'ı deploy et
./deploy.sh -e dev

# Veya otomatik onayla
./deploy.sh -e dev -a
```

### 2. Production Deployment
```bash
# Prod environment'ı deploy et
./deploy.sh -e prod -a
```

### 3. Sadece Plan Oluşturma
```bash
# Değişiklikleri görmek için plan oluştur
./deploy.sh -e dev -p
```

## .env Dosyası Oluşturma

### 1. Infrastructure Deploy Edildikten Sonra
```bash
# Dev environment için .env dosyası oluştur
./generate_env.sh -e dev

# Prod environment için .env dosyası oluştur
./generate_env.sh -e prod
```

### 2. .env Dosyasını Kullanma
```bash
# Node.js uygulamasında
source .env
# veya
export $(cat .env | xargs)

# Python uygulamasında
python-dotenv kullanarak
```

## Destroy Süreci

### 1. Güvenli Destroy
```bash
# Dev environment'ı destroy et (onay gerekli)
./destroy.sh -e dev
```

### 2. Force Destroy
```bash
# Onay prompt'larını atla
./destroy.sh -e dev -f
```

### 3. Sadece Destroy Planı
```bash
# Ne silineceğini görmek için plan oluştur
./destroy.sh -e dev -p
```

## Güvenlik

### 1. State Yedekleme
Scriptler otomatik olarak Terraform state'ini yedekler:
- Yedekler `../backups/` dizininde saklanır
- Timestamp ile isimlendirilir
- `-n, --no-backup` ile devre dışı bırakılabilir

### 2. Onay Mekanizması
- Destroy scripti çift onay gerektirir
- `-f, --force` ile atlanabilir
- `-a, --auto-approve` ile otomatik onaylanabilir

### 3. Environment Variables
- Hassas bilgiler environment variables olarak saklanır
- `terraform.tfvars` dosyasında hardcode edilmez
- `.env` dosyası `.gitignore`'da yer alır

### 4. Secrets Manager
- Tüm hassas bilgiler AWS Secrets Manager'da saklanır
- S3 bucket bilgileri de secret'lara dahil edilir
- Otomatik rotation desteklenir

## Hata Ayıklama

### 1. Prerequisites Kontrolü
Scriptler otomatik olarak şunları kontrol eder:
- Terraform kurulumu
- AWS CLI kurulumu
- AWS kimlik bilgileri
- Gerekli environment variables
- jq kurulumu (generate_env.sh için)

### 2. Log Dosyaları
- Loglar `../logs/` dizininde saklanır
- Hata durumunda detaylı bilgi verilir

### 3. Terraform Komutları
Hata durumunda manuel olarak çalıştırabilirsiniz:
```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

## Best Practices

### 1. Environment Management
- Her environment için ayrı `terraform.tfvars` kullanın
- Environment-specific değişkenleri ayrı dosyalarda saklayın

### 2. State Management
- State dosyalarını version control'e commit etmeyin
- Remote state kullanmayı düşünün (S3 + DynamoDB)

### 3. Security
- Hassas bilgileri environment variables olarak saklayın
- IAM rollerini minimum yetki prensibi ile yapılandırın
- `.env` dosyalarını asla commit etmeyin

### 4. Monitoring
- CloudWatch alarmlarını etkinleştirin
- Logları düzenli olarak kontrol edin

### 5. Secrets Management
- Tüm hassas bilgileri AWS Secrets Manager'da saklayın
- `.env` dosyalarını otomatik olarak oluşturun
- Secret rotation'ı etkinleştirin

## Troubleshooting

### 1. Terraform State Lock
```bash
# State lock'u kaldır
terraform force-unlock <LOCK_ID>
```

### 2. Provider Issues
```bash
# Provider'ları yeniden initialize et
terraform init -upgrade
```

### 3. AWS Credentials
```bash
# AWS kimlik bilgilerini kontrol et
aws sts get-caller-identity
```

### 4. Network Issues
```bash
# VPC ve subnet'leri kontrol et
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

### 5. Secrets Manager Issues
```bash
# Secret'ları listele
aws secretsmanager list-secrets

# Secret değerini kontrol et
aws secretsmanager get-secret-value --secret-id your-secret-name
```

### 6. .env Dosyası Sorunları
```bash
# jq kurulumunu kontrol et
jq --version

# Secret'ın var olup olmadığını kontrol et
aws secretsmanager describe-secret --secret-id your-secret-name
``` 