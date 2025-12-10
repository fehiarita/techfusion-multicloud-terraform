# Documentação Técnica – Infraestrutura Multicloud (AWS + Azure)

## 1. Visão geral
*   **Infraestrutura como Código (IaC):** Terraform para AWS e Azure, com foco inicial no ambiente `dev` (replicável para `prod`).
*   **Workloads Espelhados:** Aplicação containerizada, CDN + assets estáticos e banco de dados gerenciado em ambas as nuvens.
*   **Gerenciamento de Estado:** Estado remoto do Terraform armazenado em AWS S3 com tabela DynamoDB para controle de lock (`bootstrap/backend-aws`).

---

## 2. Arquitetura

![Arquitetura Multicloud](https://www.figma.com/board/jVNjdfhjXzqhZDS0iFMDzD/Multicloud-Architecture-AWS-Azure---Icon-Enhanced?node-id=0-1&t=fQrTbPdHR2I7Ipoq-1)

---

## 3. Decisões de design

*   **Multicloud paralela:** Provisionamento de recursos equivalentes em AWS e Azure. O objetivo é reduzir o *vendor lock-in* e permitir testes comparativos reais de performance e custos.
*   **Segmentação de rede:**
    *   **AWS:** Subnets públicas para entrada (ALB/CloudFront) e privadas para aplicações e bancos (com NAT Gateway).
    *   **Azure:** VNet Integration para isolamento, garantindo que o App Service se comunique de forma segura com o backend.
*   **Containers gerenciados:** Uso de **ECS Fargate** (AWS) e **App Service Linux** (Azure) para eliminar a gestão de servidores, habilitar autoescalonamento e health checks nativos.
*   **Bancos gerenciados:** **RDS PostgreSQL** e **Azure PostgreSQL Flexible Server**. Ambos configurados com backups automáticos, criptografia em repouso e janelas de manutenção definidas.
*   **CDN + Assets estáticos:** Combinação de CloudFront+S3 e Azure CDN+Blob Storage para entrega global de conteúdo e verificação de disponibilidade via páginas de status (`environments/dev/status`).
*   **Observabilidade básica:** CloudWatch Logs para tasks ECS e health checks em ALB/App Service. A arquitetura prevê espaço para integração futura de módulos de monitoramento (`modules/monitoring-*`).
*   **Automação CI:** Pipeline no Azure DevOps (`azure-pipelines.yml`) que executa o `terraform plan` no diretório `environments/dev`, autenticando em ambas as nuvens via variáveis de grupo.

---

## 4. Deploy passo a passo

### 1) Bootstrap do backend remoto (Executar uma vez por conta AWS)

Configuração inicial para armazenar o estado do Terraform:

    cd bootstrap/backend-aws
    terraform init
    terraform apply -var="region=us-east-1" -var="bucket_name=<estado-bucket>" -var="lock_table_name=tf-locks"

*Nota: Após a criação, configure os arquivos `environments/*/backend.tf` para apontar para o bucket e tabela criados.*

### 2) Preparar variáveis sensíveis

Antes de iniciar o deploy, exporte as credenciais necessárias:

*   **AWS:** Exportar `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_DEFAULT_REGION`.
*   **Azure:** Realizar login (`az login`) e definir `azure_subscription_id`, `azure_tenant_id`, `azure_client_id` e `azure_client_secret`.
*   **Database:** Definir senhas (`db_password`, `azure_db_password`) via arquivo `terraform.tfvars` ou variáveis de ambiente.

### 3) Deploy ambiente dev

Execução do provisionamento da infraestrutura de desenvolvimento:

    cd environments/dev
    terraform init

    terraform plan \
      -var="azure_subscription_id=..." \
      -var="azure_tenant_id=..." \
      -var="azure_client_id=..." \
      -var="azure_client_secret=..." \
      -var="db_password=..." \
      -var="azure_db_password=..."

    terraform apply -auto-approve \
      -var="azure_subscription_id=..." \
      -var="azure_tenant_id=..." \
      -var="azure_client_id=..." \
      -var="azure_client_secret=..." \
      -var="db_password=..." \
      -var="azure_db_password=..."

### 4) Deploy ambiente prod

Repita o passo anterior no diretório `environments/prod`, ajustando o arquivo `terraform.tfvars` conforme necessário (região, tamanho das instâncias, senhas de produção).

### 5) Pipeline Azure DevOps (Opcional)

*   Configure o Variable Group `tf-azure-dev` com as credenciais AWS/Azure e senhas.
*   O pipeline `azure-pipelines.yml` já executa o `terraform plan` em `environments/dev`. Habilite o step de `apply` conforme sua política de *change management*.

---

## 5. Estratégias de segurança e boas práticas

*   **Isolamento de rede:** Aplicações mantidas em subnets privadas (AWS) e VNet Integration (Azure). Apenas ALB, CloudFront e CDN são expostos publicamente.
*   **Mínimo privilégio:** Security Groups configurados para permitir tráfego estritamente necessário (ALB -> ECS e App -> DB). Utilize perfis/identidades de serviço específicas para o Terraform CI.
*   **Criptografia e backups:**
    *   RDS com `storage_encrypted` e retenção de backup de 7 dias.
    *   PostgreSQL Flexible com retenção configurada e opção geo-redundante.
*   **TLS e Saúde da Aplicação:** HTTPS habilitado no ALB/CloudFront/CDN. Opção `https_only` ativa no App Service. Health checks configurados para garantir alta disponibilidade.
*   **Proteção de estado:** Backend remoto em S3 com locking via DynamoDB para evitar condições de corrida. O acesso ao bucket deve ser restrito via IAM e o versionamento deve estar ativado.
*   **Gestão de Segredos:** Nunca versione senhas no código. Utilize Key Vault, Secrets Manager ou Variable Groups criptografados. Prefira a injeção via `TF_VAR_` ou pipelines seguras.
*   **Auditoria e observabilidade:** CloudWatch Logs ativado para ECS. Configure diagnósticos/Log Analytics no App Service e PostgreSQL Flexible para rastreabilidade completa.
*   **Escalonamento controlado:** Autoscaling do ECS baseado em CPU com limites definidos (min/max). Revise as configurações antes de habilitar o autoscaling no App Service para evitar custos inesperados.

---

## 6. Estimativa de Custos (Ambiente Dev)

Abaixo apresentamos uma estimativa mensal aproximada para o ambiente de desenvolvimento, considerando recursos de entrada (entry-level) e operação 24/7 (730 horas/mês).

### AWS (us-east-1)

| Recurso | Configuração Estimada | Custo Aprox. (Mensal) |
|:--------|:----------------------|:----------------------|
| **Application Load Balancer** | 1 ALB + LCUs mínimos | ~$22.00 |
| **ECS Fargate** | 2 Tasks (0.25 vCPU / 0.5 GB RAM) | ~$10.00 |
| **RDS PostgreSQL** | db.t3.micro (Single AZ) + 20GB Storage | ~$18.00 |
| **NAT Gateway** | 1 NAT Gateway (Custo fixo por hora) | ~$32.00 |
| **CloudFront + S3** | Tráfego baixo (< 10GB) | ~$1.00 |
| **Total AWS** | | **~$83.00** |

*Observacao importante:* Em ambiente `dev`, o NAT Gateway é o item mais caro. Considere usar uma instância NAT (EC2 t3.nano) ou rodar as tasks em subnets públicas restritas se a segurança da techfusion permitir, para economizar cerca de $30/mês.

### Azure (East US)

| Recurso | Configuração Estimada | Custo Aprox. (Mensal) |
|:--------|:----------------------|:----------------------|
| **App Service (Linux)** | Plano B1 (Basic) | ~$13.00 |
| **PostgreSQL Flexible** | Burstable B1ms (1 vCore, 2GB RAM) | ~$15.00 |
| **Azure CDN + Blob** | Standard Microsoft + 20GB Storage | ~$2.00 |
| **VNet / Bandwidth** | VNet Peering / Egress baixo | ~$2.00 |
| **Total Azure** | | **~$32.00** |

### Resumo Geral

*   **Total Combinado (AWS + Azure):** ~$115.00 / mês
*   *Nota: Valores baseados em preços públicos (On-Demand) vigentes em 2025. Impostos e taxas de transferência de dados excedentes não incluídos.*
