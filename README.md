# terraform-common-modules

Reusable, composable Terraform modules for Azure Landing Zone patterns.
Designed for platform engineering teams building consistent, governed Azure infrastructure at scale.
Consumed by [terraform-landing-zone-demo](https://github.com/devsocket/terraform-landing-zone-demo) and intended for use across multiple other Azure environments.

---

## Design Philosophy

This library follows platform engineering principles — centralise infrastructure patterns once, consume them everywhere where required:

- **Single responsibility** — each module provisions one logical Azure resource group with clean input/output contracts
- **Version-pinned providers** — every module pins `azurerm` and related providers to avoid drift
- **Composable** — modules are designed to be called from Landing Zone configurations or standalone pipelines without modification
- **Opinionated defaults** — sensible security defaults baked in (RBAC, diagnostic settings, soft delete) — overridable via variables
- **Environment promotion** — same module code deploys to dev, staging, and production — environment differences expressed through variable inputs only

---

## Module Catalogue

```
modules/
├─ app_platform/
│   ├── acr/                       # Azure Container Registry + AcrPull role assignment
│   ├── key_vault/                 # Key Vault + RBAC mode + soft delete + diagnostics
│   ├── storage/                   # StorageV2 + containers + lifecycle policy + diagnostics
│   ├── aks_cluster/               # AKS + Azure CNI + AGIC + workload identity + OMS agent
│   └── app_gateway_waf_agic/      # App Gateway WAF v2 + OWASP 3.2 + AGIC lifecycle management
│
├── connectivity/
│   ├── hub_vnet/                  # Hub VNet + ManagementSubnet + optional GatewaySubnet
│   ├── spoke_vnet/                # Spoke VNet + subnets + bidirectional hub peering + UDR
│   └── private_dns/               # Private DNS zones + hub and spoke VNet links
│
└── management/
    └── log_analytics/             # Log Analytics workspace + ContainerInsights + SecurityInsights
```

**Planned modules (TBD):**
`governance/policy_set`, `governance/role_assignments`, `identity/workload_identity`, `connectivity/bastion`, `monitoring/diagnostic_settings`, `monitoring/alerts`

---

## Requirements

| Dependency | Version |
|---|---|
| Terraform | `>= 1.6.0` |
| AzureRM provider | `>= 3.90.0, < 4.0.0` |

---

## Usage

### Reference locally during development

```hcl
module "log_analytics" {
  source = "../../terraform-common-modules/modules/management/log_analytics"

  workspace_name      = "law-platform-dev-001"
  resource_group_name = "rg-management-monitoring"
  location            = var.location
  retention_in_days   = 30
  tags                = var.tags
}
```

### Reference via GitHub (pinned release)

```hcl
module "log_analytics" {
  source = "github.com/devsocket/terraform-common-modules//modules/management/log_analytics?ref=v1.0.0"

  workspace_name      = "law-platform-prod-001"
  resource_group_name = "rg-management-monitoring"
  location            = var.location
  retention_in_days   = 90
  tags                = var.tags
}

module "hub_vnet" {
  source = "github.com/devsocket/terraform-common-modules//modules/connectivity/hub_vnet?ref=v1.0.0"

  vnet_name              = "vnet-hub-prod-001"
  resource_group_name    = "rg-connectivity-hub"
  location               = var.location
  vnet_address_space     = ["10.0.0.0/16"]
  management_subnet_cidr = "10.0.1.0/24"
  tags                   = var.tags
}

module "aks" {
  source = "github.com/devsocket/terraform-common-modules//modules/app_platform/aks_cluster?ref=v1.0.0"

  cluster_name        = "aks-devsocket-dev"
  resource_group_name = "rg-aks-dev"
  location            = var.location
  dns_prefix          = "devsocket-dev"
  vnet_subnet_id      = module.spoke_vnet.aks_subnet_id
  app_gateway_id      = module.app_gateway.app_gateway_id
  tags                = var.tags
}
```

---

## Key Architecture Decisions

**RBAC over access policies for Key Vault**
`app_platform/key_vault` uses `enable_rbac_authorization = true`. Access policies are disabled entirely. All access is controlled via `azurerm_role_assignment` resources, consistent with managed identity and workload identity patterns.

**Two-identity pattern for AKS**
`app_platform/aks_cluster` exposes both `cluster_identity_principal_id` and `kubelet_identity_object_id` as separate outputs. The cluster identity handles VNet and infrastructure operations. The kubelet identity handles ACR image pulls and Key Vault secret access. These must never be conflated.

**AGIC lifecycle ignore**
`app_platform/app_gateway_waf_agic` includes `lifecycle { ignore_changes = [...] }` covering all AGIC-managed fields. Without this, every `terraform plan` after AKS connects shows drift from AGIC modifications. This is intentional — do not remove it.

**Log Analytics as the observability backbone**
`management/log_analytics` is deployed once per platform and its `workspace_id` output is passed into every other module via remote state. This avoids diagnostic log fragmentation and reduces cost through consolidated retention.

**Hub-spoke as first-class pattern**
`connectivity/hub_vnet` and `connectivity/spoke_vnet` are designed as a pair. Spoke peering and UDR configuration assumes a hub exists. Standalone spoke deployment without a hub is not a supported pattern.

---

## Versioning Strategy

Modules are versioned via Git tags using semantic versioning:

```bash
git tag v1.0.0
git push origin v1.0.0
```

| Increment | When |
|---|---|
| Patch `v1.0.x` | Bug fixes, description updates, non-breaking defaults |
| Minor `v1.x.0` | New optional variables, new output values |
| Major `vx.0.0` | Breaking changes to input/output contracts |

Always pin to a specific tag. Never reference `master` directly.

---

## Releases

| Version | Date | Notes |
|---|---|---|
| `v1.0.0` | April 2026 | First stable release — all modules validated end-to-end |
| `v0.2.0` | April 2026 | Added aks_cluster, app_gateway_waf_agic, storage, spoke_vnet, private_dns |
| `v0.1.0` | March 2026 | Initial alpha — hub_vnet, log_analytics, acr, key_vault |

---

## Related

- [terraform-landing-zone-demo](https://github.com/devsocket/terraform-landing-zone-demo) — Enterprise Azure Landing Zone consuming these modules
- [Microsoft Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) — Design principles this library aligns with
- [Azure Landing Zone Terraform Accelerator](https://github.com/Azure/alz-terraform-accelerator) — Microsoft reference implementation

---

## Author

**V Sudheer Kumar K** - Senior Technical Lead | Azure Solutions Architect (AZ-104, AZ-305 Certified)

[GitHub](https://github.com/devsocket) . [LinkedIn](https://www.linkedin.com/in/sudheer-kumar-k)
