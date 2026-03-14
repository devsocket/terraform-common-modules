# terraform-common-modules
Reusable Terraform modules for Azure landing zone patterns.
Consumed by [terraform-landing-zone-demo](https://github.com/devsocket/terraform-landing-zone-demo) and future projects.

## Structure
```
modules/
├── governance/
│   ├── policy_set/             # Azure Policy sets at MG scope
│   └── role_assignments/       # RBAC assignments
├── identity/
│   ├── groups_and_roles/       # AAD groups + role mappings
│   └── workload_identity/      # Federated workload identity for AKS
├── management/
│   └── log_analytics/          # Log Analytics workspace + solutions
├── connectivity/
│   ├── hub_vnet/               # Hub VNet + subnets + route tables
│   ├── spoke_vnet/             # Spoke VNet + subnets + peering + UDR
│   ├── peering/                # Bidirectional VNet peering (standalone)
│   ├── private_dns/            # Private DNS zones + VNet links
│   └── bastion/                # Azure Bastion host
├── security/
│   └── key_vault_standards/    # Key Vault with opinionated defaults
├── app_platform/
│   ├── acr/                    # Azure Container Registry + private endpoint
│   ├── key_vault/              # App-level Key Vault + private endpoint
│   ├── storage/                # Storage Account + private endpoint
│   ├── aks_cluster/            # AKS with AGIC + workload identity
│   └── app_gateway_waf_agic/   # App Gateway WAF v2 + AGIC
└── monitoring/
    ├── diagnostic_settings/    # Reusable diagnostic settings
    └── alerts/                 # Metric + log alerts
```

## Usage

Reference locally during development:
```hcl
module "log_analytics" {
  source = "../../terraform-common-modules/modules/management/log_analytics"
}
```

Switch to GitHub source when ready:
```hcl
module "log_analytics" {
  source = "github.com/devsocket/terraform-common-modules//modules/management/log_analytics?ref=v1.0.0"
}
```

## Requirements
- Terraform >= 1.6.0
- AzureRM provider >= 3.90.0, < 4.0.0

## Versioning
Tag releases with semantic versioning e.g. `v1.0.0` before referencing via GitHub source.