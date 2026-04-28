# 🚀 AWS Multi-Tier Infrastructure with Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.14+-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)
![Status](https://img.shields.io/badge/Status-Active-success)

> Infraestrutura Multi-Tier completa na AWS, provisionada 100% como código com Terraform. Inclui VPC com subnets em múltiplas Availability Zones, Auto Scaling Group com Application Load Balancer, RDS PostgreSQL Multi-AZ com backup automático e monitoramento completo com CloudWatch.

---

## 📐 Architecture

<img src="docs/aws_multi_tier_architecture.svgZone.Identifier" width="600"/>


### 🌐 Load Balancing — ALB distribuindo entre AZs

<img src="docs/Captura%20de%20tela%202026-04-28%20072921.png" width="600"/>
<img src="docs/Captura%20de%20tela%202026-04-28%20072915.png" width="600"/>

### 🗺️ VPC Resource Map

<img src="docs/Captura%20de%20tela%202026-04-28%20075251.png" width="600"/>

### 🗄️ RDS PostgreSQL Multi-AZ

<img src="docs/Captura%20de%20tela%202026-04-28%20074151.png" width="600"/>
<img src="docs/Captura%20de%20tela%202026-04-28%20075606.png" width="600"/>

### 📊 CloudWatch Monitoring

<img src="docs/Captura%20de%20tela%202026-04-28%20081559.png" width="600"/>
<img src="docs/Captura%20de%20tela%202026-04-28%20081546.png" width="600"/>
---

## ✅ What this project solves

Every production company needs infrastructure that:

- **Scales automatically** — handles traffic spikes without manual intervention
- **Survives AZ failures** — Multi-AZ redundancy for both app and database tiers
- **Recovers from incidents** — automated health checks, failover and alerting
- **Is repeatable** — zero manual clicks, same result every deploy

This project implements all of the above in ~32 Terraform resources across 5 modules.

---

## 🧱 Modules

| Module | Resources | Description |
|---|---|---|
| `vpc` | 19 | VPC, subnets, IGW, NAT Gateway, route tables |
| `alb` | 4 | ALB, Target Group, Listener, Security Group |
| `ec2-asg` | 5 | Launch Template, ASG, scaling policies, Security Group |
| `rds` | 4 | PostgreSQL 16 Multi-AZ, subnet group, parameter group, Security Group |
| `monitoring` | 8 | CloudWatch alarms (x5), SNS topic, email subscription, dashboard |

---

## 🗂️ Project Structure

```
projeto-aws-multi-tier/
│
├── main.tf              # Provider + module declarations
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values (not committed)
├── .gitignore
│
└── modules/
    ├── vpc/             # VPC, subnets, IGW, NAT, route tables
    ├── alb/             # Load Balancer, Target Group, Listener
    ├── ec2-asg/         # Launch Template, ASG, scaling policies
    ├── rds/             # RDS PostgreSQL Multi-AZ
    └── monitoring/      # CloudWatch Alarms, SNS, Dashboard
```

---

## 🔒 Security Design

Security follows the **principle of least privilege** at every layer:

```
Internet → ALB SG     (ports 80/443 open)
ALB SG   → EC2 SG     (port 80 from ALB only)
EC2 SG   → RDS SG     (port 5432 from EC2 only)
RDS           ←        (no public access, isolated subnets)
```

- EC2 instances run in **private subnets** — never directly accessible from internet
- RDS runs in **isolated database subnets** — no route to internet
- All storage **encrypted at rest** (RDS `storage_encrypted = true`)
- NAT Gateway allows EC2 to reach internet for updates (outbound only)

---

## 📊 Monitoring & Alerting

| Alarm | Threshold | Action |
|---|---|---|
| CPU High (EC2) | > 70% for 4 min | Scale out + email |
| CPU Low (EC2) | < 20% for 4 min | Scale in + email |
| ALB 5XX Errors | > 10/min | Email alert |
| RDS CPU High | > 80% for 4 min | Email alert |
| RDS Storage Low | < 5 GB | Email alert |

CloudWatch Dashboard: EC2 CPU, ALB Request Count, ALB 5XX, RDS CPU, RDS Free Storage.

---

## ⚙️ Auto Scaling Configuration

```hcl
desired_capacity = 2
min_size         = 1
max_size         = 4

scale_out: +1 instance when CPU > 70% (cooldown: 300s)
scale_in:  -1 instance when CPU < 20% (cooldown: 300s)
```

---

## 🗄️ RDS Configuration

```
Engine:           PostgreSQL 16.3
Instance class:   db.t3.micro
Storage:          20 GB gp2 (encrypted)
Multi-AZ:         true (automatic failover)
Backup:           7 days retention (window: 03:00–04:00 UTC)
Public access:    false
```

---

## 🚀 How to deploy

### Prerequisites

- [Terraform >= 1.3](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials
- AWS account with permissions for EC2, VPC, RDS, CloudWatch, SNS

### 1. Clone the repository

```bash
git clone https://github.com/SEU_USUARIO/projeto-aws-multi-tier.git
cd projeto-aws-multi-tier
```

### 2. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "multi-tier"
environment  = "dev"
db_username  = "dbadmin"
db_password  = "YourSecurePassword123!"
alert_email  = "your@email.com"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access the application

After apply completes (~15 minutes), access the ALB DNS from the output:

```bash
terraform output alb_dns_name
```

Open in browser — you'll see the instance ID and AZ of the serving EC2.
Reload a few times to observe the load balancer distributing between AZs.

---

## 📤 Key Outputs

| Output | Description |
|---|---|
| `alb_dns_name` | Public URL of the Load Balancer |
| `vpc_id` | VPC ID |
| `rds_endpoint` | RDS connection endpoint (sensitive) |
| `dashboard_url` | CloudWatch Dashboard URL |
| `nat_gateway_ip` | NAT Gateway public IP |

---

## 💰 Estimated Cost (us-east-1)

| Resource | Cost/hour |
|---|---|
| EC2 t3.micro x2 | ~$0.021 |
| NAT Gateway | ~$0.045 |
| ALB | ~$0.008 |
| RDS db.t3.micro Multi-AZ | ~$0.040 |
| **Total** | **~$0.11/hour** |

> ⚠️ Remember to destroy resources after testing to avoid unexpected charges.

```bash
terraform destroy
```

---

## 🧹 Destroy

To tear down all resources:

```bash
terraform destroy
```

To destroy only the RDS (most expensive):

```bash
terraform destroy -target=module.rds
```

---

## 📚 Skills demonstrated

- **Infrastructure as Code** with Terraform (modules, variables, outputs, state)
- **AWS Networking** — VPC, subnets, route tables, IGW, NAT Gateway, Security Groups
- **High Availability** — Multi-AZ deployment for both app and database tiers
- **Auto Scaling** — Launch Template, ASG with CPU-based scaling policies
- **Load Balancing** — ALB with health checks, target groups and listeners
- **Database** — RDS PostgreSQL with Multi-AZ, encryption and automated backups
- **Observability** — CloudWatch Alarms, SNS notifications, custom Dashboard
- **Security** — Least-privilege Security Groups, private subnets, encryption at rest

---

## 👤 Author

**Marcos Barbosa**
- LinkedIn: [linkedin.com/in/60bb4023b](https://linkedin.com/in/60bb4023b)
- Email: marcdev.b@gmail.com
- 📍 Rio de Janeiro, RJ — Brazil

AWS Certified Solutions Architect – Associate | AWS Certified Cloud Practitioner

---

## 📄 License

MIT License — feel free to use this as reference for your own projects.
