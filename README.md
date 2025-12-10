# TechFusion: Iniciativa de Infraestrutura Híbrida (AWS & Azure)

Este repositório contém a definição de **Infraestrutura como Código (IaC)** para a plataforma TechFusion. O projeto adota uma estratégia **Multi-Cloud**, provisionando ambientes espelhados na Amazon Web Services (AWS) e Microsoft Azure para garantir resiliência máxima e independência de fornecedor.

---

## 🗺️ Mapa da Arquitetura

Abaixo, a representação visual de como nossos serviços se interconectam em ambos os provedores.

![Diagrama de Arquitetura em Nuvem](docs/cloud_architecture_diagram.png)


---

## 🏗️ Pilares da Solução

Nossa engenharia baseia-se em quatro pilares fundamentais para suportar a carga de trabalho da TechFusion:

### 1. Computação Serverless & PaaS
Eliminamos o gerenciamento de servidores tradicionais.
*   **Na AWS:** Utilizamos **ECS Fargate**, permitindo que containers Docker rodem sem a necessidade de provisionar instâncias EC2.
*   **No Azure:** Adotamos **App Service for Linux**, uma plataforma gerenciada que abstrai a infraestrutura subjacente e foca na aplicação.

### 2. Dados Gerenciados e Seguros
A persistência é crítica e tratada com serviços de ponta.
*   **AWS RDS (PostgreSQL):** Configurado em subnets privadas, inacessível via internet pública.
*   **Azure Database for PostgreSQL (Flexible):** Protegido via VNet Integration, garantindo que o tráfego de dados nunca saia da rede interna do Azure.

### 3. Entrega de Conteúdo Global (CDN)
Para garantir baixa latência em assets estáticos (imagens, JS, CSS):
*   **AWS:** Bucket S3 servido via **CloudFront**.
*   **Azure:** Storage Account servida via **Azure CDN**.

### 4. Isolamento de Rede
Segurança por design através de segmentação de rede rigorosa.
*   **VPC & VNet:** Redes virtuais isoladas em cada nuvem.
*   **Subnets:** Separação clara entre camadas públicas (Load Balancers) e privadas (Apps e Bancos).

---

## 🚀 Guia de Implantação (Deployment)

Siga os passos abaixo para provisionar o ambiente de desenvolvimento (`dev`).

### Pré-requisitos
*   Terraform >= 1.0
*   AWS CLI configurado
*   Azure CLI autenticado (`az login`)

### Passo 1: Configuração do Backend (Apenas na primeira vez)
O estado do Terraform é armazenado remotamente no S3 para permitir colaboração.
```bash
cd bootstrap/backend-aws
terraform init
terraform apply -var="bucket_name=seu-bucket-de-estado"
```

### Passo 2: Provisionamento do Ambiente
Navegue até o diretório do ambiente e inicie o Terraform.
```bash
cd environments/dev
terraform init
```

Para planejar e aplicar as mudanças, você precisará fornecer as credenciais e senhas sensíveis. Recomendamos o uso de um arquivo `terraform.tfvars` (não versionado) ou variáveis de ambiente.

```bash
# Exemplo de execução
terraform apply \
  -var="db_password=SuaSenhaSegura123" \
  -var="azure_db_password=SuaSenhaSeguraAzure123"
```

---

## 🛡️ Segurança e Compliance

*   **Criptografia:** Todos os dados em repouso (bancos de dados e buckets) são criptografados nativamente.
*   **Tráfego:** Todo tráfego de entrada é forçado via HTTPS (TLS 1.2+).
*   **Least Privilege:** Security Groups e NSGs liberam apenas as portas estritamente necessárias (ex: Porta 5432 do banco aceita apenas origem da Aplicação).

---

## 💰 Estimativa de Recursos (Dev)

Para fins de planejamento de capacidade em ambiente de desenvolvimento:
*   **AWS:** ~USD 85/mês (Principal custo: NAT Gateway e RDS).
*   **Azure:** ~USD 35/mês (Principal custo: App Service Plan e PostgreSQL).

> *Nota: Valores estimados baseados em tabelas de 2025, sujeitos a variação por região e uso.*

